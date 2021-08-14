use std::sync::{RwLock, RwLockReadGuard, RwLockWriteGuard};
use serde::{Serialize, Deserialize};
use crate::queue;

/*
#[derive(Serialize, Default, Deserialize, Debug, Clone)]
pub struct QueueState {
    pub current_track: Option<usize>,
    pub random_order: Option<Vec<usize>>,
    pub track_progress: std::time::Duration,
    pub queue: Vec<SpotifyId>,
}
*/

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct UserState {
    pub volume: u16,
    pub shuffle: bool,
    pub repeat: queue::RepeatSetting,
    //pub queue_state: QueueState,
}

impl Default for UserState {
    fn default() -> Self {
        UserState {
            volume: u16::max_value(),
            shuffle: false,
            repeat: queue::RepeatSetting::None,
        }
    }
}

pub struct Config {
    state: RwLock<UserState>,
}

impl Config {
    pub fn new() -> Self {
        Self {
            state: RwLock::new(UserState::default())
        }
    }

    pub fn state(&self) -> RwLockReadGuard<UserState> {
        self.state.read().expect("can't readlock user state")
    }

    pub fn with_state_mut<F>(&self, cb: F)
    where
        F: Fn(RwLockWriteGuard<UserState>),
    {
        let state_guard = self.state.write().expect("can't writelock user state");
        cb(state_guard);
    }
}
