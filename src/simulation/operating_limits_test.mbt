///|
test "operating limits evaluate safe and unsafe telemetry" {
  let limits = OperatingLimits::new(
    min_voltage_kv=100.0,
    max_voltage_kv=120.0,
    max_current_a=500.0,
    min_frequency_hz=49.5,
    max_frequency_hz=50.5,
  ).unwrap()
  assert_true(limits.evaluate(110.0, 200.0, 50.0).is_safe())
  assert_false(limits.evaluate(90.0, 200.0, 50.0).is_safe())
  assert_false(limits.evaluate(110.0, 600.0, 50.0).is_safe())
  assert_true(
    OperatingLimits::new(
      min_voltage_kv=120.0,
      max_voltage_kv=110.0,
      max_current_a=1.0,
      min_frequency_hz=49.0,
      max_frequency_hz=50.0,
    )
    is Err(_),
  )
}
