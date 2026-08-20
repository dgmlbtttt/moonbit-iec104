// Runtime operating limits and alarm evaluation for simulated bays.

///|
pub struct OperatingLimits {
  min_voltage_kv : Double
  max_voltage_kv : Double
  max_current_a : Double
  min_frequency_hz : Double
  max_frequency_hz : Double
} derive(Debug, Eq)

///|
pub fn OperatingLimits::new(
  min_voltage_kv~ : Double,
  max_voltage_kv~ : Double,
  max_current_a~ : Double,
  min_frequency_hz~ : Double,
  max_frequency_hz~ : Double,
) -> Result[OperatingLimits, String] {
  if min_voltage_kv < 0.0 ||
    max_voltage_kv <= min_voltage_kv ||
    max_current_a <= 0.0 ||
    min_frequency_hz < 0.0 ||
    max_frequency_hz <= min_frequency_hz {
    return Err("invalid operating limits")
  }
  Ok({
    min_voltage_kv,
    max_voltage_kv,
    max_current_a,
    min_frequency_hz,
    max_frequency_hz,
  })
}

///|
pub fn OperatingLimits::voltage_ok(
  self : OperatingLimits,
  voltage_kv : Double,
) -> Bool {
  voltage_kv >= self.min_voltage_kv && voltage_kv <= self.max_voltage_kv
}

///|
pub fn OperatingLimits::current_ok(
  self : OperatingLimits,
  current_a : Double,
) -> Bool {
  current_a >= 0.0 && current_a <= self.max_current_a
}

///|
pub fn OperatingLimits::frequency_ok(
  self : OperatingLimits,
  frequency_hz : Double,
) -> Bool {
  frequency_hz >= self.min_frequency_hz && frequency_hz <= self.max_frequency_hz
}

///|
pub struct LimitEvaluation {
  voltage_ok : Bool
  current_ok : Bool
  frequency_ok : Bool
} derive(Debug, Eq)

///|
pub fn LimitEvaluation::voltage_ok(self : LimitEvaluation) -> Bool {
  self.voltage_ok
}

///|
pub fn LimitEvaluation::current_ok(self : LimitEvaluation) -> Bool {
  self.current_ok
}

///|
pub fn LimitEvaluation::frequency_ok(self : LimitEvaluation) -> Bool {
  self.frequency_ok
}

///|
pub fn LimitEvaluation::is_safe(self : LimitEvaluation) -> Bool {
  self.voltage_ok && self.current_ok && self.frequency_ok
}

///|
pub fn OperatingLimits::evaluate(
  self : OperatingLimits,
  voltage_kv : Double,
  current_a : Double,
  frequency_hz : Double,
) -> LimitEvaluation {
  {
    voltage_ok: self.voltage_ok(voltage_kv),
    current_ok: self.current_ok(current_a),
    frequency_ok: self.frequency_ok(frequency_hz),
  }
}
