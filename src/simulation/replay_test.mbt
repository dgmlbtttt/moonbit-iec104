///|
test "replay log is bounded and produces stable signatures" {
  let log = ReplayLog::new(2)
  assert_true(
    log.append(
      ReplayStep::new(index=0, elapsed_ms=0, apdu_count=1, breaker_open=false),
    )
    is Ok(_),
  )
  assert_true(
    log.append(
      ReplayStep::new(index=1, elapsed_ms=100, apdu_count=2, breaker_open=true),
    )
    is Ok(_),
  )
  assert_true(
    log.append(
      ReplayStep::new(index=1, elapsed_ms=200, apdu_count=3, breaker_open=false),
    )
    is Err(_),
  )
  assert_true(
    log.append(
      ReplayStep::new(index=2, elapsed_ms=200, apdu_count=1, breaker_open=false),
    )
    is Ok(_),
  )
  assert_eq(log.len(), 2)
  assert_true(log.signature().contains("2:1:false"))
}
