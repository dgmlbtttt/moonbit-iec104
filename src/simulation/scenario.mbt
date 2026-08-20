// Deterministic scenario orchestration for repeatable acceptance demonstrations.

///|
pub enum ScenarioEventKind {
  Fault
  Recovery
} derive(Debug, Eq)

///|
pub struct ScenarioEvent {
  step : Int
  elapsed_ms : Int
  kind : ScenarioEventKind
  apdu_count : Int
} derive(Debug, Eq)

///|
pub fn ScenarioEvent::step(self : ScenarioEvent) -> Int {
  self.step
}

///|
pub fn ScenarioEvent::elapsed_ms(self : ScenarioEvent) -> Int {
  self.elapsed_ms
}

///|
pub fn ScenarioEvent::kind(self : ScenarioEvent) -> ScenarioEventKind {
  self.kind
}

///|
pub fn ScenarioEvent::apdu_count(self : ScenarioEvent) -> Int {
  self.apdu_count
}

///|
pub struct ScenarioConfig {
  step_ms : Int
  steps : Int
  fault_step : Int
  recovery_step : Int
} derive(Debug, Eq)

///|
pub fn ScenarioConfig::create(
  step_ms~ : Int,
  steps~ : Int,
  fault_step~ : Int,
  recovery_step~ : Int,
) -> Result[ScenarioConfig, String] {
  if step_ms < 1 {
    return Err("scenario step_ms must be positive")
  }
  if steps < 1 {
    return Err("scenario steps must be positive")
  }
  if fault_step < 0 || fault_step >= steps {
    return Err("scenario fault_step must be inside the run")
  }
  if recovery_step <= fault_step || recovery_step >= steps {
    return Err("scenario recovery_step must follow fault_step inside the run")
  }
  Ok({ step_ms, steps, fault_step, recovery_step })
}

///|
pub fn ScenarioConfig::step_ms(self : ScenarioConfig) -> Int {
  self.step_ms
}

///|
pub fn ScenarioConfig::steps(self : ScenarioConfig) -> Int {
  self.steps
}

///|
pub struct ScenarioReport {
  steps : Int
  events : Array[ScenarioEvent]
  final_breaker_open : Bool
} derive(Debug, Eq)

///|
pub fn ScenarioReport::steps(self : ScenarioReport) -> Int {
  self.steps
}

///|
pub fn ScenarioReport::events(self : ScenarioReport) -> Array[ScenarioEvent] {
  self.events
}

///|
pub fn ScenarioReport::final_breaker_open(self : ScenarioReport) -> Bool {
  self.final_breaker_open
}

///|
pub fn ScenarioReport::signature(self : ScenarioReport) -> String {
  let result = "steps=" + self.steps.to_string()
  let mut signature = result
  for event in self.events {
    let kind = match event.kind {
      Fault => "fault"
      Recovery => "recovery"
    }
    signature = signature +
      ";" +
      kind +
      "@" +
      event.step.to_string() +
      ":" +
      event.apdu_count.to_string()
  }
  signature + ";open=" + self.final_breaker_open.to_string()
}

///|
pub struct SubstationScenario {
  config : ScenarioConfig
  model : SubstationModel
} derive(Debug, Eq)

///|
pub fn SubstationScenario::new(config : ScenarioConfig) -> SubstationScenario {
  let model = SubstationModel::create(
    station_name="Scenario-110kV",
    casdu_addr=1,
  )
  model.activate_connection()
  { config, model }
}

///|
pub fn SubstationScenario::run(self : SubstationScenario) -> ScenarioReport {
  let events : Array[ScenarioEvent] = []
  let mut fault_active = false
  let mut elapsed = 0
  for step = 0; step < self.config.steps; step = step + 1 {
    if step == self.config.fault_step {
      let apdus = self.model.trigger_bay_fault(1)
      events.push({
        step,
        elapsed_ms: elapsed,
        kind: Fault,
        apdu_count: apdus.length(),
      })
      fault_active = true
    }
    if step == self.config.recovery_step {
      let _ = self.model.clear_bay_fault(1)
      let apdus = self.model.step(self.config.step_ms)
      events.push({
        step,
        elapsed_ms: elapsed,
        kind: Recovery,
        apdu_count: apdus.length(),
      })
      fault_active = false
    } else {
      let _ = self.model.step(self.config.step_ms)
    }
    elapsed = elapsed + self.config.step_ms
  }
  { steps: self.config.steps, events, final_breaker_open: fault_active }
}
