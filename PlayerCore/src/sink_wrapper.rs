use librespot::playback::audio_backend;
use librespot::playback::config::AudioFormat;
use std::sync::mpsc::Receiver;
use librespot::audio::AudioPacket;
use std::io;

pub struct SinkWrapper {
    sink: Box<dyn audio_backend::Sink>,
    sink_rx: Receiver<()>,
}

impl SinkWrapper {
    pub fn new(sink_rx: Receiver<()>) -> Box<SinkWrapper> {
        Box::new(SinkWrapper {
            sink: SinkWrapper::get_sink(),
            sink_rx,
        })
    }

    fn get_sink() -> Box<dyn audio_backend::Sink> {
        let backend = audio_backend::find(None).unwrap();
        let audio_format = AudioFormat::default();
        backend(None, audio_format)
    }

    fn reload_sink(&mut self) {
        self.sink = SinkWrapper::get_sink();
    }
}

impl audio_backend::Sink for SinkWrapper {
    fn start(&mut self) -> Result<(), std::io::Error> { 
        Ok(())
    }

    fn stop(&mut self) -> Result<(), std::io::Error> {
        Ok(())
    }

    fn write(
        &mut self,
        packet: &AudioPacket
    ) -> io::Result<()> {
        let iter = self.sink_rx.try_iter();
        let c = iter.count();
        if c > 0 {
            self.reload_sink();
        }

        self.sink.write(packet)
    }
}