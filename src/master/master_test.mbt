// MoonBit IEC 104 - Master Node Unit Tests

///|
test "Master node initialization and GI dispatch" {
  let master = MasterNode::new(101)
  assert_eq(master.target_casdu().address(), 101)

  let _ = master
    .conn()
    .process_event(@state_machine.ConnectionEvent::connected())
  let _ = master
    .conn()
    .process_event(@state_machine.ConnectionEvent::start_dt_con())
  assert_true(master.conn().is_active())

  let gi_apdu = master.initiate_general_interrogation().unwrap()
  match gi_apdu {
    IFormat(ns, nr, _) => {
      assert_eq(ns, 0)
      assert_eq(nr, 0)
    }
    _ => fail("Expected IFormat GI request")
  }
}

///|
test "Master node single command dispatch" {
  let master = MasterNode::new(101)
  let _ = master
    .conn()
    .process_event(@state_machine.ConnectionEvent::connected())
  let _ = master
    .conn()
    .process_event(@state_machine.ConnectionEvent::start_dt_con())

  let cmd_apdu = master.send_single_command(6001, true, true).unwrap()
  match cmd_apdu {
    IFormat(ns, _, _) => assert_eq(ns, 0)
    _ => fail("Expected IFormat command request")
  }
}
