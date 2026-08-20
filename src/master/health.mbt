// Master-side health summary for operational dashboards.

///|
pub struct LinkHealth {
  mut received_frames : Int
  mut sent_frames : Int
  mut protocol_errors : Int
  mut last_activity_ms : Int64
} derive(Debug, Eq)

///|
pub fn LinkHealth::new() -> LinkHealth {
  {
    received_frames: 0,
    sent_frames: 0,
    protocol_errors: 0,
    last_activity_ms: 0L,
  }
}

///|
pub fn LinkHealth::received_frames(self : LinkHealth) -> Int {
  self.received_frames
}

///|
pub fn LinkHealth::sent_frames(self : LinkHealth) -> Int {
  self.sent_frames
}

///|
pub fn LinkHealth::protocol_errors(self : LinkHealth) -> Int {
  self.protocol_errors
}

///|
pub fn LinkHealth::last_activity_ms(self : LinkHealth) -> Int64 {
  self.last_activity_ms
}

///|
pub fn LinkHealth::record_sent(self : LinkHealth, at_ms : Int64) -> Bool {
  if at_ms < self.last_activity_ms {
    false
  } else {
    self.sent_frames += 1
    self.last_activity_ms = at_ms
    true
  }
}

///|
pub fn LinkHealth::record_received(self : LinkHealth, at_ms : Int64) -> Bool {
  if at_ms < self.last_activity_ms {
    false
  } else {
    self.received_frames += 1
    self.last_activity_ms = at_ms
    true
  }
}

///|
pub fn LinkHealth::record_error(self : LinkHealth) -> Unit {
  self.protocol_errors += 1
}

///|
pub fn LinkHealth::healthy(self : LinkHealth) -> Bool {
  self.protocol_errors == 0 && self.last_activity_ms >= 0L
}
