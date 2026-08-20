// Deterministic battery dispatch policy used by microgrid demonstrations.

///|
pub enum DispatchMode {
  Hold
  Charge
  Discharge
} derive(Debug, Eq)

///|
pub fn DispatchMode::hold() -> DispatchMode {
  Hold
}

///|
pub fn DispatchMode::charge() -> DispatchMode {
  Charge
}

///|
pub fn DispatchMode::discharge() -> DispatchMode {
  Discharge
}

///|
pub struct EnergyDispatchPolicy {
  min_soc : Double
  max_soc : Double
  max_power_kw : Double
  mut mode : DispatchMode
  mut requested_kw : Double
} derive(Debug, Eq)

///|
pub fn EnergyDispatchPolicy::new(
  min_soc~ : Double,
  max_soc~ : Double,
  max_power_kw~ : Double,
) -> Result[EnergyDispatchPolicy, String] {
  if min_soc < 0.0 ||
    max_soc > 100.0 ||
    min_soc >= max_soc ||
    max_power_kw <= 0.0 {
    return Err("invalid energy dispatch limits")
  }
  Ok({ min_soc, max_soc, max_power_kw, mode: Hold, requested_kw: 0.0 })
}

///|
pub fn EnergyDispatchPolicy::mode(self : EnergyDispatchPolicy) -> DispatchMode {
  self.mode
}

///|
pub fn EnergyDispatchPolicy::requested_kw(
  self : EnergyDispatchPolicy,
) -> Double {
  self.requested_kw
}

///|
pub fn EnergyDispatchPolicy::set_request(
  self : EnergyDispatchPolicy,
  mode : DispatchMode,
  power_kw : Double,
  soc : Double,
) -> Result[Double, String] {
  if soc < 0.0 || soc > 100.0 || power_kw < 0.0 {
    return Err("invalid battery request")
  }
  if mode == Charge && soc >= self.max_soc {
    self.mode = Hold
    self.requested_kw = 0.0
    return Ok(0.0)
  }
  if mode == Discharge && soc <= self.min_soc {
    self.mode = Hold
    self.requested_kw = 0.0
    return Ok(0.0)
  }
  let accepted = if power_kw > self.max_power_kw {
    self.max_power_kw
  } else {
    power_kw
  }
  self.mode = mode
  self.requested_kw = accepted
  Ok(accepted)
}

///|
pub fn EnergyDispatchPolicy::clear(self : EnergyDispatchPolicy) -> Unit {
  self.mode = Hold
  self.requested_kw = 0.0
}
