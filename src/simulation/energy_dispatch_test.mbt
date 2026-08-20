///|
test "energy dispatch clamps power and protects SOC limits" {
  let policy = EnergyDispatchPolicy::new(
    min_soc=20.0,
    max_soc=90.0,
    max_power_kw=100.0,
  ).unwrap()
  assert_eq(
    policy.set_request(DispatchMode::discharge(), 150.0, 50.0).unwrap(),
    100.0,
  )
  assert_eq(
    policy.set_request(DispatchMode::discharge(), 50.0, 20.0).unwrap(),
    0.0,
  )
  assert_eq(policy.mode(), DispatchMode::hold())
  assert_true(policy.set_request(DispatchMode::charge(), 10.0, 101.0) is Err(_))
}
