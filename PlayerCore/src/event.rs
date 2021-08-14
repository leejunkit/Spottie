use std::ffi::{c_void};
use std::sync::{Arc, Mutex};
use serde_json::json;
use crate::queue::{Queue, QueueState};
use crate::spotify::*;

pub struct EventCallbackBox {
    pub ptr: *const c_void,
    pub callback: extern fn(*const c_void, *mut u8, usize)
}

unsafe impl Send for EventCallbackBox {}

pub fn start_event_broadcast(spotify: Arc<Mutex<Spotify>>, queue: Arc<Queue>, b: EventCallbackBox) {
    tokio::spawn(async move {
        let mut spotify_event_rx = spotify.lock().unwrap().get_spotify_event_channel();
        loop {
            let spotify_event = spotify_event_rx.recv().await;
            let queue_items = queue.queue.read().unwrap();
            let base62 = queue_items.clone().into_iter().map(|item| item.to_base62()).collect();

            let json = json!({
                "player": spotify_event,
                "queue": QueueState {
                    items: base62,
                    current_index: queue.get_current_index(),
                }
            });

            let mut v = serde_json::to_vec(&json).unwrap();
            v.shrink_to_fit();

            let ptr = v.as_mut_ptr();
            let len = v.len();

            let cb = b.callback;
            cb(b.ptr, ptr, len);
        }
    });
}