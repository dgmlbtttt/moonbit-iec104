// Protocol numeric limits and explicit validation helpers.

///|
pub const MAX_IOA : Int = 0xFFFFFF

///|
pub const MAX_CASDU : Int = 0xFFFF

///|
pub const MAX_INFORMATION_OBJECTS : Int = 127

///|
pub const MAX_SEQUENCE : Int = 32767

///|
pub fn validate_sequence(sequence : Int) -> Result[Unit, String] {
  if sequence < 0 || sequence > MAX_SEQUENCE {
    Err("sequence must be in 0..32767")
  } else {
    Ok(())
  }
}

///|
pub fn validate_ioa_value(ioa : Int) -> Result[Unit, String] {
  if ioa < 0 || ioa > MAX_IOA {
    Err("IOA must be in 0..0xFFFFFF")
  } else {
    Ok(())
  }
}

///|
pub fn validate_casdu_value(casdu : Int) -> Result[Unit, String] {
  if casdu < 1 || casdu > MAX_CASDU {
    Err("CASDU must be in 1..0xFFFF")
  } else {
    Ok(())
  }
}

///|
pub fn validate_object_count_value(count : Int) -> Result[Unit, String] {
  if count < 1 || count > MAX_INFORMATION_OBJECTS {
    Err("object count must be in 1..127")
  } else {
    Ok(())
  }
}
