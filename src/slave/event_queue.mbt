// Bounded spontaneous-event storage for a slave node.

///|
pub struct QueuedEvent {
  sequence : Int
  frame : @asdu.ASDU
} derive(Debug, Eq)

///|
pub fn QueuedEvent::sequence(self : QueuedEvent) -> Int {
  self.sequence
}

///|
pub fn QueuedEvent::frame(self : QueuedEvent) -> @asdu.ASDU {
  self.frame
}

///|
pub struct EventQueue {
  capacity : Int
  mut next_sequence : Int
  mut dropped : Int
  mut events : Array[QueuedEvent]
} derive(Debug, Eq)

///|
pub fn EventQueue::new(capacity : Int) -> EventQueue {
  {
    capacity: if capacity < 1 {
      1
    } else {
      capacity
    },
    next_sequence: 0,
    dropped: 0,
    events: [],
  }
}

///|
pub fn EventQueue::capacity(self : EventQueue) -> Int {
  self.capacity
}

///|
pub fn EventQueue::len(self : EventQueue) -> Int {
  self.events.length()
}

///|
pub fn EventQueue::is_empty(self : EventQueue) -> Bool {
  self.events.length() == 0
}

///|
pub fn EventQueue::dropped_count(self : EventQueue) -> Int {
  self.dropped
}

///|
pub fn EventQueue::push(self : EventQueue, frame : @asdu.ASDU) -> Bool {
  if self.events.length() >= self.capacity {
    self.dropped = self.dropped + 1
    return false
  }
  self.events.push({ sequence: self.next_sequence, frame })
  self.next_sequence = self.next_sequence + 1
  true
}

///|
pub fn EventQueue::pop(self : EventQueue) -> QueuedEvent? {
  if self.events.length() == 0 {
    return None
  }
  let first = self.events[0]
  let remaining : Array[QueuedEvent] = []
  for i = 1; i < self.events.length(); i = i + 1 {
    remaining.push(self.events[i])
  }
  self.events = remaining
  Some(first)
}

///|
pub fn EventQueue::drain(self : EventQueue, limit : Int) -> Array[QueuedEvent] {
  let result : Array[QueuedEvent] = []
  let amount = if limit < 0 { 0 } else { limit }
  for _i = 0; _i < amount; _i = _i + 1 {
    match self.pop() {
      Some(event) => result.push(event)
      None => break
    }
  }
  result
}
