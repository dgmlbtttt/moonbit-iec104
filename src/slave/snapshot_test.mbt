///|
test "point database snapshot captures all configured value families" {
  let db = PointDatabase::new()
  db.set_single_point(1, true)
  db.set_double_point(2, 2)
  db.set_telemetry_norm(3, 123)
  db.set_telemetry_float(4, 4.5)
  db.set_energy_counter(5, 99L)
  let snapshot = db.snapshot(1000L)
  assert_eq(snapshot.timestamp_ms(), 1000L)
  assert_eq(snapshot.entries().length(), 5)
  assert_eq(snapshot.count_kind(SnapshotKind::single_point()), 1)
  assert_eq(snapshot.count_kind(SnapshotKind::telemetry_float()), 1)
  assert_true(snapshot.find(4) is Some(_))
  assert_true(snapshot.find(99) is None)
}
