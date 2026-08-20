///|
test "byte ring preserves order and refuses overflow" {
  let ring = ByteRingBuffer::new(2)
  assert_true(ring.push(b'\x01'))
  assert_true(ring.push(b'\x02'))
  assert_false(ring.push(b'\x03'))
  assert_eq(ring.pop(), Some(b'\x01'))
  assert_true(ring.push(b'\x03'))
  assert_eq(ring.to_array(), [b'\x02', b'\x03'])
}
