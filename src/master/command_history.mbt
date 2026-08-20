// Auditable outcomes for outbound control commands.

///|
pub enum CommandOutcome {
  Accepted
  Rejected
  TimedOut
  Completed
} derive(Debug, Eq)

///|
pub fn CommandOutcome::accepted() -> CommandOutcome {
  Accepted
}

///|
pub fn CommandOutcome::rejected() -> CommandOutcome {
  Rejected
}

///|
pub fn CommandOutcome::timed_out() -> CommandOutcome {
  TimedOut
}

///|
pub fn CommandOutcome::completed() -> CommandOutcome {
  Completed
}

///|
pub struct CommandHistoryEntry {
  id : Int
  ioa : Int
  outcome : CommandOutcome
  at_ms : Int64
} derive(Debug, Eq)

///|
pub fn CommandHistoryEntry::new(
  id~ : Int,
  ioa~ : Int,
  outcome~ : CommandOutcome,
  at_ms~ : Int64,
) -> CommandHistoryEntry {
  { id, ioa, outcome, at_ms }
}

///|
pub fn CommandHistoryEntry::id(self : CommandHistoryEntry) -> Int {
  self.id
}

///|
pub fn CommandHistoryEntry::ioa(self : CommandHistoryEntry) -> Int {
  self.ioa
}

///|
pub fn CommandHistoryEntry::outcome(
  self : CommandHistoryEntry,
) -> CommandOutcome {
  self.outcome
}

///|
pub fn CommandHistoryEntry::at_ms(self : CommandHistoryEntry) -> Int64 {
  self.at_ms
}

///|
pub struct CommandHistory {
  capacity : Int
  mut entries : Array[CommandHistoryEntry]
} derive(Debug, Eq)

///|
pub fn CommandHistory::new(capacity : Int) -> CommandHistory {
  { capacity: if capacity < 1 { 1 } else { capacity }, entries: [] }
}

///|
pub fn CommandHistory::len(self : CommandHistory) -> Int {
  self.entries.length()
}

///|
pub fn CommandHistory::entries(
  self : CommandHistory,
) -> Array[CommandHistoryEntry] {
  self.entries
}

///|
pub fn CommandHistory::append(
  self : CommandHistory,
  entry : CommandHistoryEntry,
) -> Unit {
  if self.entries.length() >= self.capacity {
    let remaining : Array[CommandHistoryEntry] = []
    for i = 1; i < self.entries.length(); i = i + 1 {
      remaining.push(self.entries[i])
    }
    self.entries = remaining
  }
  self.entries.push(entry)
}

///|
pub fn CommandHistory::count_outcome(
  self : CommandHistory,
  outcome : CommandOutcome,
) -> Int {
  let mut count = 0
  for entry in self.entries {
    if entry.outcome() == outcome {
      count += 1
    }
  }
  count
}
