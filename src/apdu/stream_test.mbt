///|
test "stream decoder waits for a split APDU" {
  let bytes = encode_apdu(APDU::make_s(17))
  let decoder = APDUStreamDecoder::new()
  let first = decoder.push([bytes[0], bytes[1], bytes[2]])
  assert_true(first is Ok(frames) && frames.length() == 0)
  let second = decoder.push([bytes[3], bytes[4], bytes[5]])
  assert_true(second is Ok(frames) && frames.length() == 1)
  match second {
    Ok([SFormat(seq)]) => assert_eq(seq, 17)
    _ => fail("expected one decoded S-frame")
  }
}

///|
test "stream decoder extracts multiple APDUs from one chunk" {
  let first = encode_apdu(APDU::make_s(1))
  let second = encode_apdu(APDU::make_u(UFrameType::test_fr_act()))
  let decoder = APDUStreamDecoder::new()
  let chunk = first
  chunk.append(second)
  match decoder.push(chunk) {
    Ok([SFormat(1), UFormat(TestFRAct)]) => ()
    _ => fail("expected two decoded frames")
  }
}

///|
test "stream decoder rejects noise and oversized frames" {
  let decoder = APDUStreamDecoder::new()
  assert_true(decoder.push([b'\x01']) is Err(_))
  let oversized = [
    @types.START_BYTE,
    b'\xFF',
    b'\x01',
    b'\x00',
    b'\x00',
    b'\x00',
  ]
  assert_true(decoder.push(oversized) is Err(_))
}
