// MoonBit IEC 104 - Protocol Timer Unit Tests

///|
test "Timer manager t1 timeout trigger" {
  let cfg = TimerConfig::create(t1=2, t2=5, t3=10)
  let mgr = ProtocolTimerManager::new(config=cfg)

  mgr.start_t1()
  let exp1 = mgr.tick(1000)
  assert_eq(exp1.length(), 0)

  let exp2 = mgr.tick(1100)
  assert_eq(exp2.length(), 1)
  assert_eq(exp2[0], TimerExpired::expired_t1())
}

///|
test "Timer manager t3 keepalive idle trigger" {
  let cfg = TimerConfig::create(t1=10, t2=10, t3=3)
  let mgr = ProtocolTimerManager::new(config=cfg)

  let exp = mgr.tick(3100)
  assert_eq(exp.length(), 1)
  assert_eq(exp[0], TimerExpired::expired_t3())
}
