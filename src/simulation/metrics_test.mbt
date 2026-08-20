///|
test "running metrics tracks extrema and faults" {
  let metrics = RunningMetrics::new()
  metrics.observe(10.0, false)
  metrics.observe(4.0, true)
  metrics.observe(8.0, false)
  assert_eq(metrics.samples(), 3)
  assert_eq(metrics.minimum(), 4.0)
  assert_eq(metrics.maximum(), 10.0)
  assert_eq(metrics.average(), 22.0 / 3.0)
  assert_eq(metrics.faults(), 1)
}
