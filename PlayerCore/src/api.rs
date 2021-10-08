use std::sync::{Arc, Mutex};
use crate::spotify::Spotify;

pub mod filters {
    use super::{handlers, Arc, Mutex, Spotify};
    use serde::{Deserialize};
    use crate::queue::Queue;
    use std::convert::Infallible;
    use warp::http::HeaderMap;
    use warp::{
        Filter,
        Rejection
    };
    use bytes::{Bytes, Buf};
    use std::io::Read;

    #[derive(Clone, Debug, Deserialize)]
    struct QueueRequestBody {
        track_ids: Vec<String>
    }

    #[derive(Clone, Debug, Deserialize)]
    struct SeekRequestBody {
        position_ms: u32
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
            // .and(log_headers())
            // .and(log_body())
            // .and_then(handlers::noop)
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

    pub fn seek(spotify: Arc<Mutex<Spotify>>) -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
        warp::post()
            .and(warp::path!("player" / "seek"))
            .and(warp::body::json())
            .and(warp::body::content_length_limit(1000))
            .map(|body: SeekRequestBody| {
                body.position_ms
            })
            .and(with_spotify(spotify))
            .and_then(handlers::seek)
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
        warp::body::content_length_limit(1000000).and(warp::body::json())
    }

    fn with_queue(queue: Arc<Queue>) -> impl Filter<Extract = (Arc<Queue>,), Error = Infallible> + Clone {
        warp::any().map(move || queue.clone())
    }

    fn with_spotify(spotify: Arc<Mutex<Spotify>>) -> impl Filter<Extract = (Arc<Mutex<Spotify>>,), Error = Infallible> + Clone {
        warp::any().map(move || spotify.clone())
    }

    fn log_headers() -> impl Filter<Extract = (), Error = Infallible> + Copy {
        warp::header::headers_cloned()
            .map(|headers: HeaderMap| {
                for (k, v) in headers.iter() {
                    // Error from `to_str` should be handled properly
                    println!("{}: {}", k, v.to_str().expect("Failed to print header value"))
                }
            })
            .untuple_one()
    }

    fn log_body() -> impl Filter<Extract = (), Error = Rejection> + Copy {
        warp::body::bytes()
            .map(|b: Bytes| {
                // std::str::from_utf8(b.bytes());
                println!("bytes = {:?}", b);

                let data: Result<Vec<_>, _> = b.bytes().collect();
                let data = data.expect("Unable to read data");
                // println!("Request body: {}", std::str::from_utf8(data).expect("error converting bytes to &str"));
            })
            .untuple_one()
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
        //let scopes = "user-read-private,playlist-read-private,playlist-read-collaborative,playlist-modify-public,playlist-modify-private,user-follow-modify,user-follow-read,user-library-read,user-library-modify,user-top-read,user-read-recently-played";
        let scopes = ["ugc-image-upload", "playlist-read-collaborative", "playlist-modify-private", "playlist-modify-public", "playlist-read-private", "user-read-playback-position", "user-read-recently-played", "user-top-read", "user-modify-playback-state", "user-read-currently-playing", "user-read-playback-state", "user-read-private", "user-read-email", "user-library-modify", "user-library-read", "user-follow-modify", "user-follow-read", "streaming", "app-remote-control"].join(",");
        let token = keymaster::get_token(&session, client_id, &scopes).await.unwrap();
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

    pub async fn seek(position_ms: u32, spotify: Arc<Mutex<Spotify>>) -> Result<impl Reply, Infallible> {
        spotify.lock().unwrap().seek(position_ms);
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

    pub async fn noop() -> Result<impl warp::Reply, warp::Rejection> {
        Ok(warp::reply::reply())
    }
}