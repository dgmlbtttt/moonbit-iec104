// MoonBit IEC 104 Utilities - Bitwise Manipulation and Conversions

///|
pub fn get_bit(byte_val : Byte, bit_pos : Int) -> Bool {
  if bit_pos < 0 || bit_pos > 7 {
    false
  } else {
    ((byte_val.to_int() >> bit_pos) & 1) != 0
  }
}

///|
pub fn set_bit(byte_val : Byte, bit_pos : Int, value : Bool) -> Byte {
  if bit_pos < 0 || bit_pos > 7 {
    byte_val
  } else {
    let mask = 1 << bit_pos
    if value {
      (byte_val.to_int() | mask).to_byte()
    } else {
      (byte_val.to_int() & (mask ^ 0xFF)).to_byte()
    }
  }
}

///|
pub fn extract_field(byte_val : Byte, offset : Int, length : Int) -> Int {
  if offset < 0 || length <= 0 || offset + length > 8 {
    0
  } else {
    let mask = (1 << length) - 1
    (byte_val.to_int() >> offset) & mask
  }
}

///|
pub fn pack_field(
  byte_val : Byte,
  offset : Int,
  length : Int,
  field_val : Int,
) -> Byte {
  if offset < 0 || length <= 0 || offset + length > 8 {
    byte_val
  } else {
    let mask = ((1 << length) - 1) << offset
    let cleared = byte_val.to_int() & (mask ^ 0xFF)
    let packed = cleared | ((field_val << offset) & mask)
    packed.to_byte()
  }
}

///|
pub fn parity_bit(byte_val : Byte) -> Int {
  let mut count = 0
  let mut v = byte_val.to_int()
  while v > 0 {
    count = count + (v & 1)
    v = v >> 1
  }
  count % 2
}

///|
pub fn byte_to_hex(b : Byte) -> String {
  let hex_chars = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
  ]
  let val = b.to_int()
  let hi = (val >> 4) & 0x0F
  let lo = val & 0x0F
  hex_chars[hi].to_string() + hex_chars[lo].to_string()
}

///|
pub fn bytes_to_hex_string(bytes : Array[Byte]) -> String {
  let mut s = ""
  for i = 0; i < bytes.length(); i = i + 1 {
    if i > 0 {
      s = s + " "
    }
    s = s + byte_to_hex(bytes[i])
  }
  s
}

///|
pub fn hex_char_to_val(ch : Char) -> Int {
  match ch {
    '0' => 0
    '1' => 1
    '2' => 2
    '3' => 3
    '4' => 4
    '5' => 5
    '6' => 6
    '7' => 7
    '8' => 8
    '9' => 9
    'A' | 'a' => 10
    'B' | 'b' => 11
    'C' | 'c' => 12
    'D' | 'd' => 13
    'E' | 'e' => 14
    'F' | 'f' => 15
    _ => 0
  }
}

///|
pub fn clamp_int(val : Int, min_val : Int, max_val : Int) -> Int {
  if val < min_val {
    min_val
  } else if val > max_val {
    max_val
  } else {
    val
  }
}

///|
pub fn clamp_float(val : Float, min_val : Float, max_val : Float) -> Float {
  if val < min_val {
    min_val
  } else if val > max_val {
    max_val
  } else {
    val
  }
}
