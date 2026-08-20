// Explicit codec registry for adapters that negotiate supported ASDU types.

///|
pub struct CodecRegistry {
  mut type_ids : Array[Byte]
  max_types : Int
} derive(Debug, Eq)

///|
pub fn CodecRegistry::new(max_types : Int) -> CodecRegistry {
  { type_ids: [], max_types: if max_types < 1 { 1 } else { max_types } }
}

///|
pub fn CodecRegistry::len(self : CodecRegistry) -> Int {
  self.type_ids.length()
}

///|
pub fn CodecRegistry::contains(self : CodecRegistry, type_id : Byte) -> Bool {
  for value in self.type_ids {
    if value == type_id {
      return true
    }
  }
  false
}

///|
pub fn CodecRegistry::register(
  self : CodecRegistry,
  type_id : Byte,
) -> Result[Unit, String] {
  if @types.describe_type(type_id) is Err(_) {
    return Err("cannot register unsupported ASDU type")
  }
  if self.contains(type_id) {
    return Ok(())
  }
  if self.type_ids.length() >= self.max_types {
    return Err("codec registry capacity reached")
  }
  self.type_ids.push(type_id)
  Ok(())
}

///|
pub fn CodecRegistry::remove(self : CodecRegistry, type_id : Byte) -> Bool {
  let remaining : Array[Byte] = []
  let mut removed = false
  for value in self.type_ids {
    if value == type_id {
      removed = true
    } else {
      remaining.push(value)
    }
  }
  self.type_ids = remaining
  removed
}

///|
pub fn CodecRegistry::supported_measurements(
  self : CodecRegistry,
) -> Array[Byte] {
  let result : Array[Byte] = []
  for type_id in self.type_ids {
    match @types.describe_type(type_id) {
      Ok(desc) => if desc.is_measurement() { result.push(type_id) } else { () }
      Err(_) => ()
    }
  }
  result
}

///|
pub fn CodecRegistry::supported_commands(self : CodecRegistry) -> Array[Byte] {
  let result : Array[Byte] = []
  for type_id in self.type_ids {
    match @types.describe_type(type_id) {
      Ok(desc) => if desc.is_command() { result.push(type_id) } else { () }
      Err(_) => ()
    }
  }
  result
}
