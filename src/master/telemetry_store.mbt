// Timestamped telemetry cache for master-side polling and quality filtering.

///|
pub enum TelemetryQuality {
  Good
  Invalid
  NotTopical
  Blocked
  Substituted
} derive(Debug, Eq)

///|
pub fn TelemetryQuality::good() -> TelemetryQuality {
  Good
}

///|
pub fn TelemetryQuality::invalid() -> TelemetryQuality {
  Invalid
}

///|
pub fn TelemetryQuality::not_topical() -> TelemetryQuality {
  NotTopical
}

///|
pub fn TelemetryQuality::blocked() -> TelemetryQuality {
  Blocked
}

///|
pub fn TelemetryQuality::substituted() -> TelemetryQuality {
  Substituted
}

///|
pub fn TelemetryQuality::is_usable(self : TelemetryQuality) -> Bool {
  match self {
    Good => true
    _ => false
  }
}

///|
pub struct TelemetrySample {
  ioa : Int
  value : Double
  quality : TelemetryQuality
  timestamp_ms : Int64
  revision : Int
} derive(Debug, Eq)

///|
pub fn TelemetrySample::ioa(self : TelemetrySample) -> Int {
  self.ioa
}

///|
pub fn TelemetrySample::value(self : TelemetrySample) -> Double {
  self.value
}

///|
pub fn TelemetrySample::quality(self : TelemetrySample) -> TelemetryQuality {
  self.quality
}

///|
pub fn TelemetrySample::timestamp_ms(self : TelemetrySample) -> Int64 {
  self.timestamp_ms
}

///|
pub fn TelemetrySample::revision(self : TelemetrySample) -> Int {
  self.revision
}

///|
pub struct TelemetryStore {
  samples : Map[Int, TelemetrySample]
  mut revision : Int
  retention_ms : Int64
} derive(Debug, Eq)

///|
pub fn TelemetryStore::new(retention_ms : Int64) -> TelemetryStore {
  {
    samples: Map([]),
    revision: 0,
    retention_ms: if retention_ms < 0L {
      0L
    } else {
      retention_ms
    },
  }
}

///|
pub fn TelemetryStore::len(self : TelemetryStore) -> Int {
  self.samples.length()
}

///|
pub fn TelemetryStore::retention_ms(self : TelemetryStore) -> Int64 {
  self.retention_ms
}

///|
pub fn TelemetryStore::get(
  self : TelemetryStore,
  ioa : Int,
) -> TelemetrySample? {
  self.samples.get(ioa)
}

///|
pub fn TelemetryStore::update(
  self : TelemetryStore,
  ioa : Int,
  value : Double,
  quality : TelemetryQuality,
  timestamp_ms : Int64,
) -> Bool {
  if ioa < 0 || timestamp_ms < 0L {
    return false
  }
  match self.samples.get(ioa) {
    Some(old) =>
      if timestamp_ms < old.timestamp_ms() {
        return false
      } else {
        ()
      }
    None => ()
  }
  self.revision = self.revision + 1
  self.samples.set(ioa, {
    ioa,
    value,
    quality,
    timestamp_ms,
    revision: self.revision,
  })
  true
}

///|
pub fn TelemetryStore::remove(self : TelemetryStore, ioa : Int) -> Bool {
  match self.samples.get(ioa) {
    Some(_) => {
      self.samples.remove(ioa)
      true
    }
    None => false
  }
}

///|
pub fn TelemetryStore::count_quality(
  self : TelemetryStore,
  quality : TelemetryQuality,
) -> Int {
  let mut count = 0
  self.samples.each(fn(_ioa, sample) {
    if sample.quality() == quality {
      count = count + 1
    }
  })
  count
}

///|
pub fn TelemetryStore::stale_before(
  self : TelemetryStore,
  timestamp_ms : Int64,
) -> Array[TelemetrySample] {
  let result : Array[TelemetrySample] = []
  self.samples.each(fn(_ioa, sample) {
    if timestamp_ms >= sample.timestamp_ms() &&
      timestamp_ms - sample.timestamp_ms() >= self.retention_ms {
      result.push(sample)
    }
  })
  result
}

///|
pub fn TelemetryStore::usable_at(
  self : TelemetryStore,
  ioa : Int,
  now_ms : Int64,
) -> TelemetrySample? {
  match self.samples.get(ioa) {
    Some(sample) =>
      if sample.quality().is_usable() &&
        now_ms >= sample.timestamp_ms() &&
        now_ms - sample.timestamp_ms() <= self.retention_ms {
        Some(sample)
      } else {
        None
      }
    None => None
  }
}
