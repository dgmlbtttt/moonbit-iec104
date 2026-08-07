// MoonBit IEC 104 - ASDU Unit Tests

///|
test "ASDU Single Point Information encoding and decoding" {
  let casdu = @types.CASDU::new(101)
  let hdr = ASDUHeader::create(
    type_id=@types.TYPE_M_SP_NA_1,
    num_objects=1,
    cot=@types.COT_SPONTANEOUS,
    casdu~,
  )
  let ioa = @types.IOA::new(1001)
  let siq = @types.SIQ::create(value=true, invalid=false)
  let elem = InformationElement::single_point(ioa, siq)

  let asdu = ASDU::create(hdr, [elem])
  let bytes = asdu.encode()
  assert_true(bytes.length() > 6)

  let decoded = ASDU::decode(bytes).unwrap()
  assert_eq(decoded.header().type_id(), @types.TYPE_M_SP_NA_1)
  assert_eq(decoded.header().casdu().address(), 101)
  assert_eq(decoded.elements().length(), 1)
}

///|
test "ASDU Short Float Telemetry encoding and decoding" {
  let casdu = @types.CASDU::new(200)
  let hdr = ASDUHeader::create(
    type_id=@types.TYPE_M_ME_NC_1,
    num_objects=1,
    cot=@types.COT_PERIODIC,
    casdu~,
  )
  let ioa = @types.IOA::new(4001)
  let qds = @types.QDS::default()
  let elem = InformationElement::short_float_telemetry(ioa, 220.5, qds)

  let asdu = ASDU::create(hdr, [elem])
  let bytes = asdu.encode()

  let decoded = ASDU::decode(bytes).unwrap()
  assert_eq(decoded.header().type_id(), @types.TYPE_M_ME_NC_1)
  assert_eq(decoded.elements().length(), 1)

  match decoded.elements()[0] {
    ShortFloatTelemetryElem(d_ioa, val, _, _, _) => {
      assert_eq(d_ioa.value(), 4001)
      let diff = (val - 220.5).abs()
      assert_true(diff < 0.01)
    }
    _ => fail("Expected ShortFloatTelemetryElem")
  }
}

///|
test "ASDU General Interrogation command encoding and decoding" {
  let casdu = @types.CASDU::new(1)
  let hdr = ASDUHeader::create(
    type_id=@types.TYPE_C_IC_NA_1,
    num_objects=1,
    cot=@types.COT_ACTIVATION,
    casdu~,
  )
  let ioa = @types.IOA::new(0)
  let elem = InformationElement::interrogation_command(
    ioa,
    @types.QOI_STATION_GI,
  )

  let asdu = ASDU::create(hdr, [elem])
  let bytes = asdu.encode()

  let decoded = ASDU::decode(bytes).unwrap()
  assert_eq(decoded.header().type_id(), @types.TYPE_C_IC_NA_1)
  assert_eq(decoded.header().cot(), @types.COT_ACTIVATION)
}
