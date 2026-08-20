///|
test "event queue preserves FIFO order and reports overflow" {
  let queue = EventQueue::new(2)
  let first = @asdu.ASDU::create(
    @asdu.ASDUHeader::create(
      type_id=@types.TYPE_M_SP_NA_1,
      num_objects=1,
      cot=@types.COT_SPONTANEOUS,
      casdu=@types.CASDU::new(1),
    ),
    [
      @asdu.InformationElement::single_point(
        @types.IOA::new(1),
        @types.SIQ::create(value=true),
      ),
    ],
  )
  let second = @asdu.ASDU::create(
    @asdu.ASDUHeader::create(
      type_id=@types.TYPE_M_SP_NA_1,
      num_objects=1,
      cot=@types.COT_SPONTANEOUS,
      casdu=@types.CASDU::new(1),
    ),
    [
      @asdu.InformationElement::single_point(
        @types.IOA::new(2),
        @types.SIQ::create(value=false),
      ),
    ],
  )
  assert_true(queue.push(first))
  assert_true(queue.push(second))
  assert_false(queue.push(first))
  assert_eq(queue.len(), 2)
  assert_eq(queue.dropped_count(), 1)
  assert_eq(queue.pop().unwrap().sequence(), 0)
  assert_eq(queue.pop().unwrap().sequence(), 1)
  assert_true(queue.pop() is None)
}

///|
test "event queue drains a bounded batch" {
  let queue = EventQueue::new(4)
  let asdu = @asdu.ASDU::create(
    @asdu.ASDUHeader::create(
      type_id=@types.TYPE_M_SP_NA_1,
      num_objects=1,
      cot=@types.COT_SPONTANEOUS,
      casdu=@types.CASDU::new(1),
    ),
    [
      @asdu.InformationElement::single_point(
        @types.IOA::new(1),
        @types.SIQ::create(),
      ),
    ],
  )
  let _ = queue.push(asdu)
  let _ = queue.push(asdu)
  let _ = queue.push(asdu)
  assert_eq(queue.drain(2).length(), 2)
  assert_eq(queue.len(), 1)
}
