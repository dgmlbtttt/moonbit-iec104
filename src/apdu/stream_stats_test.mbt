///|
test "stream statistics counts accepted and failed chunks" {
  let stats = StreamStatistics::new()
  assert_true(stats.observe_chunk(6, 1, false))
  assert_true(stats.observe_chunk(10, 2, true))
  assert_false(stats.observe_chunk(-1, 0, false))
  assert_eq(stats.chunks(), 2)
  assert_eq(stats.bytes(), 16)
  assert_eq(stats.frames(), 3)
  assert_eq(stats.errors(), 2)
}
