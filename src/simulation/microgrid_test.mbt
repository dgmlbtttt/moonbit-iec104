// MoonBit IEC 104 - Microgrid Physical Simulation Unit Tests

///|
test "Solar PV inverter power generation and cloud response" {
  let pv = SolarPVInverter::create(
    inverter_id="PV-01",
    voltage_ioa=5001,
    current_ioa=5002,
    power_ioa=5003,
    status_ioa=5004,
    capacity_kw=1000.0,
  )

  pv.set_irradiance(1000.0)
  assert_true(pv.active_power_kw() > 900.0)

  pv.trip_inverter()
  assert_false(pv.is_connected())
  assert_eq(pv.active_power_kw(), 0.0)
}

///|
test "Battery BESS charging and discharging dynamics" {
  let bess = BatteryBESS::create(
    bess_id="BESS-01",
    soc_ioa=6001,
    power_ioa=6002,
    status_ioa=6003,
    capacity_kwh=1000.0,
    max_power_kw=500.0,
  )

  assert_eq(bess.soc_percent(), 75.0)

  bess.set_mode(BESSMode::discharging(), 500.0)
  bess.step_simulation(3600000) // 1 hour discharge
  assert_true(bess.soc_percent() < 75.0)
}

///|
test "IDMT overcurrent protection curve calculation" {
  let relay = IDMTProtectionRelay::create(
    pickup_current_a=200.0,
    time_multiplier=0.5,
  )
  let t_sec = relay.calculate_trip_time_sec(1000.0) // 5x pickup current
  assert_true(t_sec > 0.0)
  assert_true(t_sec < 5.0)

  let tripped = relay.check_fault(1200.0, 10000) // 10s fault condition
  assert_true(tripped)
}
