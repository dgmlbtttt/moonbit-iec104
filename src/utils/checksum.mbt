// MoonBit IEC 104 Utilities - Frame Checksum and Verification Functions

///|
pub fn calculate_sum8(data : Array[Byte], start : Int, length : Int) -> Byte {
  let mut sum = 0
  let end_pos = start + length
  for i = start; i < end_pos; i = i + 1 {
    sum = (sum + data[i].to_int()) & 0xFF
  }
  sum.to_byte()
}

///|
pub fn calculate_xor8(data : Array[Byte], start : Int, length : Int) -> Byte {
  let mut xor_val = 0
  let end_pos = start + length
  for i = start; i < end_pos; i = i + 1 {
    xor_val = xor_val ^ data[i].to_int()
  }
  xor_val.to_byte()
}

///|
pub fn calculate_crc16_modbus(
  data : Array[Byte],
  start : Int,
  length : Int,
) -> Int {
  let mut crc = 0xFFFF
  let end_pos = start + length
  for i = start; i < end_pos; i = i + 1 {
    crc = crc ^ data[i].to_int()
    for _j = 0; _j < 8; _j = _j + 1 {
      if (crc & 1) != 0 {
        crc = (crc >> 1) ^ 0xA001
      } else {
        crc = crc >> 1
      }
    }
  }
  crc & 0xFFFF
}

///|
pub fn verify_checksum_sum8(data : Array[Byte], expected : Byte) -> Bool {
  let actual = calculate_sum8(data, 0, data.length())
  actual == expected
}

///|
pub fn format_sequence_no(seq_no : Int) -> String {
  let seq = seq_no & 0x7FFF
  seq.to_string()
}
