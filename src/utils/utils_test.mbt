// MoonBit IEC 104 Utilities - Unit Tests

///|
test "buffer read write uint8 and int8" {
  let buf = ByteBuffer::new(16)
  buf.write_uint8(b'\x42')
  buf.write_int8(-15)
  assert_eq(buf.length(), 2)

  let b0 = buf.read_uint8().unwrap()
  assert_eq(b0, b'\x42')

  let i1 = buf.read_int8().unwrap()
  assert_eq(i1, -15)
}

///|
test "buffer read write uint16_le and uint32_le" {
  let buf = ByteBuffer::new(32)
  buf.write_uint16_le(0x1234)
  buf.write_uint32_le(0x87654321L)
  assert_eq(buf.length(), 6)

  let v16 = buf.read_uint16_le().unwrap()
  assert_eq(v16, 0x1234)

  let v32 = buf.read_uint32_le().unwrap()
  assert_eq(v32, 0x87654321L)
}

///|
test "buffer read write float32_le" {
  let buf = ByteBuffer::new(16)
  let val : Double = 123.45
  buf.write_float32_le(val)
  let read_val = buf.read_float32_le().unwrap()
  let diff = (read_val - val).abs()
  assert_true(diff < 0.01)
}

///|
test "bit operations set and get" {
  let mut b = b'\x00'
  b = set_bit(b, 3, true)
  assert_eq(b, b'\x08')
  assert_true(get_bit(b, 3))
  assert_false(get_bit(b, 2))

  let field = extract_field(b'\x3C', 2, 4) // 00111100 -> bits 2..5 = 1111 = 15
  assert_eq(field, 15)
}

///|
test "checksum calculations" {
  let data : Array[Byte] = [b'\x01', b'\x02', b'\x03', b'\x04']
  let sum = calculate_sum8(data, 0, 4)
  assert_eq(sum, b'\x0A')

  let xor_val = calculate_xor8(data, 0, 4)
  assert_eq(xor_val, b'\x04')
}
