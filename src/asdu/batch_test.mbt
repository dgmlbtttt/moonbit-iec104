///|
test "ASDU batch builder flushes at configured object limit" {
  let batch = ASDUBatchBuilder::new(
    type_id=@types.TYPE_M_SP_NA_1,
    cot=@types.COT_SPONTANEOUS,
    casdu=@types.CASDU::new(1),
    max_objects=2,
  )
  let one = @asdu.InformationElement::single_point(
    @types.IOA::new(1),
    @types.SIQ::create(),
  )
  let two = @asdu.InformationElement::single_point(
    @types.IOA::new(2),
    @types.SIQ::create(),
  )
  assert_true(batch.add(one) is Ok(None))
  assert_true(batch.add(two) is Ok(Some(_)))
  assert_eq(batch.pending(), 0)
  assert_true(batch.flush() is None)
}
