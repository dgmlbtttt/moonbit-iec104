///|
test "scenario produces repeatable fault and recovery events" {
  let config = ScenarioConfig::create(
    step_ms=1000,
    steps=5,
    fault_step=2,
    recovery_step=4,
  ).unwrap()
  let first = SubstationScenario::new(config)
  let first_report = first.run()
  assert_eq(first_report.steps(), 5)
  assert_eq(first_report.events().length(), 2)
  assert_true(first_report.signature().contains("fault"))
  assert_true(first_report.signature().contains("recovery"))

  let second = SubstationScenario::new(config).run()
  assert_eq(first_report.signature(), second.signature())
  assert_false(first_report.final_breaker_open())
}

///|
test "scenario configuration rejects impossible schedules" {
  assert_true(
    ScenarioConfig::create(step_ms=0, steps=1, fault_step=0, recovery_step=0)
    is Err(_),
  )
  assert_true(
    ScenarioConfig::create(step_ms=100, steps=2, fault_step=3, recovery_step=1)
    is Err(_),
  )
  assert_true(
    ScenarioConfig::create(step_ms=100, steps=4, fault_step=3, recovery_step=2)
    is Err(_),
  )
}
