// MoonBit IEC 104 - IDMT Protection Relay Engine (IEC 60255 Standard Curves)

///|
pub enum RelayCurveType {
  StandardInverse
  VeryInverse
  ExtremelyInverse
} derive(Debug, Eq)

///|
pub fn RelayCurveType::standard_inverse() -> RelayCurveType {
  StandardInverse
}

///|
pub fn RelayCurveType::very_inverse() -> RelayCurveType {
  VeryInverse
}

///|
pub fn RelayCurveType::extremely_inverse() -> RelayCurveType {
  ExtremelyInverse
}

///|
pub struct IDMTProtectionRelay {
  pickup_current_a : Double
  time_multiplier : Double // TMS multiplier (e.g. 0.1 .. 1.0)
  curve_type : RelayCurveType
  mut accumulated_trip_ms : Double
  mut is_tripped : Bool
} derive(Debug, Eq)

///|
pub fn IDMTProtectionRelay::create(
  pickup_current_a? : Double = 200.0,
  time_multiplier? : Double = 0.5,
  curve_type? : RelayCurveType = StandardInverse,
) -> IDMTProtectionRelay {
  {
    pickup_current_a,
    time_multiplier,
    curve_type,
    accumulated_trip_ms: 0.0,
    is_tripped: false,
  }
}

///|
pub fn IDMTProtectionRelay::pickup_current_a(
  self : IDMTProtectionRelay,
) -> Double {
  self.pickup_current_a
}

///|
pub fn IDMTProtectionRelay::time_multiplier(
  self : IDMTProtectionRelay,
) -> Double {
  self.time_multiplier
}

///|
pub fn IDMTProtectionRelay::curve_type(
  self : IDMTProtectionRelay,
) -> RelayCurveType {
  self.curve_type
}

///|
pub fn IDMTProtectionRelay::is_tripped(self : IDMTProtectionRelay) -> Bool {
  self.is_tripped
}

///|
pub fn IDMTProtectionRelay::reset(self : IDMTProtectionRelay) -> Unit {
  self.accumulated_trip_ms = 0.0
  self.is_tripped = false
}

///|
pub fn IDMTProtectionRelay::calculate_trip_time_sec(
  self : IDMTProtectionRelay,
  fault_current_a : Double,
) -> Double {
  if fault_current_a <= self.pickup_current_a {
    return 99999.0
  }
  let psm = fault_current_a / self.pickup_current_a
  match self.curve_type {
    StandardInverse => {
      let base = psm * psm - 1.0
      if base <= 0.0 {
        100.0
      } else {
        0.14 / base * self.time_multiplier
      }
    }
    VeryInverse => {
      let base = psm - 1.0
      if base <= 0.0 {
        100.0
      } else {
        13.5 / base * self.time_multiplier
      }
    }
    ExtremelyInverse => {
      let base = psm * psm - 1.0
      if base <= 0.0 {
        100.0
      } else {
        80.0 / base * self.time_multiplier
      }
    }
  }
}

///|
pub fn IDMTProtectionRelay::check_fault(
  self : IDMTProtectionRelay,
  current_a : Double,
  delta_ms : Int,
) -> Bool {
  if self.is_tripped {
    return true
  }
  if current_a > self.pickup_current_a {
    let t_sec = self.calculate_trip_time_sec(current_a)
    let t_ms = t_sec * 1000.0
    self.accumulated_trip_ms = self.accumulated_trip_ms + delta_ms.to_double()
    if self.accumulated_trip_ms >= t_ms {
      self.is_tripped = true
    }
  } else {
    self.accumulated_trip_ms = 0.0
  }
  self.is_tripped
}
