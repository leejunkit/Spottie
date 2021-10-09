use librespot::core::authentication::Credentials;
use librespot::core::config::SessionConfig;
use librespot::core::session::Session;
use librespot::core::spotify_id::SpotifyId;
use librespot::core::mercury::MercuryError;
use librespot::core::keymaster;
use librespot::playback::config::PlayerConfig;
use librespot::playback::player::{Player, PlayerEvent as LibrespotPlayerEvent};
use tokio::sync::mpsc::{unbounded_channel, UnboundedSender, UnboundedReceiver};
use serde::Serialize;
use std::time::{Duration, SystemTime};
use std::sync::mpsc::Receiver;
use std::sync::{Arc, RwLock, Mutex};
use crate::sink_wrapper::SinkWrapper;

#[derive(Clone, Debug, Serialize)]
#[serde(rename_all = "lowercase")]
pub enum PlayerState {
    Playing,
    Paused,
    Stopped,
}

#[derive(Clone, Serialize, Debug)]
pub struct SpotifyState {
    pub state: PlayerState,
    pub track_id: Option<String>,
    pub elapsed: Option<u64>,
    pub since: Option<u64>,
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum PlayerEvent {
    Playing(SystemTime, SpotifyId),
    Paused(Duration, SpotifyId),
    Stopped,
    FinishedTrack,
}

pub struct Spotify {
    player: Player,
    session: Session,
    status: Arc<RwLock<PlayerEvent>>,
    elapsed: Arc<RwLock<Option<Duration>>>,
    since: Arc<RwLock<Option<SystemTime>>>,
    event_senders: Vec<UnboundedSender<SpotifyState>>,
}

impl Spotify {
    pub async fn new(sink_rx: Receiver<()>) -> Arc<Mutex<Spotify>> {
        let session_config = SessionConfig::default();
        let player_config = PlayerConfig::default();
        // TODO: use env var for this, to be specified in the Xcode side somehow?
        let credentials = Credentials::with_password("", "");

        println!("Connecting...");
        let session = Session::connect(session_config, credentials, None)
            .await
            .unwrap();
    
        let (player, player_events_rx) = Player::new(player_config, session.clone(), None, move || {
            SinkWrapper::new(sink_rx)
        });

        let spotify = Arc::new(Mutex::new(Spotify {
            player,
            session,
            status: Arc::new(RwLock::new(PlayerEvent::Stopped)),
            elapsed: Arc::new(RwLock::new(None)),
            since: Arc::new(RwLock::new(None)),
            event_senders: [].to_vec(),
        }));

        // handle Player events
        Spotify::player_events_run_loop(player_events_rx, spotify.clone());

        spotify
    }

    fn player_events_run_loop(mut events_rx: UnboundedReceiver<LibrespotPlayerEvent>, spotify: Arc<Mutex<Spotify>>) {
        tokio::spawn(async move {
            loop {
                let event = events_rx.recv().await;
                match event {
                    Some(LibrespotPlayerEvent::Playing {
                        play_request_id: _,
                        track_id,
                        position_ms,
                        duration_ms: _,
                    }) => {
                        let position = Duration::from_millis(position_ms as u64);
                        let playback_start = SystemTime::now() - position;
                        spotify.lock().unwrap().update_status(PlayerEvent::Playing(playback_start, track_id));
                    }
                    Some(LibrespotPlayerEvent::Paused {
                        play_request_id: _,
                        track_id,
                        position_ms,
                        duration_ms: _,
                    }) => {
                        let position = Duration::from_millis(position_ms as u64);
                        spotify.lock().unwrap().update_status(PlayerEvent::Paused(position, track_id));
                    }
                    Some(LibrespotPlayerEvent::Stopped { .. }) => {
                        spotify.lock().unwrap().update_status(PlayerEvent::Stopped);
                    }
                    _ => {}
                };
            }
        });
    }

    pub fn get_spotify_event_channel(&mut self) -> UnboundedReceiver<SpotifyState> {
        let (event_sender, event_receiver) = unbounded_channel();
        self.event_senders.push(event_sender);
        event_receiver
    }

    pub fn get_player_event_channel(&mut self) -> UnboundedReceiver<LibrespotPlayerEvent> {
        self.player.get_player_event_channel()
    }

    pub fn get_session(&self) -> &Session {
        &self.session
    }

    pub async fn get_token(&self) -> Result<keymaster::Token, MercuryError> {
        let client_id = "d420a117a32841c2b3474932e49fb54b";
        let scopes = "user-read-private,playlist-read-private,playlist-read-collaborative,playlist-modify-public,playlist-modify-private,user-follow-modify,user-follow-read,user-library-read,user-library-modify,user-top-read,user-read-recently-played";
        keymaster::get_token(&self.session, client_id, scopes).await
    }

    pub fn preload(&self, track: SpotifyId) {
        self.player.preload(track);
    }

    pub fn load(&mut self, track: SpotifyId, start_playing: bool, position_ms: u32) {
        self.player.load(track, start_playing, position_ms);
    }

    pub fn play(&self) {
        self.player.play();
    }

    pub fn pause(&self) {
        self.player.pause();
    }

    pub fn stop(&self) {
        self.player.stop();
    }
    
    pub fn seek(&self, position_ms: u32) {
        self.player.seek(position_ms);
    }
    
    pub fn toggleplayback(&self) {
        match self.get_current_status() {
            PlayerEvent::Playing(_, _) => self.pause(),
            PlayerEvent::Paused(_, _) => self.play(),
            _ => (),
        }
    }

    pub fn get_current_status(&self) -> PlayerEvent {
        let status = self
            .status
            .read()
            .expect("could not acquire read lock on playback status");
        (*status).clone()
    }

    pub fn update_status(&mut self, new_status: PlayerEvent) {
        {
            let mut status = self
            .status
            .write()
            .expect("could not acquire write lock on player status");
            *status = new_status;
        }

        match new_status {
            PlayerEvent::Paused(position, track_id) => {
                self.set_elapsed(Some(position));
                self.set_since(None);

                self.send_event(SpotifyState {
                    state: PlayerState::Paused,
                    track_id: Some(track_id.to_base62()),
                    elapsed: Some(position.as_secs()),
                    since: None,
                });
            }
            PlayerEvent::Playing(playback_start, track_id) => {
                self.set_since(Some(playback_start));
                self.set_elapsed(None);

                self.send_event(SpotifyState {
                    state: PlayerState::Playing,
                    track_id: Some(track_id.to_base62()),
                    elapsed: None,
                    since: Some(playback_start.duration_since(std::time::UNIX_EPOCH).unwrap().as_secs()),
                });
            }
            PlayerEvent::Stopped | PlayerEvent::FinishedTrack => {
                self.set_elapsed(None);
                self.set_since(None);

                self.send_event(SpotifyState {
                    state: PlayerState::Stopped,
                    track_id: None,
                    elapsed: None,
                    since: None,
                });
            }
        }
    }

    fn send_event(&mut self, event: SpotifyState) {
        let mut index = 0;
        while index < self.event_senders.len() {
            match self.event_senders[index].send(event.clone()) {
                Ok(_) => index += 1,
                Err(_) => {
                    self.event_senders.remove(index);
                }
            }
        }
    }

    fn set_elapsed(&self, new_elapsed: Option<Duration>) {
        let mut elapsed = self
            .elapsed
            .write()
            .expect("could not acquire write lock on elapsed time");
        *elapsed = new_elapsed;
    }

    pub fn get_elapsed(&self) -> Option<Duration> {
        let elapsed = self
            .elapsed
            .read()
            .expect("could not acquire read lock on elapsed time");
        *elapsed
    }

    fn set_since(&self, new_since: Option<SystemTime>) {
        let mut since = self
            .since
            .write()
            .expect("could not acquire write lock on since time");
        *since = new_since;
    }

    pub fn get_since(&self) -> Option<SystemTime> {
        let since = self
            .since
            .read()
            .expect("could not acquire read lock on since time");
        *since
    }
}
