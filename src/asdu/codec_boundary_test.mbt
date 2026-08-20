///|
test "ASDU headers cover object count and COT boundaries" {
  let counts : Array[Int] = [0, -1, 128, 255]
  for count in counts {
    let header = ASDUHeader::create(
      type_id=@types.TYPE_M_SP_NA_1,
      num_objects=count,
      cot=@types.COT_SPONTANEOUS,
      casdu=@types.CASDU::new(1),
    )
    assert_true(header.validate() is Err(_))
  }
  let causes : Array[Int] = [0, 48, 63, 255]
  for cot in causes {
    let header = ASDUHeader::create(
      type_id=@types.TYPE_M_SP_NA_1,
      num_objects=1,
      cot~,
      casdu=@types.CASDU::new(1),
    )
    assert_true(header.validate() is Err(_))
  }
}

///|
test "ASDU validation catches mismatched element types and counts" {
  let header = ASDUHeader::create(
    type_id=@types.TYPE_C_SC_NA_1,
    num_objects=2,
    cot=@types.COT_ACTIVATION,
    casdu=@types.CASDU::new(1),
  )
  let wrong = ASDU::create(header, [
    InformationElement::double_point(
      @types.IOA::new(1),
      @types.DIQ::create(dpi=1),
    ),
  ])
  assert_true(wrong.validate() is Err(_))
  let empty = ASDU::create(header, [])
  assert_true(empty.encode_checked() is Err(_))
}

///|
test "batch builder rejects all incompatible information families" {
  let builder = ASDUBatchBuilder::new(
    type_id=@types.TYPE_M_SP_NA_1,
    cot=@types.COT_SPONTANEOUS,
    casdu=@types.CASDU::new(1),
    max_objects=4,
  )
  let incompatible : Array[InformationElement] = [
    InformationElement::double_point(
      @types.IOA::new(1),
      @types.DIQ::create(dpi=1),
    ),
    InformationElement::interrogation_command(
      @types.IOA::new(0),
      @types.QOI_STATION_GI,
    ),
    InformationElement::clock_sync(
      @types.IOA::new(0),
      @types.CP56Time2a::default(),
    ),
  ]
  for element in incompatible {
    assert_true(builder.add(element) is Err(_))
  }
}
