///|
fn test_gi_asdu(cot : Int, count : Int) -> @asdu.ASDU {
  let header = @asdu.ASDUHeader::create(
    type_id=@types.TYPE_M_SP_NA_1,
    num_objects=count,
    cot~,
    casdu=@types.CASDU::new(1),
  )
  let elements : Array[@asdu.InformationElement] = []
  for i = 0; i < count; i = i + 1 {
    elements.push(
      @asdu.InformationElement::single_point(
        @types.IOA::new(i + 1),
        @types.SIQ::create(value=true),
      ),
    )
  }
  @asdu.ASDU::create(header, elements)
}

///|
test "interrogation session enforces activation and termination order" {
  let session = InterrogationSession::new(@types.CASDU::new(1), 2)
  assert_true(session.start() is Ok(_))
  assert_true(session.start() is Err(_))
  assert_true(session.accept(test_gi_asdu(@types.COT_SPONTANEOUS, 1)) is Err(_))
  assert_true(
    session.accept(test_gi_asdu(@types.COT_ACTIVATION_CON, 1)) is Ok(_),
  )
  assert_eq(session.status(), InterrogationStatus::receiving_data())
  assert_true(
    session.accept(test_gi_asdu(@types.COT_INTERROGATED_STATION, 2)) is Ok(_),
  )
  assert_eq(session.received_objects(), 2)
  assert_true(
    session.accept(test_gi_asdu(@types.COT_ACTIVATION_TERMINATED, 1)) is Ok(_),
  )
  assert_eq(session.status(), InterrogationStatus::complete())
}

///|
test "interrogation session rejects a different station" {
  let session = InterrogationSession::new(@types.CASDU::new(1), 1)
  let _ = session.start()
  let wrong = @asdu.ASDU::create(
    @asdu.ASDUHeader::create(
      type_id=@types.TYPE_C_IC_NA_1,
      num_objects=1,
      cot=@types.COT_ACTIVATION_CON,
      casdu=@types.CASDU::new(2),
    ),
    [
      @asdu.InformationElement::interrogation_command(
        @types.IOA::new(0),
        @types.QOI_STATION_GI,
      ),
    ],
  )
  assert_true(session.accept(wrong) is Err(_))
}
