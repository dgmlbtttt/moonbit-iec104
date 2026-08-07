// MoonBit IEC 104 - Substation Simulation Unit Tests

///|
test "Substation model creation and bay setup" {
  let sub = SubstationModel::create(
    station_name="Substation-110kV-Beta",
    casdu_addr=10,
  )
  assert_eq(sub.station_name(), "Substation-110kV-Beta")
  assert_eq(sub.bays().length(), 3)

  let tr1 = sub.bays()[0]
  assert_eq(tr1.bay_id(), "TR-1")
  assert_true(tr1.breaker_state())
}

///|
test "Substation simulation step and fault injection" {
  let sub = SubstationModel::create()
  sub.activate_connection()
  assert_true(sub.slave_node().conn().is_active())

  let _ = sub.step(1000)
  let tr1 = sub.bays()[0]
  assert_true(tr1.current_a() > 100.0)

  // Inject overcurrent fault on Feeder-1 (index 1)
  let events = sub.trigger_bay_fault(1)
  let feeder1 = sub.bays()[1]
  assert_false(feeder1.breaker_state())
  assert_true(events.length() > 0)
}
