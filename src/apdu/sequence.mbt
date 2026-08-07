// MoonBit IEC 104 - Sequence Number and Window Management

///|
pub struct SequenceManager {
  mut send_seq : Int // N(S): Local send sequence number (0..32767)
  mut recv_seq : Int // N(R): Local receive sequence number (0..32767)
  mut ack_seq : Int // N(A): Last acknowledged sequence number
  max_unacked : Int // k: Max unacknowledged I frames (default 12)
  ack_threshold : Int // w: Max received I frames before sending S-frame (default 8)
  mut unacked_count : Int
} derive(Debug, Eq)

///|
pub fn SequenceManager::new(
  max_unacked? : Int = 12,
  ack_threshold? : Int = 8,
) -> SequenceManager {
  {
    send_seq: 0,
    recv_seq: 0,
    ack_seq: 0,
    max_unacked,
    ack_threshold,
    unacked_count: 0,
  }
}

///|
pub fn SequenceManager::send_seq(self : SequenceManager) -> Int {
  self.send_seq
}

///|
pub fn SequenceManager::recv_seq(self : SequenceManager) -> Int {
  self.recv_seq
}

///|
pub fn SequenceManager::ack_seq(self : SequenceManager) -> Int {
  self.ack_seq
}

///|
pub fn SequenceManager::unacked_count(self : SequenceManager) -> Int {
  self.unacked_count
}

///|
pub fn SequenceManager::reset(self : SequenceManager) -> Unit {
  self.send_seq = 0
  self.recv_seq = 0
  self.ack_seq = 0
  self.unacked_count = 0
}

///|
pub fn SequenceManager::next_send_seq(self : SequenceManager) -> Int {
  let seq = self.send_seq
  self.send_seq = (self.send_seq + 1) & 0x7FFF
  self.unacked_count = self.unacked_count + 1
  seq
}

///|
pub fn SequenceManager::confirm_recv(
  self : SequenceManager,
  remote_ns : Int,
) -> Result[Unit, String] {
  let expected = self.recv_seq
  if remote_ns != expected {
    return Err(
      "Sequence error: expected N(S)=" +
      expected.to_string() +
      ", got " +
      remote_ns.to_string(),
    )
  }
  self.recv_seq = (self.recv_seq + 1) & 0x7FFF
  Ok(())
}

///|
pub fn SequenceManager::update_ack(
  self : SequenceManager,
  remote_nr : Int,
) -> Unit {
  self.ack_seq = remote_nr
  self.unacked_count = 0
}

///|
pub fn SequenceManager::should_send_s_frame(self : SequenceManager) -> Bool {
  let diff = (self.recv_seq - self.ack_seq) & 0x7FFF
  diff >= self.ack_threshold
}

///|
pub fn SequenceManager::can_send_i_frame(self : SequenceManager) -> Bool {
  self.unacked_count < self.max_unacked
}
