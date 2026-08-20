///|
test "codec registry tracks negotiated measurements and commands" {
  let registry = CodecRegistry::new(2)
  assert_true(registry.register(@types.TYPE_M_ME_TF_1) is Ok(_))
  assert_true(registry.register(@types.TYPE_C_SC_NA_1) is Ok(_))
  assert_true(registry.register(@types.TYPE_M_SP_NA_1) is Err(_))
  assert_eq(registry.supported_measurements().length(), 1)
  assert_eq(registry.supported_commands().length(), 1)
  assert_true(registry.remove(@types.TYPE_C_SC_NA_1))
  assert_false(registry.contains(@types.TYPE_C_SC_NA_1))
}
