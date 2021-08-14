use std::sync::{Arc, Mutex};
use crate::spotify::Spotify;

pub mod filters {
    use super::{handlers, Arc, Mutex, Spotify};
    use serde::{Deserialize};
    use crate::queue::Queue;
    use std::convert::Infallible;
    use warp::{
        Filter,
    };

    #[derive(Clone, Debug, Deserialize)]
    struct QueueRequestBody {
        track_ids: Vec<String>
    }

    pub fn get_token(spotify: Arc<Mutex<Spotify>>) -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
        warp::path!("token")
            .and(with_spotify(spotify))
            .and_then(handlers::get_token)
    }

    pub fn toggle_playback(queue: Arc<Queue>) -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
        warp::post()
            .and(warp::path!("queue" / "toggle"))
            .and(with_queue(queue))
            .and_then(handlers::toggle_playback)
    }

    pub fn play(queue: Arc<Queue>) -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
        warp::post()
            .and(warp::path!("queue" / "play"))
            .and(json_body())
            .map(|body: QueueRequestBody| {
                body.track_ids
            })
            .and(with_queue(queue))
            .and_then(handlers::play)
    }

    pub fn next(queue: Arc<Queue>) -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
        warp::post()
            .and(warp::path!("queue" / "next"))
            .and(with_queue(queue))
            .and_then(handlers::next)
    }

    pub fn previous(queue: Arc<Queue>) -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
        warp::post()
            .and(warp::path!("queue" / "previous"))
            .and(with_queue(queue))
            .and_then(handlers::previous)
    }

    // pub fn play_next(queue: Arc<Queue>) -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    //     warp::post()
    //         .and(warp::path!("queue/play_next"))
    // }

    // pub fn queue(queue: Arc<Queue>) -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    //     warp::post()
    //         .and(warp::path!("queue/push"))
    // }

    fn json_body() -> impl Filter<Extract = (QueueRequestBody,), Error = warp::Rejection> + Clone {
        warp::body::content_length_limit(1024 * 16).and(warp::body::json())
    }

    fn with_queue(queue: Arc<Queue>) -> impl Filter<Extract = (Arc<Queue>,), Error = Infallible> + Clone {
        warp::any().map(move || queue.clone())
    }

    fn with_spotify(spotify: Arc<Mutex<Spotify>>) -> impl Filter<Extract = (Arc<Mutex<Spotify>>,), Error = Infallible> + Clone {
        warp::any().map(move || spotify.clone())
    }
}

mod handlers {
    use librespot::core::spotify_id::SpotifyId;
    use librespot::core::keymaster;
    use serde::Serialize;
    use super::{Arc, Mutex, Spotify};
    use std::convert::Infallible;
    use warp::{Reply};
    use crate::queue::Queue;

    #[derive(Serialize)]
    struct TokenProxy {
        access_token: String,
        expires_in: u32,
        token_type: String,
        scope: Vec<String>,
    }

    pub async fn get_token(spotify: Arc<Mutex<Spotify>>) -> Result<impl Reply, Infallible> {
        let session = spotify.lock().unwrap().get_session().clone();
        let client_id = "d420a117a32841c2b3474932e49fb54b";
        let scopes = "user-read-private,playlist-read-private,playlist-read-collaborative,playlist-modify-public,playlist-modify-private,user-follow-modify,user-follow-read,user-library-read,user-library-modify,user-top-read,user-read-recently-played";
        let token = keymaster::get_token(&session, client_id, scopes).await.unwrap();
        let proxy = TokenProxy {
            access_token: token.access_token,
            expires_in: token.expires_in,
            token_type: token.token_type,
            scope: token.scope,
        };

        Ok(warp::reply::json(&proxy).into_response())
    }

    pub async fn play(track_ids: Vec<String>, queue: Arc<Queue>) -> Result<impl Reply, Infallible> {
        let q = queue.clone();
        
        // append the track_ids into the queue
        let index = q.append_next(track_ids.iter().map(|id: &String| {
            SpotifyId::from_base62(id).unwrap()
        }).collect());

        // start playback at the first inserted index
        q.play(index, true, true);

        // return latest queue items
        let queue_items = q.queue.read().unwrap();
        let ids: Vec<String> = queue_items.iter().map(|id: &SpotifyId| {
            id.to_base62()
        }).collect();

        Ok(warp::reply::json(&ids).into_response())
    }

    pub async fn toggle_playback(queue: Arc<Queue>) -> Result<impl Reply, Infallible> {
        let q = queue.clone();
        q.toggleplayback();
        Ok(warp::reply())
    }

    pub async fn next(queue: Arc<Queue>) -> Result<impl Reply, Infallible> {
        let q = queue.clone();
        q.next(true);
        Ok(warp::reply())
    }

    pub async fn previous(queue: Arc<Queue>) -> Result<impl Reply, Infallible> {
        let q = queue.clone();
        q.previous();
        Ok(warp::reply())
    }

    pub fn queue_append_after_current() {

    }
}