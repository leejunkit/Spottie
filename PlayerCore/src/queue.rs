/*
Adapted from ncspot's queue implementation found at
https://github.com/hrkfdn/ncspot/blob/HEAD/src/queue.rs

BSD 2-Clause License

Copyright (c) 2019, Henrik Friedrichsen
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

use std::cmp::Ordering;
use std::sync::{Mutex, Arc, RwLock};
use librespot::core::spotify_id::SpotifyId;
use librespot::playback::player::PlayerEvent as LibrespotPlayerEvent;
use tokio::sync::mpsc::{UnboundedReceiver};
use serde::{Serialize, Deserialize};
use rand::prelude::*;
use crate::spotify::{Spotify, PlayerEvent};
use crate::config::Config;

#[derive(Clone, Debug, Serialize)]
pub struct QueueState {
    pub items: Vec<String>,
    pub current_index: Option<usize>,
}

#[derive(Clone, Copy, PartialEq, Debug, Serialize, Deserialize)]
pub enum RepeatSetting {
    #[serde(rename = "off")]
    None,
    #[serde(rename = "playlist")]
    RepeatPlaylist,
    #[serde(rename = "track")]
    RepeatTrack,
}

pub struct Queue {
    pub queue: Arc<RwLock<Vec<SpotifyId>>>,
    random_order: RwLock<Option<Vec<usize>>>,
    current_track: RwLock<Option<usize>>,
    spotify: Arc<Mutex<Spotify>>,
    cfg: Arc<Config>,
}

impl Queue {
    pub fn new(spotify: Arc<Mutex<Spotify>>) -> Arc<Queue> {
        // get an event channel for LibrespotPlayerEvent
        let player_events_rx = spotify.lock().unwrap().get_player_event_channel();
        let cfg = Arc::new(Config::new());

        let q = Arc::new(Queue {
            queue: Arc::new(RwLock::new(vec![])),
            random_order: RwLock::new(Some(vec![])),
            current_track: RwLock::new(None),
            spotify,
            cfg,
        });

        Queue::player_events_run_loop(player_events_rx, q.clone());

        q
    }

    fn player_events_run_loop(mut events_rx: UnboundedReceiver<LibrespotPlayerEvent>, queue: Arc<Queue>) {
        tokio::spawn(async move {
            loop {
                let event = events_rx.recv().await;
                match event {
                    Some(LibrespotPlayerEvent::EndOfTrack { .. }) => {
                        queue.next(false);
                    }
                    Some(LibrespotPlayerEvent::TimeToPreloadNextTrack { .. }) => {
                        if let Some(next_index) = queue.next_index() {
                            let track = queue.queue.read().unwrap()[next_index].clone();
                            queue.spotify.lock().unwrap().preload(track);
                        }
                    }
                    _ => {}
                }
            }
        });
    }

    pub fn next_index(&self) -> Option<usize> {
        match *self.current_track.read().unwrap() {
            Some(mut index) => {
                let random_order = self.random_order.read().unwrap();
                if let Some(order) = random_order.as_ref() {
                    index = order.iter().position(|&i| i == index).unwrap();
                }

                let mut next_index = index + 1;
                if next_index < self.queue.read().unwrap().len() {
                    if let Some(order) = random_order.as_ref() {
                        next_index = order[next_index];
                    }

                    Some(next_index)
                } else {
                    None
                }
            }
            None => None,
        }
    }

    pub fn previous_index(&self) -> Option<usize> {
        match *self.current_track.read().unwrap() {
            Some(mut index) => {
                let random_order = self.random_order.read().unwrap();
                if let Some(order) = random_order.as_ref() {
                    index = order.iter().position(|&i| i == index).unwrap();
                }

                if index > 0 {
                    let mut next_index = index - 1;
                    if let Some(order) = random_order.as_ref() {
                        next_index = order[next_index];
                    }

                    Some(next_index)
                } else {
                    None
                }
            }
            None => None,
        }
    }

    pub fn get_current(&self) -> Option<SpotifyId> {
        self.get_current_index()
            .map(|index| self.queue.read().unwrap()[index].clone())
    }

    pub fn get_current_index(&self) -> Option<usize> {
        *self.current_track.read().unwrap()
    }

    pub fn insert_after_current(&self, track: SpotifyId) {
        if let Some(index) = self.get_current_index() {
            let mut random_order = self.random_order.write().unwrap();
            if let Some(order) = random_order.as_mut() {
                let next_i = order.iter().position(|&i| i == index).unwrap();
                // shift everything after the insertion in order
                for item in order.iter_mut() {
                    if *item > index {
                        *item += 1;
                    }
                }
                // finally, add the next track index
                order.insert(next_i + 1, index + 1);
            }
            let mut q = self.queue.write().unwrap();
            q.insert(index + 1, track);
        } else {
            self.append(track);
        }
    }

    pub fn append(&self, track: SpotifyId) {
        let mut random_order = self.random_order.write().unwrap();
        if let Some(order) = random_order.as_mut() {
            let index = order.len().saturating_sub(1);
            order.push(index);
        }

        let mut q = self.queue.write().unwrap();
        q.push(track);
    }

    pub fn append_next(&self, tracks: Vec<SpotifyId>) -> usize {
        let mut q = self.queue.write().unwrap();

        {
            let mut random_order = self.random_order.write().unwrap();
            if let Some(order) = random_order.as_mut() {
                order.extend((q.len().saturating_sub(1))..(q.len() + tracks.len()));
            }
        }

        let first = match *self.current_track.read().unwrap() {
            Some(index) => index + 1,
            None => q.len(),
        };

        let mut i = first;
        for track in tracks {
            q.insert(i, track.clone());
            i += 1;
        }

        first
    }

    pub fn remove(&self, index: usize) {
        {
            let mut q = self.queue.write().unwrap();
            if q.len() == 0 {
                return;
            }
            q.remove(index);
        }

        // if the queue is empty stop playback
        let len = self.queue.read().unwrap().len();
        if len == 0 {
            self.stop();
            return;
        }

        // if we are deleting the currently playing track, play the track with
        // the same index again, because the next track is now at the position
        // of the one we deleted
        let current = *self.current_track.read().unwrap();
        if let Some(current_track) = current {
            match current_track.cmp(&index) {
                Ordering::Equal => {
                    // if we have deleted the last item and it was playing
                    // stop playback, unless repeat playlist is on, play next
                    if current_track == len {
                        if self.get_repeat() == RepeatSetting::RepeatPlaylist {
                            self.next(false);
                        } else {
                            self.stop();
                        }
                    } else {
                        self.play(index, false, false);
                    }
                }
                Ordering::Greater => {
                    let mut current = self.current_track.write().unwrap();
                    current.replace(current_track - 1);
                }
                _ => (),
            }
        }

        if self.get_shuffle() {
            self.generate_random_order();
        }
    }

    pub fn clear(&self) {
        self.stop();

        let mut q = self.queue.write().unwrap();
        q.clear();

        let mut random_order = self.random_order.write().unwrap();
        if let Some(o) = random_order.as_mut() {
            o.clear()
        }
    }

    pub fn len(&self) -> usize {
        self.queue.read().unwrap().len()
    }

    pub fn shift(&self, from: usize, to: usize) {
        let mut queue = self.queue.write().unwrap();
        let item = queue.remove(from);
        queue.insert(to, item);

        // if the currently playing track is affected by the shift, update its
        // index
        let mut current = self.current_track.write().unwrap();
        if let Some(index) = *current {
            if index == from {
                current.replace(to);
            } else if index == to && from > index {
                current.replace(to + 1);
            } else if index == to && from < index {
                current.replace(to - 1);
            }
        }
    }

    pub fn play(&self, mut index: usize, reshuffle: bool, shuffle_index: bool) {
        if shuffle_index && self.get_shuffle() {
            let mut rng = rand::thread_rng();
            index = rng.gen_range(0..self.queue.read().unwrap().len());
        }

        if let Some(track) = self.queue.read().unwrap().get(index) {
            self.spotify.lock().unwrap().load(track.clone(), true, 0);
            let mut current = self.current_track.write().unwrap();
            current.replace(index);
        }

        if reshuffle && self.get_shuffle() {
            self.generate_random_order()
        }
    }

    pub fn toggleplayback(&self) {
        let spotify = self.spotify.lock().unwrap();
        let current_status = spotify.get_current_status();

        match current_status {
            PlayerEvent::Playing(_, _) | PlayerEvent::Paused(_, _) => {
                spotify.toggleplayback();
            }
            PlayerEvent::Stopped => match self.next_index() {
                Some(_) => {
                    drop(spotify);
                    self.next(false);
                }
                None => {
                    drop(spotify);
                    self.play(0, false, false);
                }
            },
            _ => (),
        }
    }

    pub fn stop(&self) {
        let mut current = self.current_track.write().unwrap();
        *current = None;
        self.spotify.lock().unwrap().stop();
    }

    pub fn next(&self, manual: bool) {
        let q = self.queue.read().unwrap();
        let current = *self.current_track.read().unwrap();
        let repeat = self.cfg.state().repeat;

        if repeat == RepeatSetting::RepeatTrack && !manual {
            if let Some(index) = current {
                self.play(index, false, false);
            }
        } else if let Some(index) = self.next_index() {
            self.play(index, false, false);
            if repeat == RepeatSetting::RepeatTrack && manual {
                self.set_repeat(RepeatSetting::RepeatPlaylist);
            }
        } else if repeat == RepeatSetting::RepeatPlaylist && q.len() > 0 {
            let random_order = self.random_order.read().unwrap();
            self.play(
                random_order.as_ref().map(|o| o[0]).unwrap_or(0),
                false,
                false,
            );
        } else {
            self.spotify.lock().unwrap().stop();
        }
    }

    pub fn previous(&self) {
        let q = self.queue.read().unwrap();
        let current = *self.current_track.read().unwrap();
        let repeat = self.cfg.state().repeat;

        if let Some(index) = self.previous_index() {
            self.play(index, false, false);
        } else if repeat == RepeatSetting::RepeatPlaylist && q.len() > 0 {
            if self.get_shuffle() {
                let random_order = self.random_order.read().unwrap();
                self.play(
                    random_order.as_ref().map(|o| o[q.len() - 1]).unwrap_or(0),
                    false,
                    false,
                );
            } else {
                self.play(q.len() - 1, false, false);
            }
        } else if let Some(index) = current {
            self.play(index, false, false);
        }
    }

    pub fn get_repeat(&self) -> RepeatSetting {
        self.cfg.state().repeat
    }

    pub fn set_repeat(&self, new: RepeatSetting) {
        self.cfg.with_state_mut(|mut s| s.repeat = new);
    }

    pub fn get_shuffle(&self) -> bool {
        self.cfg.state().shuffle
    }

    pub fn get_random_order(&self) -> Option<Vec<usize>> {
        self.random_order.read().unwrap().clone()
    }

    fn generate_random_order(&self) {
        let q = self.queue.read().unwrap();
        let mut order: Vec<usize> = Vec::with_capacity(q.len());
        let mut random: Vec<usize> = (0..q.len()).collect();

        if let Some(current) = *self.current_track.read().unwrap() {
            order.push(current);
            random.remove(current);
        }

        let mut rng = rand::thread_rng();
        random.shuffle(&mut rng);
        order.extend(random);

        let mut random_order = self.random_order.write().unwrap();
        *random_order = Some(order);
    }

    pub fn set_shuffle(&self, new: bool) {
        self.cfg.with_state_mut(|mut s| s.shuffle = new);
        if new {
            self.generate_random_order();
        } else {
            let mut random_order = self.random_order.write().unwrap();
            *random_order = None;
        }
    }
}