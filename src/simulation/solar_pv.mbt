// MoonBit IEC 104 - Microgrid Solar PV Inverter Simulation Model

///|
pub struct SolarPVInverter {
  inverter_id : String
  voltage_ioa : Int
  current_ioa : Int
  power_ioa : Int
  status_ioa : Int
  capacity_kw : Double
  mut irradiance_w_m2 : Double
  mut active_power_kw : Double
  mut reactive_power_kvar : Double
  mut is_connected : Bool
  mut inverter_temp_c : Double
} derive(Debug, Eq)

///|
pub fn SolarPVInverter::create(
  inverter_id~ : String,
  voltage_ioa~ : Int,
  current_ioa~ : Int,
  power_ioa~ : Int,
  status_ioa~ : Int,
  capacity_kw? : Double = 500.0,
) -> SolarPVInverter {
  {
    inverter_id,
    voltage_ioa,
    current_ioa,
    power_ioa,
    status_ioa,
    capacity_kw,
    irradiance_w_m2: 800.0,
    active_power_kw: 400.0,
    reactive_power_kvar: 0.0,
    is_connected: true,
    inverter_temp_c: 45.0,
  }
}

///|
pub fn SolarPVInverter::inverter_id(self : SolarPVInverter) -> String {
  self.inverter_id
}

///|
pub fn SolarPVInverter::voltage_ioa(self : SolarPVInverter) -> Int {
  self.voltage_ioa
}

///|
pub fn SolarPVInverter::current_ioa(self : SolarPVInverter) -> Int {
  self.current_ioa
}

///|
pub fn SolarPVInverter::power_ioa(self : SolarPVInverter) -> Int {
  self.power_ioa
}

///|
pub fn SolarPVInverter::status_ioa(self : SolarPVInverter) -> Int {
  self.status_ioa
}

///|
pub fn SolarPVInverter::capacity_kw(self : SolarPVInverter) -> Double {
  self.capacity_kw
}

///|
pub fn SolarPVInverter::active_power_kw(self : SolarPVInverter) -> Double {
  self.active_power_kw
}

///|
pub fn SolarPVInverter::reactive_power_kvar(self : SolarPVInverter) -> Double {
  self.reactive_power_kvar
}

///|
pub fn SolarPVInverter::is_connected(self : SolarPVInverter) -> Bool {
  self.is_connected
}

///|
pub fn SolarPVInverter::inverter_temp_c(self : SolarPVInverter) -> Double {
  self.inverter_temp_c
}

///|
pub fn SolarPVInverter::set_irradiance(
  self : SolarPVInverter,
  irr : Double,
) -> Unit {
  self.irradiance_w_m2 = irr
  if self.is_connected {
    let efficiency = 0.96
    let p = self.capacity_kw * (irr / 1000.0) * efficiency
    if p > self.capacity_kw {
      self.active_power_kw = self.capacity_kw
    } else {
      self.active_power_kw = p
    }
  }
}

///|
pub fn SolarPVInverter::trip_inverter(self : SolarPVInverter) -> Unit {
  self.is_connected = false
  self.active_power_kw = 0.0
  self.reactive_power_kvar = 0.0
}

///|
pub fn SolarPVInverter::reset_inverter(self : SolarPVInverter) -> Unit {
  self.is_connected = true
  self.set_irradiance(self.irradiance_w_m2)
}

///|
pub fn SolarPVInverter::step_simulation(
  self : SolarPVInverter,
  elapsed_total_ms : Int64,
) -> Unit {
  if self.is_connected {
    let t_sec = (elapsed_total_ms / 1000L).to_double()
    let cloud_cover = t_sec * 0.05 % 1.0 * 150.0
    let cur_irr = 850.0 - cloud_cover
    self.set_irradiance(cur_irr)
    self.inverter_temp_c = 40.0 + self.active_power_kw / self.capacity_kw * 20.0
  }
}
