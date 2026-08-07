// MoonBit IEC 104 - APDU Unit Tests

///|
test "U-Frame encoding and parsing" {
  let frame = APDU::make_u(UFrameType::start_dt_act())
  let bytes = encode_apdu(frame)
  assert_eq(bytes.length(), 6)
  assert_eq(bytes[0], b'\x68')
  assert_eq(bytes[1], b'\x04')
  assert_eq(bytes[2], b'\x07')

  let parsed = parse_apdu(bytes).unwrap()
  match parsed {
    UFormat(u_type) => assert_eq(u_type, UFrameType::start_dt_act())
    _ => fail("Expected UFormat")
  }
}

///|
test "S-Frame encoding and parsing" {
  let frame = APDU::make_s(42)
  let bytes = encode_apdu(frame)
  assert_eq(bytes.length(), 6)

  let parsed = parse_apdu(bytes).unwrap()
  match parsed {
    SFormat(recv_seq) => assert_eq(recv_seq, 42)
    _ => fail("Expected SFormat")
  }
}

///|
test "I-Frame encoding and parsing" {
  let payload : Array[Byte] = [b'\x01', b'\x02', b'\x03', b'\x04', b'\x05']
  let frame = APDU::make_i(10, 20, payload)
  let bytes = encode_apdu(frame)
  assert_eq(bytes.length(), 11)

  let parsed = parse_apdu(bytes).unwrap()
  match parsed {
    IFormat(send_seq, recv_seq, p) => {
      assert_eq(send_seq, 10)
      assert_eq(recv_seq, 20)
      assert_eq(p.length(), 5)
      assert_eq(p[0], b'\x01')
      assert_eq(p[4], b'\x05')
    }
    _ => fail("Expected IFormat")
  }
}

///|
test "Sequence manager increment and ack" {
  let seq_mgr = SequenceManager::new(max_unacked=12, ack_threshold=8)
  assert_eq(seq_mgr.send_seq(), 0)

  let s0 = seq_mgr.next_send_seq()
  assert_eq(s0, 0)
  assert_eq(seq_mgr.send_seq(), 1)
  assert_eq(seq_mgr.unacked_count(), 1)

  assert_true(seq_mgr.confirm_recv(0) is Ok(_))
  assert_eq(seq_mgr.recv_seq(), 1)
}
