// Stable metadata for supported IEC 104 type identifiers.

///|
pub struct TypeDescriptor {
  type_id : Byte
  name : String
  value_width : Int
  measurement : Bool
  command : Bool
  cp24_time : Bool
  cp56_time : Bool
} derive(Debug, Eq)

///|
pub fn TypeDescriptor::type_id(self : TypeDescriptor) -> Byte {
  self.type_id
}

///|
pub fn TypeDescriptor::name(self : TypeDescriptor) -> String {
  self.name
}

///|
pub fn TypeDescriptor::value_width(self : TypeDescriptor) -> Int {
  self.value_width
}

///|
pub fn TypeDescriptor::is_measurement(self : TypeDescriptor) -> Bool {
  self.measurement
}

///|
pub fn TypeDescriptor::is_command(self : TypeDescriptor) -> Bool {
  self.command
}

///|
pub fn TypeDescriptor::has_cp24_time(self : TypeDescriptor) -> Bool {
  self.cp24_time
}

///|
pub fn TypeDescriptor::has_cp56_time(self : TypeDescriptor) -> Bool {
  self.cp56_time
}

///|
fn descriptor(
  type_id : Byte,
  name : String,
  value_width : Int,
  measurement : Bool,
  command : Bool,
  cp24_time : Bool,
  cp56_time : Bool,
) -> TypeDescriptor {
  { type_id, name, value_width, measurement, command, cp24_time, cp56_time }
}

///|
pub fn describe_type(type_id : Byte) -> Result[TypeDescriptor, String] {
  match type_id.to_int() {
    0x01 => Ok(descriptor(type_id, "M_SP_NA_1", 1, false, false, false, false))
    0x02 => Ok(descriptor(type_id, "M_SP_TA_1", 4, false, false, true, false))
    0x03 => Ok(descriptor(type_id, "M_DP_NA_1", 1, false, false, false, false))
    0x04 => Ok(descriptor(type_id, "M_DP_TA_1", 4, false, false, true, false))
    0x05 => Ok(descriptor(type_id, "M_ST_NA_1", 3, false, false, false, false))
    0x07 => Ok(descriptor(type_id, "M_BO_NA_1", 5, true, false, false, false))
    0x09 => Ok(descriptor(type_id, "M_ME_NA_1", 3, true, false, false, false))
    0x0B => Ok(descriptor(type_id, "M_ME_NB_1", 5, true, false, false, false))
    0x0D => Ok(descriptor(type_id, "M_ME_NC_1", 6, true, false, false, false))
    0x0F => Ok(descriptor(type_id, "M_IT_NA_1", 5, true, false, false, false))
    0x1E => Ok(descriptor(type_id, "M_SP_TB_1", 8, false, false, false, true))
    0x1F => Ok(descriptor(type_id, "M_DP_TB_1", 8, false, false, false, true))
    0x22 => Ok(descriptor(type_id, "M_ME_TD_1", 10, true, false, false, true))
    0x23 => Ok(descriptor(type_id, "M_ME_TE_1", 9, true, false, false, true))
    0x24 => Ok(descriptor(type_id, "M_ME_TF_1", 13, true, false, false, true))
    0x25 => Ok(descriptor(type_id, "M_IT_TB_1", 12, true, false, false, true))
    0x2D => Ok(descriptor(type_id, "C_SC_NA_1", 1, false, true, false, false))
    0x2E => Ok(descriptor(type_id, "C_DC_NA_1", 1, false, true, false, false))
    0x2F => Ok(descriptor(type_id, "C_RC_NA_1", 1, false, true, false, false))
    0x30 => Ok(descriptor(type_id, "C_SE_NA_1", 3, false, true, false, false))
    0x31 => Ok(descriptor(type_id, "C_SE_NB_1", 3, false, true, false, false))
    0x32 => Ok(descriptor(type_id, "C_SE_NC_1", 5, false, true, false, false))
    0x64 => Ok(descriptor(type_id, "C_IC_NA_1", 1, false, true, false, false))
    0x65 => Ok(descriptor(type_id, "C_CI_NA_1", 1, false, true, false, false))
    0x67 => Ok(descriptor(type_id, "C_CS_NA_1", 7, false, true, false, true))
    0x69 => Ok(descriptor(type_id, "C_RP_NA_1", 1, false, true, false, false))
    _ => Err("unsupported IEC 104 type identifier")
  }
}

///|
pub fn validate_cause_of_transmission(cot : Int) -> Result[Unit, String] {
  if cot < 1 || cot > 47 {
    Err("cause of transmission must be in 1..47")
  } else {
    Ok(())
  }
}
