///|
test "retry budget never exceeds its limit" {
  let budget = RetryBudget::new(2)
  assert_true(budget.take())
  assert_true(budget.take())
  assert_false(budget.take())
  assert_true(budget.exhausted())
  budget.reset()
  assert_eq(budget.remaining(), 2)
}
