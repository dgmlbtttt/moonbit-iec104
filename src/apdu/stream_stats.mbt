// Counters for incremental APDU ingestion.

///|
pub struct StreamStatistics {
  mut chunks : Int
  mut bytes : Int
  mut frames : Int
  mut errors : Int
} derive(Debug, Eq)

///|
pub fn StreamStatistics::new() -> StreamStatistics {
  { chunks: 0, bytes: 0, frames: 0, errors: 0 }
}

///|
pub fn StreamStatistics::chunks(self : StreamStatistics) -> Int {
  self.chunks
}

///|
pub fn StreamStatistics::bytes(self : StreamStatistics) -> Int {
  self.bytes
}

///|
pub fn StreamStatistics::frames(self : StreamStatistics) -> Int {
  self.frames
}

///|
pub fn StreamStatistics::errors(self : StreamStatistics) -> Int {
  self.errors
}

///|
pub fn StreamStatistics::observe_chunk(
  self : StreamStatistics,
  byte_count : Int,
  frame_count : Int,
  failed : Bool,
) -> Bool {
  if byte_count < 0 || frame_count < 0 {
    self.errors += 1
    return false
  }
  self.chunks += 1
  self.bytes += byte_count
  self.frames += frame_count
  if failed {
    self.errors += 1
  }
  true
}

///|
pub fn StreamStatistics::reset(self : StreamStatistics) -> Unit {
  self.chunks = 0
  self.bytes = 0
  self.frames = 0
  self.errors = 0
}
