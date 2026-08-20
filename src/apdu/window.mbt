// Explicit modulo-15-bit sequence window with cumulative acknowledgements.

///|
pub const SEQUENCE_MODULUS : Int = 32768

///|
pub struct ReliableSequenceWindow {
  mut send_next : Int
  mut receive_next_value : Int
  mut send_acknowledged : Int
  mut receive_acknowledged : Int
  max_send : Int
  ack_threshold : Int
} derive(Debug, Eq)

///|
pub fn ReliableSequenceWindow::new(
  max_send? : Int = 12,
  ack_threshold? : Int = 8,
) -> ReliableSequenceWindow {
  {
    send_next: 0,
    receive_next_value: 0,
    send_acknowledged: 0,
    receive_acknowledged: 0,
    max_send: if max_send < 1 || max_send >= SEQUENCE_MODULUS / 2 {
      1
    } else {
      max_send
    },
    ack_threshold: if ack_threshold < 1 {
      1
    } else {
      ack_threshold
    },
  }
}

///|
pub fn ReliableSequenceWindow::send_next(self : ReliableSequenceWindow) -> Int {
  self.send_next
}

///|
pub fn ReliableSequenceWindow::receive_next(
  self : ReliableSequenceWindow,
) -> Int {
  self.receive_next_value
}

///|
pub fn ReliableSequenceWindow::acknowledged(
  self : ReliableSequenceWindow,
) -> Int {
  self.send_acknowledged
}

///|
pub fn ReliableSequenceWindow::pending_send(
  self : ReliableSequenceWindow,
) -> Int {
  modulo_distance(self.send_acknowledged, self.send_next)
}

///|
pub fn ReliableSequenceWindow::pending_receive_ack(
  self : ReliableSequenceWindow,
) -> Int {
  modulo_distance(self.receive_acknowledged, self.receive_next_value)
}

///|
pub fn ReliableSequenceWindow::set_send_sequence(
  self : ReliableSequenceWindow,
  sequence : Int,
) -> Unit {
  self.send_next = normalize_sequence(sequence)
  self.send_acknowledged = self.send_next
}

///|
pub fn ReliableSequenceWindow::set_receive_sequence(
  self : ReliableSequenceWindow,
  sequence : Int,
) -> Unit {
  self.receive_next_value = normalize_sequence(sequence)
  self.receive_acknowledged = self.receive_next_value
}

///|
fn normalize_sequence(sequence : Int) -> Int {
  sequence & 0x7FFF
}

///|
fn modulo_distance(start : Int, end : Int) -> Int {
  (end - start) & 0x7FFF
}

///|
pub fn ReliableSequenceWindow::reserve_send(
  self : ReliableSequenceWindow,
) -> Result[Int, String] {
  if self.pending_send() >= self.max_send {
    return Err("send window is full")
  }
  let sequence = self.send_next
  self.send_next = (self.send_next + 1) & 0x7FFF
  Ok(sequence)
}

///|
pub fn ReliableSequenceWindow::receive(
  self : ReliableSequenceWindow,
  sequence : Int,
) -> Result[Unit, String] {
  let normalized = normalize_sequence(sequence)
  if normalized != self.receive_next_value {
    return Err(
      "unexpected receive sequence: expected " +
      self.receive_next_value.to_string(),
    )
  }
  self.receive_next_value = (self.receive_next_value + 1) & 0x7FFF
  Ok(())
}

///|
pub fn ReliableSequenceWindow::should_ack(
  self : ReliableSequenceWindow,
) -> Bool {
  self.pending_receive_ack() >= self.ack_threshold
}

///|
pub fn ReliableSequenceWindow::acknowledge(
  self : ReliableSequenceWindow,
  sequence : Int,
) -> Result[Unit, String] {
  let normalized = normalize_sequence(sequence)
  let distance = modulo_distance(self.send_acknowledged, normalized)
  let pending = self.pending_send()
  if distance > pending {
    return Err("acknowledgement is ahead of unacknowledged sends")
  }
  self.send_acknowledged = normalized
  Ok(())
}

///|
pub fn ReliableSequenceWindow::reset(self : ReliableSequenceWindow) -> Unit {
  self.send_next = 0
  self.receive_next_value = 0
  self.send_acknowledged = 0
  self.receive_acknowledged = 0
}
