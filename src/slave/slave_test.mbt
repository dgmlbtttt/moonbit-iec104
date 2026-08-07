// MoonBit IEC 104 - Slave Node Unit Tests

///|
test "Slave node initialization and database populate" {
  let slave = SlaveNode::new(101)
  slave.db().set_single_point(1001, true)
  slave.db().set_telemetry_float(4001, 220.5)

  assert_eq(slave.db().get_single_point(1001), Some(true))
  let diff = (slave.db().get_telemetry_float(4001).unwrap() - 220.5).abs()
  assert_true(diff < 0.01)
}

///|
test "Slave node General Interrogation handling" {
  let slave = SlaveNode::new(1)
  slave.db().set_single_point(1001, true)
  slave.db().set_telemetry_float(4001, 10.5)

  let _ = slave
    .conn()
    .process_event(@state_machine.ConnectionEvent::connected())
  let _ = slave
    .conn()
    .process_event(@state_machine.ConnectionEvent::start_dt_act())
  assert_true(slave.conn().is_active())

  // Create GI command APDU
  let casdu = @types.CASDU::new(1)
  let hdr = @asdu.ASDUHeader::create(
    type_id=@types.TYPE_C_IC_NA_1,
    num_objects=1,
    cot=@types.COT_ACTIVATION,
    casdu~,
  )
  let ioa = @types.IOA::new(0)
  let elem = @asdu.InformationElement::interrogation_command(
    ioa,
    @types.QOI_STATION_GI,
  )
  let asdu = @asdu.ASDU::create(hdr, [elem])

  let apdu_req = @apdu.APDU::make_i(0, 0, asdu.encode())
  let res = slave.handle_apdu(apdu_req).unwrap()

  // GI response should include: ActivationCon, GI data ASDUs, ActivationTerminated
  assert_true(res.length() >= 3)
}
