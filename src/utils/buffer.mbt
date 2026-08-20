// MoonBit IEC 104 Utilities - Byte Buffer Operations

///|
pub struct ByteBuffer {
  mut data : Array[Byte]
  mut read_pos : Int
  mut write_pos : Int
} derive(Debug)

///|
pub fn ByteBuffer::new(capacity : Int) -> ByteBuffer {
  let cap = if capacity < 16 { 16 } else { capacity }
  let arr : Array[Byte] = Array::make(cap, b'\x00')
  { data: arr, read_pos: 0, write_pos: 0 }
}

///|
pub fn ByteBuffer::from_bytes(bytes : Array[Byte]) -> ByteBuffer {
  let len = bytes.length()
  let arr : Array[Byte] = Array::make(len, b'\x00')
  for i = 0; i < len; i = i + 1 {
    arr[i] = bytes[i]
  }
  { data: arr, read_pos: 0, write_pos: len }
}

///|
pub fn ByteBuffer::length(self : ByteBuffer) -> Int {
  self.write_pos - self.read_pos
}

///|
pub fn ByteBuffer::capacity(self : ByteBuffer) -> Int {
  self.data.length()
}

///|
pub fn ByteBuffer::clear(self : ByteBuffer) -> Unit {
  self.read_pos = 0
  self.write_pos = 0
}

///|
fn ByteBuffer::ensure_capacity(self : ByteBuffer, additional : Int) -> Unit {
  let required = self.write_pos + additional
  if required > self.data.length() {
    let mut new_cap = self.data.length() * 2
    while new_cap < required {
      new_cap = new_cap * 2
    }
    let new_arr : Array[Byte] = Array::make(new_cap, b'\x00')
    for i = 0; i < self.write_pos; i = i + 1 {
      new_arr[i] = self.data[i]
    }
    self.data = new_arr
  }
}

///|
pub fn ByteBuffer::write_uint8(self : ByteBuffer, val : Byte) -> Unit {
  self.ensure_capacity(1)
  self.data[self.write_pos] = val
  self.write_pos = self.write_pos + 1
}

///|
pub fn ByteBuffer::write_int8(self : ByteBuffer, val : Int) -> Unit {
  let b = (val & 0xFF).to_byte()
  self.write_uint8(b)
}

///|
pub fn ByteBuffer::write_uint16_le(self : ByteBuffer, val : Int) -> Unit {
  self.ensure_capacity(2)
  self.data[self.write_pos] = (val & 0xFF).to_byte()
  self.data[self.write_pos + 1] = ((val >> 8) & 0xFF).to_byte()
  self.write_pos = self.write_pos + 2
}

///|
pub fn ByteBuffer::write_uint16_be(self : ByteBuffer, val : Int) -> Unit {
  self.ensure_capacity(2)
  self.data[self.write_pos] = ((val >> 8) & 0xFF).to_byte()
  self.data[self.write_pos + 1] = (val & 0xFF).to_byte()
  self.write_pos = self.write_pos + 2
}

///|
pub fn ByteBuffer::write_uint24_le(self : ByteBuffer, val : Int) -> Unit {
  self.ensure_capacity(3)
  self.data[self.write_pos] = (val & 0xFF).to_byte()
  self.data[self.write_pos + 1] = ((val >> 8) & 0xFF).to_byte()
  self.data[self.write_pos + 2] = ((val >> 16) & 0xFF).to_byte()
  self.write_pos = self.write_pos + 3
}

///|
pub fn ByteBuffer::write_uint32_le(self : ByteBuffer, val : Int64) -> Unit {
  self.ensure_capacity(4)
  let v = val
  self.data[self.write_pos] = (v & 0xFFL).to_byte()
  self.data[self.write_pos + 1] = ((v >> 8) & 0xFFL).to_byte()
  self.data[self.write_pos + 2] = ((v >> 16) & 0xFFL).to_byte()
  self.data[self.write_pos + 3] = ((v >> 24) & 0xFFL).to_byte()
  self.write_pos = self.write_pos + 4
}

///|
pub fn ByteBuffer::write_int32_le(self : ByteBuffer, val : Int) -> Unit {
  self.write_uint32_le(val.to_int64())
}

// Convert 32-bit Float to IEEE 754 binary representation

///|
pub fn float32_to_bits(val : Double) -> Int64 {
  if val == 0.0 {
    return 0L
  }
  let sign = if val < 0.0 { 1L } else { 0L }
  let mut abs_val = if val < 0.0 { -val } else { val }
  let mut exp = 127
  if abs_val >= 1.0 {
    while abs_val >= 2.0 && exp < 254 {
      abs_val = abs_val / 2.0
      exp = exp + 1
    }
  } else {
    while abs_val < 1.0 && exp > 0 {
      abs_val = abs_val * 2.0
      exp = exp - 1
    }
  }
  let mantissa_int = ((abs_val - 1.0) * 8388608.0).to_int()
  let mantissa = mantissa_int.to_int64() & 0x7FFFFFL
  let exp_bits = exp.to_int64() & 0xFFL
  (sign << 31) | (exp_bits << 23) | mantissa
}

// Convert IEEE 754 32-bit binary representation to Double

///|
pub fn bits_to_float32(bits : Int64) -> Double {
  if bits == 0L {
    return 0.0
  }
  let sign = (bits >> 31) & 1L
  let exp = ((bits >> 23) & 0xFFL).to_int()
  let mantissa_int = (bits & 0x7FFFFFL).to_int()
  let mantissa = mantissa_int.to_double()
  if exp == 0 {
    return 0.0
  }
  let mut val = 1.0 + mantissa / 8388608.0
  let exp_diff = exp - 127
  if exp_diff > 0 {
    for i = 0; i < exp_diff; i = i + 1 {
      val = val * 2.0
    }
  } else if exp_diff < 0 {
    for i = 0; i < -exp_diff; i = i + 1 {
      val = val / 2.0
    }
  }
  if sign == 1L {
    -val
  } else {
    val
  }
}

///|
pub fn ByteBuffer::write_float32_le(self : ByteBuffer, val : Double) -> Unit {
  let bits = float32_to_bits(val)
  self.write_uint32_le(bits)
}

///|
pub fn ByteBuffer::write_bytes(self : ByteBuffer, bytes : Array[Byte]) -> Unit {
  let len = bytes.length()
  self.ensure_capacity(len)
  for i = 0; i < len; i = i + 1 {
    self.data[self.write_pos + i] = bytes[i]
  }
  self.write_pos = self.write_pos + len
}

///|
pub fn ByteBuffer::read_uint8(self : ByteBuffer) -> Result[Byte, String] {
  if self.read_pos >= self.write_pos {
    return Err("Buffer underflow: read_uint8")
  }
  let b = self.data[self.read_pos]
  self.read_pos = self.read_pos + 1
  Ok(b)
}

///|
pub fn ByteBuffer::read_int8(self : ByteBuffer) -> Result[Int, String] {
  match self.read_uint8() {
    Ok(b) => {
      let v = b.to_int()
      if v >= 128 {
        Ok(v - 256)
      } else {
        Ok(v)
      }
    }
    Err(e) => Err(e)
  }
}

///|
pub fn ByteBuffer::read_uint16_le(self : ByteBuffer) -> Result[Int, String] {
  if self.read_pos + 2 > self.write_pos {
    return Err("Buffer underflow: read_uint16_le")
  }
  let b0 = self.data[self.read_pos].to_int()
  let b1 = self.data[self.read_pos + 1].to_int()
  self.read_pos = self.read_pos + 2
  Ok(b0 | (b1 << 8))
}

///|
pub fn ByteBuffer::read_uint24_le(self : ByteBuffer) -> Result[Int, String] {
  if self.read_pos + 3 > self.write_pos {
    return Err("Buffer underflow: read_uint24_le")
  }
  let b0 = self.data[self.read_pos].to_int()
  let b1 = self.data[self.read_pos + 1].to_int()
  let b2 = self.data[self.read_pos + 2].to_int()
  self.read_pos = self.read_pos + 3
  Ok(b0 | (b1 << 8) | (b2 << 16))
}

///|
pub fn ByteBuffer::read_uint32_le(self : ByteBuffer) -> Result[Int64, String] {
  if self.read_pos + 4 > self.write_pos {
    return Err("Buffer underflow: read_uint32_le")
  }
  let b0 = self.data[self.read_pos].to_int64()
  let b1 = self.data[self.read_pos + 1].to_int64()
  let b2 = self.data[self.read_pos + 2].to_int64()
  let b3 = self.data[self.read_pos + 3].to_int64()
  self.read_pos = self.read_pos + 4
  Ok(b0 | (b1 << 8) | (b2 << 16) | (b3 << 24))
}

///|
pub fn ByteBuffer::read_int32_le(self : ByteBuffer) -> Result[Int, String] {
  match self.read_uint32_le() {
    Ok(v) => Ok(v.to_int())
    Err(e) => Err(e)
  }
}

///|
pub fn ByteBuffer::read_float32_le(self : ByteBuffer) -> Result[Double, String] {
  match self.read_uint32_le() {
    Ok(v) => Ok(bits_to_float32(v))
    Err(e) => Err(e)
  }
}

///|
pub fn ByteBuffer::read_bytes(
  self : ByteBuffer,
  count : Int,
) -> Result[Array[Byte], String] {
  if count < 0 || self.read_pos + count > self.write_pos {
    return Err("Buffer underflow: read_bytes")
  }
  let res : Array[Byte] = Array::make(count, b'\x00')
  for i = 0; i < count; i = i + 1 {
    res[i] = self.data[self.read_pos + i]
  }
  self.read_pos = self.read_pos + count
  Ok(res)
}

///|
pub fn ByteBuffer::to_array(self : ByteBuffer) -> Array[Byte] {
  let len = self.write_pos - self.read_pos
  let res : Array[Byte] = Array::make(len, b'\x00')
  for i = 0; i < len; i = i + 1 {
    res[i] = self.data[self.read_pos + i]
  }
  res
}

///|
pub fn ByteBuffer::to_hex_string(self : ByteBuffer) -> String {
  let hex_chars = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
  ]
  let mut hex = ""
  for i = self.read_pos; i < self.write_pos; i = i + 1 {
    let b = self.data[i].to_int()
    let hi = (b >> 4) & 0x0F
    let lo = b & 0x0F
    if i > self.read_pos {
      hex = hex + " "
    }
    hex = hex + hex_chars[hi].to_string() + hex_chars[lo].to_string()
  }
  hex
}
