use std::{env, fs};
use std::sync::mpsc;
use std::os::raw::c_char;
use tokio::runtime::Runtime;
use tokio::net::UnixListener;
use tokio_stream::wrappers::UnixListenerStream;
use warp::Filter;
use std::ffi::{c_void, CString};

mod api;
mod sink_wrapper;
mod spotify;
mod config;
mod queue;
mod event;

#[no_mangle]
pub extern "C" fn librespot_init(user_data: *const c_void, event_callback: extern fn(*const c_void, *mut u8, usize)) {
    let rt = Runtime::new().unwrap();
    rt.block_on(async move {
        let (sink_reload_tx, sink_reload_rx) = mpsc::sync_channel(1);
        let spotify = spotify::Spotify::new(sink_reload_rx).await;
        let queue = queue::Queue::new(spotify.clone());

        event::start_event_broadcast(spotify.clone(), queue.clone(), event::EventCallbackBox {
            ptr: user_data,
            callback: event_callback,
        });

        let mut dir = env::temp_dir();
        dir.push("warp.sock");
        println!("Temporary directory: {}", &dir.display());

        fs::remove_file(&dir).ok();

        let listener = UnixListener::bind(dir).unwrap();
        let incoming = UnixListenerStream::new(listener);

        let routes = api::filters::get_token(spotify.clone())
            .or(api::filters::play(queue.clone()))
            .or(api::filters::toggle_playback(queue.clone()))
            .or(api::filters::next(queue.clone()))
            .or(api::filters::previous(queue.clone()));

        warp::serve(routes)
            .run_incoming(incoming)
            .await;
    });
}

#[no_mangle]
pub extern "C" fn free_string(s: *mut c_char) {
    let cstring = unsafe { CString::from_raw(s) };
    drop(cstring);
}

#[no_mangle]
/// This is intended for the C code to call for deallocating
/// the Rust-allocated u8 array.
pub unsafe extern "C" fn deallocate_rust_buffer(ptr: *mut u8, len: usize) {
    drop(Vec::from_raw_parts(ptr, len, len));
}