///|
test "telemetry store tracks quality and stale values" {
  let store = TelemetryStore::new(10000L)
  assert_true(store.update(4001, 220.5, TelemetryQuality::good(), 1000L))
  assert_true(store.update(4002, 50.0, TelemetryQuality::invalid(), 1000L))
  assert_eq(store.len(), 2)
  assert_eq(store.get(4001).unwrap().value(), 220.5)
  assert_eq(store.count_quality(TelemetryQuality::invalid()), 1)
  assert_eq(store.stale_before(12000L).length(), 2)
  assert_eq(store.stale_before(1000L).length(), 0)
  assert_false(store.update(4001, 221.0, TelemetryQuality::good(), 900L))
  assert_eq(store.get(4001).unwrap().value(), 220.5)
}
