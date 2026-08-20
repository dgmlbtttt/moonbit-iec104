///|
test "ASDU headers reject impossible object counts and causes" {
  let header = ASDUHeader::create(
    type_id=@types.TYPE_M_SP_NA_1,
    num_objects=0,
    cot=0,
    casdu=@types.CASDU::new(1),
  )
  assert_true(header.validate() is Err(_))
}
