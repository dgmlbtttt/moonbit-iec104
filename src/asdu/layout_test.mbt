///|
test "ASDU validation checks header, count, and element family" {
  let valid_header = ASDUHeader::create(
    type_id=@types.TYPE_M_SP_NA_1,
    num_objects=1,
    cot=@types.COT_SPONTANEOUS,
    casdu=@types.CASDU::new(1),
  )
  let valid = ASDU::create(valid_header, [
    InformationElement::single_point(
      @types.IOA::new(1),
      @types.SIQ::create(value=true),
    ),
  ])
  assert_true(valid.validate() is Ok(_))

  let wrong = ASDU::create(valid_header, [
    InformationElement::double_point(
      @types.IOA::new(1),
      @types.DIQ::create(dpi=1),
    ),
  ])
  assert_true(wrong.validate() is Err(_))
}

///|
test "object layout reports fixed and sequence payload widths" {
  assert_eq(information_object_width(@types.TYPE_M_SP_NA_1, false).unwrap(), 4)
  assert_eq(information_object_width(@types.TYPE_M_SP_NA_1, true).unwrap(), 1)
  assert_eq(information_object_width(@types.TYPE_M_ME_TF_1, false).unwrap(), 16)
  assert_true(information_object_width(b'\xFF', false) is Err(_))
}
