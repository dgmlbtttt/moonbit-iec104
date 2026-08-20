// MoonBit IEC 104 - Complete 110kV Substation Automation Model

///|
pub struct SubstationModel {
  station_name : String
  bays : Array[SubstationBay]
  slave_node : @slave.SlaveNode
  mut total_sim_time_ms : Int64
  mut generated_events_count : Int
} derive(Debug, Eq)

///|
pub fn SubstationModel::create(
  station_name? : String = "Substation-110kV-Alpha",
  casdu_addr? : Int = 1,
) -> SubstationModel {
  let slave = @slave.SlaveNode::new(casdu_addr)

  // Create 3 Substation Bays: Transformer Bay 1, Feeder Bay 1, Feeder Bay 2
  let bay1 = SubstationBay::create(
    bay_id="TR-1",
    breaker_ioa=1001,
    disconnector_ioa=1002,
    voltage_ioa=4001,
    current_ioa=4002,
    power_ioa=4003,
    freq_ioa=4004,
    base_voltage_kv=110.0,
  )

  let bay2 = SubstationBay::create(
    bay_id="FEEDER-1",
    breaker_ioa=1003,
    disconnector_ioa=1004,
    voltage_ioa=4005,
    current_ioa=4006,
    power_ioa=4007,
    freq_ioa=4008,
    base_voltage_kv=35.0,
  )

  let bay3 = SubstationBay::create(
    bay_id="FEEDER-2",
    breaker_ioa=1005,
    disconnector_ioa=1006,
    voltage_ioa=4009,
    current_ioa=4010,
    power_ioa=4011,
    freq_ioa=4012,
    base_voltage_kv=35.0,
  )

  let bays : Array[SubstationBay] = [bay1, bay2, bay3]

  // Initialize Point Database with Bay initial states
  for i = 0; i < bays.length(); i = i + 1 {
    let b = bays[i]
    slave.db().set_single_point(b.breaker_ioa(), b.breaker_state())
    slave.db().set_single_point(b.disconnector_ioa(), b.disconnector_state())
    slave.db().set_telemetry_float(b.voltage_ioa(), b.base_voltage_kv())
    slave.db().set_telemetry_float(b.current_ioa(), b.current_a())
    slave.db().set_telemetry_float(b.power_ioa(), b.active_power_mw())
    slave.db().set_telemetry_float(b.freq_ioa(), b.frequency_hz())
  }

  {
    station_name,
    bays,
    slave_node: slave,
    total_sim_time_ms: 0L,
    generated_events_count: 0,
  }
}

///|
pub fn SubstationModel::station_name(self : SubstationModel) -> String {
  self.station_name
}

///|
pub fn SubstationModel::bays(self : SubstationModel) -> Array[SubstationBay] {
  self.bays
}

///|
pub fn SubstationModel::slave_node(self : SubstationModel) -> @slave.SlaveNode {
  self.slave_node
}

///|
pub fn SubstationModel::generated_events_count(self : SubstationModel) -> Int {
  self.generated_events_count
}

///|
pub fn SubstationModel::activate_connection(self : SubstationModel) -> Unit {
  let conn = self.slave_node.conn()
  let _ = conn.process_event(@state_machine.ConnectionEvent::connected())
  let _ = conn.process_event(@state_machine.ConnectionEvent::start_dt_act())
}

///|
pub fn SubstationModel::step(
  self : SubstationModel,
  delta_ms : Int,
) -> Array[@apdu.APDU] {
  self.total_sim_time_ms = self.total_sim_time_ms + delta_ms.to_int64()
  let spontaneous_apdus : Array[@apdu.APDU] = []

  for i = 0; i < self.bays.length(); i = i + 1 {
    let bay = self.bays[i]
    let old_brk = bay.breaker_state()

    bay.step_simulation(self.total_sim_time_ms)
    let new_brk = bay.breaker_state()

    if old_brk != new_brk {
      self.generated_events_count = self.generated_events_count + 1
      match
        self.slave_node.report_spontaneous_single_point(
          bay.breaker_ioa(),
          new_brk,
        ) {
        Ok(apdu) => spontaneous_apdus.push(apdu)
        Err(_) => ()
      }
    }

    self.slave_node.db().set_telemetry_float(bay.current_ioa(), bay.current_a())
    self.slave_node
    .db()
    .set_telemetry_float(bay.power_ioa(), bay.active_power_mw())
    self.slave_node.db().set_telemetry_float(bay.freq_ioa(), bay.frequency_hz())
  }

  spontaneous_apdus
}

///|
pub fn SubstationModel::trigger_bay_fault(
  self : SubstationModel,
  bay_index : Int,
) -> Array[@apdu.APDU] {
  if bay_index < 0 || bay_index >= self.bays.length() {
    return []
  }
  let bay = self.bays[bay_index]
  let old_brk = bay.breaker_state()
  bay.inject_overcurrent_fault()
  let new_brk = bay.breaker_state()

  let spontaneous_apdus : Array[@apdu.APDU] = []
  if old_brk != new_brk {
    self.generated_events_count = self.generated_events_count + 1
    match
      self.slave_node.report_spontaneous_single_point(
        bay.breaker_ioa(),
        new_brk,
      ) {
      Ok(apdu) => spontaneous_apdus.push(apdu)
      Err(_) => ()
    }
  }
  spontaneous_apdus
}

///|
pub fn SubstationModel::clear_bay_fault(
  self : SubstationModel,
  bay_index : Int,
) -> Bool {
  if bay_index < 0 || bay_index >= self.bays.length() {
    return false
  }
  let bay = self.bays[bay_index]
  bay.clear_fault()
  self.slave_node.db().set_single_point(bay.breaker_ioa(), bay.breaker_state())
  self.slave_node.db().set_telemetry_float(bay.current_ioa(), bay.current_a())
  self.slave_node
  .db()
  .set_telemetry_float(bay.power_ioa(), bay.active_power_mw())
  true
}
