///|
test "validation report aggregates protocol boundary issues" {
  let address = validate_protocol_addresses(-1, 0)
  assert_false(address.is_valid())
  assert_eq(address.issues().length(), 2)
  let window = validate_frame_window(1, 40000)
  assert_false(window.is_valid())
  let merged = ValidationReport::new()
  merged.merge(address)
  merged.merge(window)
  assert_eq(merged.issues().length(), 3)
}
