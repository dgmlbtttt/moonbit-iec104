///|
test "dispatch plan executes ordered bay actions once" {
  let plan = DispatchPlan::new()
  assert_true(plan.schedule_fault(step=2, bay_index=1) is Ok(_))
  assert_true(plan.schedule_recovery(step=4, bay_index=1) is Ok(_))
  assert_true(plan.schedule_fault(step=2, bay_index=0) is Err(_))
  let model = SubstationModel::create(casdu_addr=1)
  let mut actions = 0
  for step = 0; step < 5; step = step + 1 {
    actions = actions + plan.run_step(model, step).actions_executed()
  }
  assert_eq(actions, 2)
  assert_eq(plan.pending(), 0)
  assert_false(model.bays()[1].is_faulted())
}

///|
test "dispatch plan rejects invalid steps and bay indexes" {
  let plan = DispatchPlan::new()
  assert_true(plan.schedule_fault(step=-1, bay_index=0) is Err(_))
  assert_true(plan.schedule_fault(step=1, bay_index=-1) is Err(_))
  assert_true(plan.schedule_recovery(step=1, bay_index=99) is Err(_))
}
