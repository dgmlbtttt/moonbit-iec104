// Cross-cutting codec rules shared by validators and adapters.

///|
pub fn type_has_cp24_time(type_id : Byte) -> Bool {
  type_id == @types.TYPE_M_SP_TA_1 ||
  type_id == @types.TYPE_M_DP_TA_1 ||
  type_id == @types.TYPE_M_ST_TA_1 ||
  type_id == @types.TYPE_M_ME_TA_1 ||
  type_id == @types.TYPE_M_ME_TB_1 ||
  type_id == @types.TYPE_M_ME_TC_1 ||
  type_id == @types.TYPE_M_IT_TA_1
}

///|
pub fn type_has_cp56_time(type_id : Byte) -> Bool {
  type_id == @types.TYPE_M_SP_TB_1 ||
  type_id == @types.TYPE_M_DP_TB_1 ||
  type_id == @types.TYPE_M_ST_TB_1 ||
  type_id == @types.TYPE_M_ME_TD_1 ||
  type_id == @types.TYPE_M_ME_TE_1 ||
  type_id == @types.TYPE_M_ME_TF_1 ||
  type_id == @types.TYPE_M_IT_TB_1 ||
  type_id == @types.TYPE_C_CS_NA_1
}

///|
pub fn type_is_sequence_compatible(type_id : Byte) -> Bool {
  match information_object_width(type_id, true) {
    Ok(_) => true
    Err(_) => false
  }
}

///|
pub fn validate_object_count(
  type_id : Byte,
  sq : Bool,
  count : Int,
  payload_length : Int,
) -> Result[Unit, String] {
  if count < 1 || count > 127 {
    return Err("object count must be in 1..127")
  }
  if payload_length < 0 {
    return Err("payload length cannot be negative")
  }
  let width = match information_object_width(type_id, sq) {
    Ok(value) => value
    Err(e) => return Err(e)
  }
  let expected = if sq { width + 3 } else { width }
  if count > 1 && !sq {
    if payload_length != width * count {
      return Err("fixed-address payload width mismatch")
    }
  }
  if count > 1 && sq {
    if payload_length != expected + width * (count - 1) {
      return Err("sequence payload width mismatch")
    }
  }
  if count == 1 && payload_length != width {
    return Err("single-object payload width mismatch")
  }
  Ok(())
}
