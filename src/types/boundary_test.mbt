///|
test "addresses expose checked constructors" {
  assert_true(IOA::try_new(-1) is Err(_))
  assert_true(IOA::try_new(0x1000000) is Err(_))
  assert_eq(IOA::try_new(0x123456).unwrap().value(), 0x123456)
  assert_true(CASDU::try_new(0) is Err(_))
  assert_eq(CASDU::try_new(0xFFFF).unwrap().address(), 0xFFFF)
}

///|
test "command qualifiers reject reserved pulse values" {
  let invalid = CommandQualifier::create(pulse_duration=32)
  assert_true(invalid.validate() is Err(_))
  assert_eq(
    CommandQualifier::create(pulse_duration=7).encode_checked().unwrap(),
    b'\x1C',
  )
}
