// Immutable point-database view suitable for polling, logging, and tests.

///|
pub enum SnapshotKind {
  SinglePoint
  DoublePoint
  NormalizedTelemetry
  FloatTelemetry
  EnergyCounter
} derive(Debug, Eq)

///|
pub fn SnapshotKind::single_point() -> SnapshotKind {
  SinglePoint
}

///|
pub fn SnapshotKind::double_point() -> SnapshotKind {
  DoublePoint
}

///|
pub fn SnapshotKind::normalized_telemetry() -> SnapshotKind {
  NormalizedTelemetry
}

///|
pub fn SnapshotKind::telemetry_float() -> SnapshotKind {
  FloatTelemetry
}

///|
pub fn SnapshotKind::energy_counter() -> SnapshotKind {
  EnergyCounter
}

///|
pub enum SnapshotValue {
  Single(Bool)
  Double(Int)
  Normalized(Int)
  Float(Double)
  Counter(Int64)
} derive(Debug, Eq)

///|
pub struct SnapshotEntry {
  ioa : Int
  kind : SnapshotKind
  value : SnapshotValue
} derive(Debug, Eq)

///|
pub fn SnapshotEntry::ioa(self : SnapshotEntry) -> Int {
  self.ioa
}

///|
pub fn SnapshotEntry::kind(self : SnapshotEntry) -> SnapshotKind {
  self.kind
}

///|
pub fn SnapshotEntry::value(self : SnapshotEntry) -> SnapshotValue {
  self.value
}

///|
pub struct PointSnapshot {
  timestamp_ms : Int64
  entries : Array[SnapshotEntry]
} derive(Debug, Eq)

///|
pub fn PointSnapshot::timestamp_ms(self : PointSnapshot) -> Int64 {
  self.timestamp_ms
}

///|
pub fn PointSnapshot::entries(self : PointSnapshot) -> Array[SnapshotEntry] {
  self.entries
}

///|
pub fn PointSnapshot::find(self : PointSnapshot, ioa : Int) -> SnapshotEntry? {
  for entry in self.entries {
    if entry.ioa == ioa {
      return Some(entry)
    }
  }
  None
}

///|
pub fn PointSnapshot::count_kind(
  self : PointSnapshot,
  kind : SnapshotKind,
) -> Int {
  let mut count = 0
  for entry in self.entries {
    if entry.kind == kind {
      count = count + 1
    }
  }
  count
}

///|
pub fn PointDatabase::snapshot(
  self : PointDatabase,
  timestamp_ms : Int64,
) -> PointSnapshot {
  let entries : Array[SnapshotEntry] = []
  self.single_points.each(fn(ioa, value) {
    entries.push({ ioa, kind: SinglePoint, value: Single(value) })
  })
  self.double_points.each(fn(ioa, value) {
    entries.push({ ioa, kind: DoublePoint, value: Double(value) })
  })
  self.telemetry_norm.each(fn(ioa, value) {
    entries.push({ ioa, kind: NormalizedTelemetry, value: Normalized(value) })
  })
  self.telemetry_float.each(fn(ioa, value) {
    entries.push({ ioa, kind: FloatTelemetry, value: Float(value) })
  })
  self.energy_counters.each(fn(ioa, value) {
    entries.push({ ioa, kind: EnergyCounter, value: Counter(value) })
  })
  { timestamp_ms, entries }
}
