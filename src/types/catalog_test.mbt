///|
test "type catalog classifies IEC 104 information types" {
  let telemetry = describe_type(TYPE_M_ME_TF_1).unwrap()
  assert_true(telemetry.is_measurement())
  assert_true(telemetry.has_cp56_time())
  assert_eq(telemetry.value_width(), 13)
  let command = describe_type(TYPE_C_SC_NA_1).unwrap()
  assert_true(command.is_command())
  assert_false(command.is_measurement())
  assert_true(describe_type(b'\xFF') is Err(_))
  assert_true(validate_cause_of_transmission(0) is Err(_))
  assert_true(validate_cause_of_transmission(3) is Ok(_))
}
