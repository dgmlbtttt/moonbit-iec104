///|
test "codec matrix validates sequence and fixed address payloads" {
  assert_true(type_has_cp24_time(@types.TYPE_M_SP_TA_1))
  assert_true(type_has_cp56_time(@types.TYPE_M_ME_TF_1))
  assert_true(type_is_sequence_compatible(@types.TYPE_M_SP_NA_1))
  assert_true(
    validate_object_count(@types.TYPE_M_SP_NA_1, false, 2, 8) is Ok(_),
  )
  assert_true(validate_object_count(@types.TYPE_M_SP_NA_1, true, 2, 5) is Ok(_))
  assert_true(
    validate_object_count(@types.TYPE_M_SP_NA_1, false, 2, 5) is Err(_),
  )
}
