// Small deterministic action scheduler used by scenario and integration tests.

///|
pub enum ScheduledAction {
  Fault(Int, Int)
  Recovery(Int, Int)
} derive(Debug, Eq)

///|
pub struct DispatchResult {
  actions_executed : Int
  apdu_count : Int
  rejected_actions : Int
} derive(Debug, Eq)

///|
pub fn DispatchResult::actions_executed(self : DispatchResult) -> Int {
  self.actions_executed
}

///|
pub fn DispatchResult::apdu_count(self : DispatchResult) -> Int {
  self.apdu_count
}

///|
pub fn DispatchResult::rejected_actions(self : DispatchResult) -> Int {
  self.rejected_actions
}

///|
pub struct DispatchPlan {
  actions : Array[ScheduledAction]
  mut cursor : Int
} derive(Debug, Eq)

///|
pub fn DispatchPlan::new() -> DispatchPlan {
  { actions: [], cursor: 0 }
}

///|
pub fn DispatchPlan::len(self : DispatchPlan) -> Int {
  self.actions.length()
}

///|
pub fn DispatchPlan::pending(self : DispatchPlan) -> Int {
  self.actions.length() - self.cursor
}

///|
fn action_step(action : ScheduledAction) -> Int {
  match action {
    Fault(step, _) => step
    Recovery(step, _) => step
  }
}

///|
fn action_bay(action : ScheduledAction) -> Int {
  match action {
    Fault(_, bay) => bay
    Recovery(_, bay) => bay
  }
}

///|
pub fn DispatchPlan::schedule_fault(
  self : DispatchPlan,
  step~ : Int,
  bay_index~ : Int,
) -> Result[Unit, String] {
  self.schedule(Fault(step, bay_index))
}

///|
pub fn DispatchPlan::schedule_recovery(
  self : DispatchPlan,
  step~ : Int,
  bay_index~ : Int,
) -> Result[Unit, String] {
  self.schedule(Recovery(step, bay_index))
}

///|
fn DispatchPlan::schedule(
  self : DispatchPlan,
  action : ScheduledAction,
) -> Result[Unit, String] {
  if action_step(action) < 0 ||
    action_bay(action) < 0 ||
    action_bay(action) >= 3 {
    return Err("dispatch action is outside model bounds")
  }
  if self.actions.length() > 0 &&
    action_step(action) <= action_step(self.actions[self.actions.length() - 1]) {
    return Err(
      "dispatch actions must be scheduled in strictly increasing steps",
    )
  }
  self.actions.push(action)
  Ok(())
}

///|
pub fn DispatchPlan::run_step(
  self : DispatchPlan,
  model : SubstationModel,
  step : Int,
) -> DispatchResult {
  let mut executed = 0
  let mut apdu_count = 0
  let mut rejected = 0
  while self.cursor < self.actions.length() &&
        action_step(self.actions[self.cursor]) == step {
    let action = self.actions[self.cursor]
    let bay = action_bay(action)
    match action {
      Fault(_, _) => {
        let frames = model.trigger_bay_fault(bay)
        apdu_count = apdu_count + frames.length()
      }
      Recovery(_, _) =>
        if model.clear_bay_fault(bay) {
          ()
        } else {
          rejected = rejected + 1
        }
    }
    executed = executed + 1
    self.cursor = self.cursor + 1
  }
  { actions_executed: executed, apdu_count, rejected_actions: rejected }
}
