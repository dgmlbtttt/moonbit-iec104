// MoonBit IEC 104 - 110kV/35kV Substation Bay Physical Model

///|
pub struct SubstationBay {
  bay_id : String
  breaker_ioa : Int
  disconnector_ioa : Int
  voltage_ioa : Int
  current_ioa : Int
  power_ioa : Int
  freq_ioa : Int
  mut breaker_state : Bool
  disconnector_state : Bool
  base_voltage_kv : Double
  mut current_a : Double
  mut active_power_mw : Double
  mut frequency_hz : Double
  mut is_faulted : Bool
} derive(Debug, Eq)

///|
pub fn SubstationBay::create(
  bay_id~ : String,
  breaker_ioa~ : Int,
  disconnector_ioa~ : Int,
  voltage_ioa~ : Int,
  current_ioa~ : Int,
  power_ioa~ : Int,
  freq_ioa~ : Int,
  base_voltage_kv? : Double = 110.0,
) -> SubstationBay {
  {
    bay_id,
    breaker_ioa,
    disconnector_ioa,
    voltage_ioa,
    current_ioa,
    power_ioa,
    freq_ioa,
    breaker_state: true,
    disconnector_state: true,
    base_voltage_kv,
    current_a: 150.0,
    active_power_mw: 28.5,
    frequency_hz: 50.00,
    is_faulted: false,
  }
}

///|
pub fn SubstationBay::bay_id(self : SubstationBay) -> String {
  self.bay_id
}

///|
pub fn SubstationBay::breaker_ioa(self : SubstationBay) -> Int {
  self.breaker_ioa
}

///|
pub fn SubstationBay::disconnector_ioa(self : SubstationBay) -> Int {
  self.disconnector_ioa
}

///|
pub fn SubstationBay::voltage_ioa(self : SubstationBay) -> Int {
  self.voltage_ioa
}

///|
pub fn SubstationBay::current_ioa(self : SubstationBay) -> Int {
  self.current_ioa
}

///|
pub fn SubstationBay::power_ioa(self : SubstationBay) -> Int {
  self.power_ioa
}

///|
pub fn SubstationBay::freq_ioa(self : SubstationBay) -> Int {
  self.freq_ioa
}

///|
pub fn SubstationBay::base_voltage_kv(self : SubstationBay) -> Double {
  self.base_voltage_kv
}

///|
pub fn SubstationBay::breaker_state(self : SubstationBay) -> Bool {
  self.breaker_state
}

///|
pub fn SubstationBay::disconnector_state(self : SubstationBay) -> Bool {
  self.disconnector_state
}

///|
pub fn SubstationBay::current_a(self : SubstationBay) -> Double {
  self.current_a
}

///|
pub fn SubstationBay::active_power_mw(self : SubstationBay) -> Double {
  self.active_power_mw
}

///|
pub fn SubstationBay::frequency_hz(self : SubstationBay) -> Double {
  self.frequency_hz
}

///|
pub fn SubstationBay::is_faulted(self : SubstationBay) -> Bool {
  self.is_faulted
}

///|
pub fn SubstationBay::set_breaker_state(
  self : SubstationBay,
  state : Bool,
) -> Unit {
  self.breaker_state = state
  if !state {
    self.current_a = 0.0
    self.active_power_mw = 0.0
  }
}

///|
pub fn SubstationBay::inject_overcurrent_fault(self : SubstationBay) -> Unit {
  self.is_faulted = true
  self.current_a = 1250.0 // Heavy fault current 1.25kA
  self.set_breaker_state(false) // Protection trip!
}

///|
pub fn SubstationBay::clear_fault(self : SubstationBay) -> Unit {
  self.is_faulted = false
  self.current_a = 150.0
  self.set_breaker_state(true)
}

///|
fn wave_triangle(t_sec : Double) -> Double {
  let cycle = t_sec % 10.0 / 10.0
  if cycle < 0.5 {
    cycle * 4.0 - 1.0
  } else {
    3.0 - cycle * 4.0
  }
}

///|
pub fn SubstationBay::step_simulation(
  self : SubstationBay,
  elapsed_total_ms : Int64,
) -> Unit {
  if self.breaker_state && !self.is_faulted {
    let t_sec = (elapsed_total_ms / 1000L).to_double()
    let load_noise = wave_triangle(t_sec) * 5.0
    self.current_a = 150.0 + load_noise
    self.active_power_mw = 28.5 + load_noise * 0.18

    let freq_jitter = wave_triangle(t_sec + 2.5) * 0.02
    self.frequency_hz = 50.00 + freq_jitter
  }
}
