// MoonBit IEC 104 - Microgrid Battery Energy Storage System (BESS) Physical Model

///|
pub enum BESSMode {
  BESSIdle
  BESSCharging
  BESSDischarging
} derive(Debug, Eq)

///|
pub fn BESSMode::idle() -> BESSMode {
  BESSIdle
}

///|
pub fn BESSMode::charging() -> BESSMode {
  BESSCharging
}

///|
pub fn BESSMode::discharging() -> BESSMode {
  BESSDischarging
}

///|
pub struct BatteryBESS {
  bess_id : String
  soc_ioa : Int
  power_ioa : Int
  status_ioa : Int
  capacity_kwh : Double
  max_power_kw : Double
  mut soc_percent : Double
  mut current_power_kw : Double
  mut mode : BESSMode
  mut cell_temp_c : Double
} derive(Debug, Eq)

///|
pub fn BatteryBESS::create(
  bess_id~ : String,
  soc_ioa~ : Int,
  power_ioa~ : Int,
  status_ioa~ : Int,
  capacity_kwh? : Double = 1000.0,
  max_power_kw? : Double = 500.0,
) -> BatteryBESS {
  {
    bess_id,
    soc_ioa,
    power_ioa,
    status_ioa,
    capacity_kwh,
    max_power_kw,
    soc_percent: 75.0,
    current_power_kw: 0.0,
    mode: BESSIdle,
    cell_temp_c: 28.0,
  }
}

///|
pub fn BatteryBESS::bess_id(self : BatteryBESS) -> String {
  self.bess_id
}

///|
pub fn BatteryBESS::soc_ioa(self : BatteryBESS) -> Int {
  self.soc_ioa
}

///|
pub fn BatteryBESS::power_ioa(self : BatteryBESS) -> Int {
  self.power_ioa
}

///|
pub fn BatteryBESS::status_ioa(self : BatteryBESS) -> Int {
  self.status_ioa
}

///|
pub fn BatteryBESS::soc_percent(self : BatteryBESS) -> Double {
  self.soc_percent
}

///|
pub fn BatteryBESS::current_power_kw(self : BatteryBESS) -> Double {
  self.current_power_kw
}

///|
pub fn BatteryBESS::mode(self : BatteryBESS) -> BESSMode {
  self.mode
}

///|
pub fn BatteryBESS::cell_temp_c(self : BatteryBESS) -> Double {
  self.cell_temp_c
}

///|
pub fn BatteryBESS::set_mode(
  self : BatteryBESS,
  new_mode : BESSMode,
  target_power_kw : Double,
) -> Unit {
  self.mode = new_mode
  match new_mode {
    BESSIdle => self.current_power_kw = 0.0
    BESSCharging => {
      let p = if target_power_kw > self.max_power_kw {
        self.max_power_kw
      } else {
        target_power_kw
      }
      self.current_power_kw = -p // Negative power indicates charging into battery
    }
    BESSDischarging => {
      let p = if target_power_kw > self.max_power_kw {
        self.max_power_kw
      } else {
        target_power_kw
      }
      self.current_power_kw = p // Positive power indicates discharging into grid
    }
  }
}

///|
pub fn BatteryBESS::step_simulation(self : BatteryBESS, delta_ms : Int) -> Unit {
  let dt_hours = delta_ms.to_double() / 3600000.0
  match self.mode {
    BESSCharging => {
      let energy_kwh = -self.current_power_kw * dt_hours * 0.95 // 95% charge efficiency
      let added_soc = energy_kwh / self.capacity_kwh * 100.0
      self.soc_percent = self.soc_percent + added_soc
      if self.soc_percent >= 100.0 {
        self.soc_percent = 100.0
        self.set_mode(BESSIdle, 0.0)
      }
      self.cell_temp_c = 28.0 +
        -self.current_power_kw / self.max_power_kw * 12.0
    }
    BESSDischarging => {
      let energy_kwh = self.current_power_kw * dt_hours / 0.95
      let dropped_soc = energy_kwh / self.capacity_kwh * 100.0
      self.soc_percent = self.soc_percent - dropped_soc
      if self.soc_percent <= 10.0 {
        self.soc_percent = 10.0
        self.set_mode(BESSIdle, 0.0)
      }
      self.cell_temp_c = 28.0 + self.current_power_kw / self.max_power_kw * 15.0
    }
    BESSIdle => self.cell_temp_c = 25.0
  }
}
