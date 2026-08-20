// Bounded connection transition history for diagnostics and observability.

///|
pub struct TransitionRecord {
  from : LinkStatus
  to : LinkStatus
  at_ms : Int64
} derive(Debug, Eq)

///|
pub fn TransitionRecord::from(self : TransitionRecord) -> LinkStatus {
  self.from
}

///|
pub fn TransitionRecord::to(self : TransitionRecord) -> LinkStatus {
  self.to
}

///|
pub fn TransitionRecord::at_ms(self : TransitionRecord) -> Int64 {
  self.at_ms
}

///|
pub struct ConnectionAuditLog {
  capacity : Int
  mut entries : Array[TransitionRecord]
} derive(Debug, Eq)

///|
pub fn ConnectionAuditLog::new(capacity : Int) -> ConnectionAuditLog {
  { capacity: if capacity < 1 { 1 } else { capacity }, entries: [] }
}

///|
pub fn ConnectionAuditLog::len(self : ConnectionAuditLog) -> Int {
  self.entries.length()
}

///|
pub fn ConnectionAuditLog::record(
  self : ConnectionAuditLog,
  from : LinkStatus,
  to : LinkStatus,
  at_ms : Int64,
) -> Unit {
  if self.entries.length() >= self.capacity {
    let remaining : Array[TransitionRecord] = []
    for i = 1; i < self.entries.length(); i = i + 1 {
      remaining.push(self.entries[i])
    }
    self.entries = remaining
  }
  self.entries.push({ from, to, at_ms })
}

///|
pub fn ConnectionAuditLog::latest(
  self : ConnectionAuditLog,
) -> TransitionRecord? {
  if self.entries.length() == 0 {
    None
  } else {
    Some(self.entries[self.entries.length() - 1])
  }
}

///|
pub fn ConnectionAuditLog::transitions_from(
  self : ConnectionAuditLog,
  status : LinkStatus,
) -> Int {
  let mut count = 0
  for entry in self.entries {
    if entry.from == status {
      count += 1
    }
  }
  count
}
