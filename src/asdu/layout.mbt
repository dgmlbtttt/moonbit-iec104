// ASDU structural validation and object-layout metadata.

///|
pub fn information_object_width(
  type_id : Byte,
  sequence : Bool,
) -> Result[Int, String] {
  let value_width = match type_id.to_int() {
    0x01 => 1
    0x02 => 4
    0x03 => 1
    0x04 => 4
    0x05 => 3
    0x06 => 6
    0x07 => 5
    0x09 => 3
    0x0A => 6
    0x0B => 5
    0x0C => 8
    0x0D => 6
    0x0E => 9
    0x0F => 5
    0x10 => 12
    0x1E => 8
    0x1F => 8
    0x20 => 10
    0x22 => 10
    0x23 => 9
    0x24 => 13
    0x25 => 12
    0x2D => 1
    0x2E => 1
    0x2F => 1
    0x30 => 3
    0x31 => 3
    0x32 => 5
    0x64 => 1
    0x65 => 1
    0x66 => 0
    0x67 => 7
    0x68 => 1
    0x69 => 1
    _ => return Err("unsupported ASDU object layout")
  }
  if sequence {
    Ok(value_width)
  } else {
    Ok(value_width + 3)
  }
}

///|
fn element_matches(type_id : Byte, element : InformationElement) -> Bool {
  match element {
    SinglePointElem(_, _, _, _) =>
      type_id == @types.TYPE_M_SP_NA_1 ||
      type_id == @types.TYPE_M_SP_TA_1 ||
      type_id == @types.TYPE_M_SP_TB_1
    DoublePointElem(_, _, _, _) =>
      type_id == @types.TYPE_M_DP_NA_1 ||
      type_id == @types.TYPE_M_DP_TA_1 ||
      type_id == @types.TYPE_M_DP_TB_1
    StepPositionElem(_, _, _, _) =>
      type_id == @types.TYPE_M_ST_NA_1 ||
      type_id == @types.TYPE_M_ST_TA_1 ||
      type_id == @types.TYPE_M_ST_TB_1
    NormalizedTelemetryElem(_, _, _, _, _) =>
      type_id == @types.TYPE_M_ME_NA_1 ||
      type_id == @types.TYPE_M_ME_TA_1 ||
      type_id == @types.TYPE_M_ME_TD_1
    ScaledTelemetryElem(_, _, _, _, _) =>
      type_id == @types.TYPE_M_ME_NB_1 ||
      type_id == @types.TYPE_M_ME_TB_1 ||
      type_id == @types.TYPE_M_ME_TE_1
    ShortFloatTelemetryElem(_, _, _, _, _) =>
      type_id == @types.TYPE_M_ME_NC_1 ||
      type_id == @types.TYPE_M_ME_TC_1 ||
      type_id == @types.TYPE_M_ME_TF_1
    IntegratedTotalsElem(_, _, _, _, _, _, _) =>
      type_id == @types.TYPE_M_IT_NA_1 ||
      type_id == @types.TYPE_M_IT_TA_1 ||
      type_id == @types.TYPE_M_IT_TB_1
    SingleCommandElem(_, _) => type_id == @types.TYPE_C_SC_NA_1
    DoubleCommandElem(_, _) => type_id == @types.TYPE_C_DC_NA_1
    SetPointNormalizedElem(_, _, _) => type_id == @types.TYPE_C_SE_NA_1
    SetPointScaledElem(_, _, _) => type_id == @types.TYPE_C_SE_NB_1
    SetPointFloatElem(_, _, _) => type_id == @types.TYPE_C_SE_NC_1
    InterrogationCommandElem(_, _) => type_id == @types.TYPE_C_IC_NA_1
    CounterInterrogationElem(_, _) => type_id == @types.TYPE_C_CI_NA_1
    ClockSyncElem(_, _) => type_id == @types.TYPE_C_CS_NA_1
    ResetProcessElem(_, _) => type_id == @types.TYPE_C_RP_NA_1
  }
}

///|
pub fn ASDU::validate(self : ASDU) -> Result[Unit, String] {
  match self.header.validate() {
    Err(e) => return Err(e)
    Ok(_) => ()
  }
  if self.elements.length() != self.header.num_objects() {
    return Err("ASDU object count does not match element count")
  }
  for element in self.elements {
    if !element_matches(self.header.type_id(), element) {
      return Err("ASDU element does not match type identifier")
    }
  }
  Ok(())
}

///|
pub fn ASDU::encode_checked(self : ASDU) -> Result[Array[Byte], String] {
  match self.validate() {
    Ok(_) => Ok(self.encode())
    Err(e) => Err(e)
  }
}
