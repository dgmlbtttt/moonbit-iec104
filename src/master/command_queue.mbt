// Bounded outbound command queue with deterministic retry accounting.

///|
pub struct QueuedCommand {
  id : Int
  ioa : Int
  state : Bool
  attempts : Int
} derive(Debug, Eq)

///|
pub fn QueuedCommand::id(self : QueuedCommand) -> Int {
  self.id
}

///|
pub fn QueuedCommand::ioa(self : QueuedCommand) -> Int {
  self.ioa
}

///|
pub fn QueuedCommand::state(self : QueuedCommand) -> Bool {
  self.state
}

///|
pub fn QueuedCommand::attempts(self : QueuedCommand) -> Int {
  self.attempts
}

///|
pub struct ControlCommandQueue {
  capacity : Int
  max_attempts : Int
  mut next_id : Int
  mut current : QueuedCommand?
  mut pending : Array[QueuedCommand]
} derive(Debug, Eq)

///|
pub fn ControlCommandQueue::new(
  capacity : Int,
  max_attempts : Int,
) -> ControlCommandQueue {
  {
    capacity: if capacity < 1 {
      1
    } else {
      capacity
    },
    max_attempts: if max_attempts < 1 {
      1
    } else {
      max_attempts
    },
    next_id: 0,
    current: None,
    pending: [],
  }
}

///|
pub fn ControlCommandQueue::pending_count(self : ControlCommandQueue) -> Int {
  self.pending.length()
}

///|
pub fn ControlCommandQueue::has_current(self : ControlCommandQueue) -> Bool {
  self.current is Some(_)
}

///|
pub fn ControlCommandQueue::enqueue(
  self : ControlCommandQueue,
  ioa : Int,
  state : Bool,
) -> Result[Int, String] {
  if ioa < 0 {
    return Err("command IOA cannot be negative")
  }
  if self.pending.length() + (if self.current is Some(_) { 1 } else { 0 }) >=
    self.capacity {
    return Err("command queue is full")
  }
  let id = self.next_id
  self.next_id = self.next_id + 1
  self.pending.push({ id, ioa, state, attempts: 0 })
  Ok(id)
}

///|
pub fn ControlCommandQueue::next(self : ControlCommandQueue) -> QueuedCommand? {
  if self.current is Some(_) {
    return self.current
  }
  if self.pending.length() == 0 {
    return None
  }
  let command = self.pending[0]
  let remaining : Array[QueuedCommand] = []
  for i = 1; i < self.pending.length(); i = i + 1 {
    remaining.push(self.pending[i])
  }
  self.pending = remaining
  self.current = Some(command)
  self.current
}

///|
pub fn ControlCommandQueue::retry_current(self : ControlCommandQueue) -> Bool {
  match self.current {
    None => false
    Some(command) =>
      if command.attempts >= self.max_attempts {
        false
      } else {
        self.current = Some({ ..command, attempts: command.attempts + 1 })
        true
      }
  }
}

///|
pub fn ControlCommandQueue::complete_current(
  self : ControlCommandQueue,
) -> Bool {
  match self.current {
    None => false
    Some(_) => {
      self.current = None
      true
    }
  }
}
