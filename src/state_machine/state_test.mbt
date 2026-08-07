// MoonBit IEC 104 - State Machine Unit Tests

///|
test "Master state machine initialization and STARTDT" {
  let conn = ConnectionState::new(is_master=true)
  assert_eq(conn.status(), LinkStatus::unconnected())

  let res = conn.process_event(ConnectionEvent::connected()).unwrap()
  assert_eq(conn.status(), LinkStatus::pending_active())
  assert_eq(res.length(), 1)

  let _ = conn.process_event(ConnectionEvent::start_dt_con()).unwrap()
  assert_eq(conn.status(), LinkStatus::active())
  assert_true(conn.is_active())
}

///|
test "Slave state machine STARTDT handling" {
  let conn = ConnectionState::new(is_master=false)
  assert_eq(conn.status(), LinkStatus::unconnected())

  let _ = conn.process_event(ConnectionEvent::connected()).unwrap()
  assert_eq(conn.status(), LinkStatus::stopped())

  let res = conn.process_event(ConnectionEvent::start_dt_act()).unwrap()
  assert_eq(conn.status(), LinkStatus::active())
  assert_eq(res.length(), 1)
}

///|
test "I-Frame sequence tracking in state machine" {
  let master = ConnectionState::new(is_master=true)
  let _ = master.process_event(ConnectionEvent::connected())
  let _ = master.process_event(ConnectionEvent::start_dt_con())

  let payload : Array[Byte] = [b'\x01', b'\x02']
  let frame = master.send_i_frame(payload).unwrap()
  match frame {
    IFormat(ns, nr, _) => {
      assert_eq(ns, 0)
      assert_eq(nr, 0)
    }
    _ => fail("Expected IFormat")
  }
}
