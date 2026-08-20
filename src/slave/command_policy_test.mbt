///|
test "select before execute policy accepts matching command" {
  let policy = SelectBeforeExecute::new(5000L)
  let qual = @types.CommandQualifier::create(state=true, select_execute=true)
  assert_true(policy.select(1001, qual, 1000L) is Ok(_))
  let execute = @types.CommandQualifier::create(
    state=true,
    select_execute=false,
  )
  assert_true(policy.execute(1001, execute, 2000L) is Ok(_))
  assert_false(policy.is_selected())
}

///|
test "select before execute policy rejects wrong, expired, and duplicate commands" {
  let policy = SelectBeforeExecute::new(100L)
  let select = @types.CommandQualifier::create(select_execute=true)
  let execute = @types.CommandQualifier::create(select_execute=false)
  assert_true(policy.select(1, select, 10L) is Ok(_))
  assert_true(policy.select(1, select, 20L) is Err(_))
  assert_true(policy.execute(2, execute, 20L) is Err(_))
  assert_true(policy.execute(1, execute, 111L) is Err(_))
}
