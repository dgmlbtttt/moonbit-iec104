///|
test "byte buffer underflow is reported for every primitive reader" {
  let buffer = ByteBuffer::new(4)
  assert_true(buffer.read_uint8() is Err(_))
  assert_true(buffer.read_int8() is Err(_))
  assert_true(buffer.read_uint16_le() is Err(_))
  assert_true(buffer.read_uint24_le() is Err(_))
  assert_true(buffer.read_uint32_le() is Err(_))
  assert_true(buffer.read_int32_le() is Err(_))
  assert_true(buffer.read_float32_le() is Err(_))
  assert_true(buffer.read_bytes(-1) is Err(_))
}

///|
test "byte reader handles zero and exact-width reads" {
  let reader = ByteReader::new([])
  assert_eq(reader.remaining(), 0)
  assert_true(reader.read_bytes(0) is Ok(bytes) && bytes.length() == 0)
  let exact = ByteReader::new([b'\x01', b'\x02', b'\x03'])
  assert_eq(exact.read_u24_le().unwrap(), 0x030201)
  assert_eq(exact.remaining(), 0)
}
