// MoonBit IEC 104 - Protocol Types Unit Tests

///|
test "CP56Time2a encoding and decoding" {
  let t = CP56Time2a::create(
    milliseconds=45678,
    minutes=34,
    invalid=false,
    substituted=false,
    hours=14,
    day_of_week=3,
    day_of_month=25,
    month=8,
    year=26,
  )
  let bytes = t.to_bytes()
  assert_eq(bytes.length(), 7)

  let decoded = CP56Time2a::from_bytes(bytes).unwrap()
  assert_eq(decoded.milliseconds(), 45678)
  assert_eq(decoded.minutes(), 34)
  assert_eq(decoded.hours(), 14)
  assert_eq(decoded.day_of_month(), 25)
  assert_eq(decoded.month(), 8)
  assert_eq(decoded.year(), 26)
}

///|
test "Quality descriptors encoding and decoding" {
  let qds = QDS::create(
    invalid=true,
    not_topical=false,
    substituted=true,
    blocked=false,
    overflow=true,
  )
  let b = qds.to_byte()
  let decoded = QDS::from_byte(b)
  assert_eq(decoded.invalid(), true)
  assert_eq(decoded.substituted(), true)
  assert_eq(decoded.overflow(), true)
  assert_eq(decoded.blocked(), false)
}

///|
test "IOA and CASDU conversion" {
  let ioa = IOA::new(0x123456)
  let bytes = ioa.to_bytes()
  let decoded_ioa = IOA::from_bytes(bytes).unwrap()
  assert_eq(decoded_ioa.value(), 0x123456)

  let casdu = CASDU::new(101)
  let casdu_bytes = casdu.to_bytes()
  let decoded_casdu = CASDU::from_bytes(casdu_bytes).unwrap()
  assert_eq(decoded_casdu.address(), 101)
  assert_false(decoded_casdu.is_broadcast())
}
