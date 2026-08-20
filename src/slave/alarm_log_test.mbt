///|
test "alarm log bounds history and acknowledges records" {
  let log = AlarmLog::new(2)
  let id = log.record(1001, AlarmSeverity::critical(), "trip", 10L).unwrap()
  let _ = log.record(1002, AlarmSeverity::warning(), "voltage", 20L)
  let _ = log.record(1003, AlarmSeverity::info(), "restored", 30L)
  assert_eq(log.len(), 2)
  assert_false(log.acknowledge(id))
  assert_eq(log.unacknowledged().length(), 2)
  assert_true(log.acknowledge(log.records()[0].id()))
  assert_eq(log.unacknowledged().length(), 1)
}
