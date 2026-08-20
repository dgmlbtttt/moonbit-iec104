// Small bounds-checked reader for protocol payloads.

///|
pub struct ByteReader {
  bytes : Array[Byte]
  mut offset : Int
} derive(Debug, Eq)

///|
pub fn ByteReader::new(bytes : Array[Byte]) -> ByteReader {
  { bytes, offset: 0 }
}

///|
pub fn ByteReader::position(self : ByteReader) -> Int {
  self.offset
}

///|
pub fn ByteReader::remaining(self : ByteReader) -> Int {
  self.bytes.length() - self.offset
}

///|
pub fn ByteReader::is_empty(self : ByteReader) -> Bool {
  self.offset >= self.bytes.length()
}

///|
fn ByteReader::require(self : ByteReader, count : Int) -> Result[Unit, String] {
  if count < 0 {
    return Err("reader count cannot be negative")
  }
  if self.offset + count > self.bytes.length() {
    Err("reader buffer underflow")
  } else {
    Ok(())
  }
}

///|
pub fn ByteReader::peek_u8(self : ByteReader) -> Result[Byte, String] {
  match self.require(1) {
    Err(e) => Err(e)
    Ok(_) => Ok(self.bytes[self.offset])
  }
}

///|
pub fn ByteReader::read_u8(self : ByteReader) -> Result[Byte, String] {
  match self.require(1) {
    Err(e) => Err(e)
    Ok(_) => {
      let value = self.bytes[self.offset]
      self.offset += 1
      Ok(value)
    }
  }
}

///|
pub fn ByteReader::read_i8(self : ByteReader) -> Result[Int, String] {
  match self.read_u8() {
    Err(e) => Err(e)
    Ok(value) => {
      let v = value.to_int()
      Ok(if v >= 128 { v - 256 } else { v })
    }
  }
}

///|
pub fn ByteReader::read_u16_le(self : ByteReader) -> Result[Int, String] {
  match self.require(2) {
    Err(e) => Err(e)
    Ok(_) => {
      let a = self.bytes[self.offset].to_int()
      let b = self.bytes[self.offset + 1].to_int()
      self.offset += 2
      Ok(a | (b << 8))
    }
  }
}

///|
pub fn ByteReader::read_u24_le(self : ByteReader) -> Result[Int, String] {
  match self.require(3) {
    Err(e) => Err(e)
    Ok(_) => {
      let a = self.bytes[self.offset].to_int()
      let b = self.bytes[self.offset + 1].to_int()
      let c = self.bytes[self.offset + 2].to_int()
      self.offset += 3
      Ok(a | (b << 8) | (c << 16))
    }
  }
}

///|
pub fn ByteReader::read_bytes(
  self : ByteReader,
  count : Int,
) -> Result[Array[Byte], String] {
  match self.require(count) {
    Err(e) => Err(e)
    Ok(_) => {
      let result : Array[Byte] = Array::make(count, b'\x00')
      for i = 0; i < count; i = i + 1 {
        result[i] = self.bytes[self.offset + i]
      }
      self.offset += count
      Ok(result)
    }
  }
}

///|
pub fn ByteReader::skip(self : ByteReader, count : Int) -> Result[Unit, String] {
  match self.require(count) {
    Err(e) => Err(e)
    Ok(_) => {
      self.offset += count
      Ok(())
    }
  }
}
