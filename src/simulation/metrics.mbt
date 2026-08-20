// Online statistics for deterministic simulation and benchmark reports.

///|
pub struct RunningMetrics {
  mut samples : Int
  mut sum : Double
  mut minimum : Double
  mut maximum : Double
  mut faults : Int
} derive(Debug, Eq)

///|
pub fn RunningMetrics::new() -> RunningMetrics {
  { samples: 0, sum: 0.0, minimum: 0.0, maximum: 0.0, faults: 0 }
}

///|
pub fn RunningMetrics::samples(self : RunningMetrics) -> Int {
  self.samples
}

///|
pub fn RunningMetrics::sum(self : RunningMetrics) -> Double {
  self.sum
}

///|
pub fn RunningMetrics::minimum(self : RunningMetrics) -> Double {
  self.minimum
}

///|
pub fn RunningMetrics::maximum(self : RunningMetrics) -> Double {
  self.maximum
}

///|
pub fn RunningMetrics::faults(self : RunningMetrics) -> Int {
  self.faults
}

///|
pub fn RunningMetrics::average(self : RunningMetrics) -> Double {
  if self.samples == 0 {
    0.0
  } else {
    self.sum / self.samples.to_double()
  }
}

///|
pub fn RunningMetrics::range(self : RunningMetrics) -> Double {
  if self.samples == 0 {
    0.0
  } else {
    self.maximum - self.minimum
  }
}

///|
pub fn RunningMetrics::observe(
  self : RunningMetrics,
  value : Double,
  fault : Bool,
) -> Unit {
  if self.samples == 0 {
    self.minimum = value
    self.maximum = value
  } else {
    if value < self.minimum {
      self.minimum = value
    }
    if value > self.maximum {
      self.maximum = value
    }
  }
  self.samples += 1
  self.sum += value
  if fault {
    self.faults += 1
  }
}

///|
pub fn RunningMetrics::reset(self : RunningMetrics) -> Unit {
  self.samples = 0
  self.sum = 0.0
  self.minimum = 0.0
  self.maximum = 0.0
  self.faults = 0
}
