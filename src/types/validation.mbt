///|
pub fn IOA::validate(self : IOA) -> Result[Unit, String] {
  if self.value < 0 || self.value > 0xFFFFFF {
    Err("IOA must be in 0..0xFFFFFF")
  } else {
    Ok(())
  }
}

///|
pub fn IOA::try_new(addr : Int) -> Result[IOA, String] {
  let result = IOA::{ value: addr }
  match result.validate() {
    Ok(_) => Ok(result)
    Err(e) => Err(e)
  }
}

///|
pub fn CASDU::validate(self : CASDU) -> Result[Unit, String] {
  if self.address == 0 || self.address > 0xFFFF {
    Err("CASDU must be in 1..0xFFFF")
  } else {
    Ok(())
  }
}

///|
pub fn CASDU::try_new(addr : Int) -> Result[CASDU, String] {
  let result = CASDU::{ address: addr }
  match result.validate() {
    Ok(_) => Ok(result)
    Err(e) => Err(e)
  }
}

///|
pub fn CommandQualifier::validate(
  self : CommandQualifier,
) -> Result[Unit, String] {
  if self.pulse_duration < 0 || self.pulse_duration > 31 {
    Err("command qualifier pulse_duration must be in 0..31")
  } else {
    Ok(())
  }
}

///|
pub fn CommandQualifier::encode_checked(
  self : CommandQualifier,
) -> Result[Byte, String] {
  match self.validate() {
    Ok(_) => Ok(self.to_byte())
    Err(e) => Err(e)
  }
}
