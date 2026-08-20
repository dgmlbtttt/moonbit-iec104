///|
test "timer scheduler expires due protocol timers once" {
  let timers = ProtocolTimerScheduler::new(t1_ms=100, t2_ms=200, t3_ms=300)
  assert_true(timers.arm(TimerKind::t1(), 1000L) is Ok(_))
  assert_true(timers.arm(TimerKind::t2(), 1050L) is Ok(_))
  assert_eq(timers.expired_at(1099L).unwrap().length(), 0)
  let expired = timers.expired_at(1100L).unwrap()
  assert_eq(expired.length(), 1)
  assert_eq(expired[0], TimerKind::t1())
  assert_eq(timers.expired_at(1100L).unwrap().length(), 0)
}

///|
test "timer scheduler rejects time reversal and duplicate active timers" {
  let timers = ProtocolTimerScheduler::new(t1_ms=10, t2_ms=20, t3_ms=30)
  assert_true(timers.arm(TimerKind::t3(), 100L) is Ok(_))
  assert_true(timers.arm(TimerKind::t3(), 101L) is Err(_))
  assert_true(timers.expired_at(99L) is Err(_))
}
