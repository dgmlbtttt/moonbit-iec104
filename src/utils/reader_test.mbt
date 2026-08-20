///|
test "byte reader provides checked sequential access" {
  let reader = ByteReader::new([b'\x01', b'\x02', b'\x03', b'\x04'])
  assert_eq(reader.position(), 0)
  assert_eq(reader.read_u8().unwrap(), b'\x01')
  assert_eq(reader.read_u16_le().unwrap(), 0x0302)
  assert_eq(reader.remaining(), 1)
  assert_true(reader.read_bytes(2) is Err(_))
  assert_eq(reader.peek_u8().unwrap(), b'\x04')
  assert_eq(reader.read_u8().unwrap(), b'\x04')
  assert_true(reader.read_u8() is Err(_))
}

///|
test "byte reader rejects invalid cursor operations" {
  let reader = ByteReader::new([b'\x01'])
  assert_true(reader.skip(-1) is Err(_))
  assert_true(reader.read_u24_le() is Err(_))
}
