// Bounded alarm history with explicit acknowledgement state.

///|
pub enum AlarmSeverity {
  Info
  Warning
  Critical
} derive(Debug, Eq)

///|
pub fn AlarmSeverity::info() -> AlarmSeverity {
  Info
}

///|
pub fn AlarmSeverity::warning() -> AlarmSeverity {
  Warning
}

///|
pub fn AlarmSeverity::critical() -> AlarmSeverity {
  Critical
}

///|
pub struct AlarmRecord {
  id : Int
  ioa : Int
  severity : AlarmSeverity
  message : String
  raised_at : Int64
  mut acknowledged : Bool
} derive(Debug, Eq)

///|
pub fn AlarmRecord::id(self : AlarmRecord) -> Int {
  self.id
}

///|
pub fn AlarmRecord::ioa(self : AlarmRecord) -> Int {
  self.ioa
}

///|
pub fn AlarmRecord::severity(self : AlarmRecord) -> AlarmSeverity {
  self.severity
}

///|
pub fn AlarmRecord::message(self : AlarmRecord) -> String {
  self.message
}

///|
pub fn AlarmRecord::raised_at(self : AlarmRecord) -> Int64 {
  self.raised_at
}

///|
pub fn AlarmRecord::acknowledged(self : AlarmRecord) -> Bool {
  self.acknowledged
}

///|
pub fn AlarmRecord::acknowledge(self : AlarmRecord) -> Unit {
  self.acknowledged = true
}

///|
pub struct AlarmLog {
  capacity : Int
  mut next_id : Int
  mut records : Array[AlarmRecord]
} derive(Debug, Eq)

///|
pub fn AlarmLog::new(capacity : Int) -> AlarmLog {
  { capacity: if capacity < 1 { 1 } else { capacity }, next_id: 0, records: [] }
}

///|
pub fn AlarmLog::len(self : AlarmLog) -> Int {
  self.records.length()
}

///|
pub fn AlarmLog::records(self : AlarmLog) -> Array[AlarmRecord] {
  self.records
}

///|
pub fn AlarmLog::record(
  self : AlarmLog,
  ioa : Int,
  severity : AlarmSeverity,
  message : String,
  at_ms : Int64,
) -> Result[Int, String] {
  if ioa < 0 || at_ms < 0L || message.length() == 0 {
    return Err("invalid alarm record")
  }
  if self.records.length() >= self.capacity {
    let remaining : Array[AlarmRecord] = []
    for i = 1; i < self.records.length(); i = i + 1 {
      remaining.push(self.records[i])
    }
    self.records = remaining
  }
  let id = self.next_id
  self.next_id += 1
  self.records.push({
    id,
    ioa,
    severity,
    message,
    raised_at: at_ms,
    acknowledged: false,
  })
  Ok(id)
}

///|
pub fn AlarmLog::unacknowledged(self : AlarmLog) -> Array[AlarmRecord] {
  let result : Array[AlarmRecord] = []
  for record in self.records {
    if !record.acknowledged() {
      result.push(record)
    }
  }
  result
}

///|
pub fn AlarmLog::acknowledge(self : AlarmLog, id : Int) -> Bool {
  for record in self.records {
    if record.id() == id {
      record.acknowledge()
      return true
    }
  }
  false
}
