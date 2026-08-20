///|
test "APDU diagnostics classify malformed input" {
  let short = parse_apdu_diagnostic([@types.START_BYTE])
  assert_true(short is Err(error) && error.kind() == APDUErrorKind::truncated())
  let prefix = parse_apdu_diagnostic([
    b'\x01', b'\x04', b'\x00', b'\x00', b'\x00', b'\x00',
  ])
  assert_true(
    prefix is Err(error) && error.kind() == APDUErrorKind::invalid_prefix(),
  )
  let valid = parse_apdu_diagnostic(encode_apdu(APDU::make_s(3))).unwrap()
  assert_eq(valid.frame_type_name(), "S-Frame")
}
