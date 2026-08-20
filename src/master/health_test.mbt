///|
test "link health rejects clock rollback and counts protocol errors" {
  let health = LinkHealth::new()
  assert_true(health.record_sent(10L))
  assert_true(health.record_received(20L))
  assert_false(health.record_sent(19L))
  health.record_error()
  assert_eq(health.sent_frames(), 1)
  assert_eq(health.received_frames(), 1)
  assert_false(health.healthy())
}
