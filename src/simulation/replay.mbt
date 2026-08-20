// Compact deterministic replay log for simulation and protocol demonstrations.

///|
pub struct ReplayStep {
  index : Int
  elapsed_ms : Int
  apdu_count : Int
  breaker_open : Bool
} derive(Debug, Eq)

///|
pub fn ReplayStep::new(
  index~ : Int,
  elapsed_ms~ : Int,
  apdu_count~ : Int,
  breaker_open~ : Bool,
) -> ReplayStep {
  { index, elapsed_ms, apdu_count, breaker_open }
}

///|
pub fn ReplayStep::index(self : ReplayStep) -> Int {
  self.index
}

///|
pub fn ReplayStep::elapsed_ms(self : ReplayStep) -> Int {
  self.elapsed_ms
}

///|
pub fn ReplayStep::apdu_count(self : ReplayStep) -> Int {
  self.apdu_count
}

///|
pub fn ReplayStep::breaker_open(self : ReplayStep) -> Bool {
  self.breaker_open
}

///|
pub struct ReplayLog {
  capacity : Int
  mut steps : Array[ReplayStep]
} derive(Debug, Eq)

///|
pub fn ReplayLog::new(capacity : Int) -> ReplayLog {
  { capacity: if capacity < 1 { 1 } else { capacity }, steps: [] }
}

///|
pub fn ReplayLog::len(self : ReplayLog) -> Int {
  self.steps.length()
}

///|
pub fn ReplayLog::steps(self : ReplayLog) -> Array[ReplayStep] {
  self.steps
}

///|
pub fn ReplayLog::append(
  self : ReplayLog,
  step : ReplayStep,
) -> Result[Unit, String] {
  if step.index() < 0 || step.elapsed_ms() < 0 || step.apdu_count() < 0 {
    return Err("invalid replay step")
  }
  if self.steps.length() > 0 &&
    step.index() <= self.steps[self.steps.length() - 1].index() {
    return Err("replay step indexes must increase")
  }
  if self.steps.length() >= self.capacity {
    let remaining : Array[ReplayStep] = []
    for i = 1; i < self.steps.length(); i = i + 1 {
      remaining.push(self.steps[i])
    }
    self.steps = remaining
  }
  self.steps.push(step)
  Ok(())
}

///|
pub fn ReplayLog::signature(self : ReplayLog) -> String {
  let mut result = ""
  for step in self.steps {
    result = result +
      step.index().to_string() +
      ":" +
      step.apdu_count().to_string() +
      ":" +
      step.breaker_open().to_string() +
      ";"
  }
  result
}
