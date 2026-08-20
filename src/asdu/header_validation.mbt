///|
pub fn ASDUHeader::validate(self : ASDUHeader) -> Result[Unit, String] {
  if self.num_objects < 1 || self.num_objects > 127 {
    return Err("ASDU object count must be in 1..127")
  }
  if self.cot < 1 || self.cot > 47 {
    return Err("ASDU cause of transmission must be in 1..47")
  }
  if self.oa < 0 || self.oa > 255 {
    return Err("ASDU originator address must be in 0..255")
  }
  match self.casdu.validate() {
    Ok(_) => Ok(())
    Err(e) => Err(e)
  }
}

///|
pub fn ASDUHeader::encode_checked(
  self : ASDUHeader,
) -> Result[Array[Byte], String] {
  match self.validate() {
    Ok(_) => Ok(self.encode())
    Err(e) => Err(e)
  }
}
