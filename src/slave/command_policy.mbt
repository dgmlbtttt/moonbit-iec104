// Select-before-execute command policy used by remote control handlers.

///|
pub enum CommandDecision {
  Selected
  Executed
} derive(Debug, Eq)

///|
pub struct SelectBeforeExecute {
  timeout_ms : Int64
  mut selected_ioa : Int?
  mut selected_state : Bool
  mut selected_at : Int64
} derive(Debug, Eq)

///|
pub fn SelectBeforeExecute::new(timeout_ms : Int64) -> SelectBeforeExecute {
  {
    timeout_ms: if timeout_ms < 1L {
      1L
    } else {
      timeout_ms
    },
    selected_ioa: None,
    selected_state: false,
    selected_at: 0L,
  }
}

///|
pub fn SelectBeforeExecute::is_selected(self : SelectBeforeExecute) -> Bool {
  self.selected_ioa is Some(_)
}

///|
pub fn SelectBeforeExecute::selected_ioa(self : SelectBeforeExecute) -> Int? {
  self.selected_ioa
}

///|
fn SelectBeforeExecute::valid_time(
  self : SelectBeforeExecute,
  now_ms : Int64,
) -> Bool {
  now_ms >= self.selected_at && now_ms - self.selected_at <= self.timeout_ms
}

///|
pub fn SelectBeforeExecute::select(
  self : SelectBeforeExecute,
  ioa : Int,
  qualifier : @types.CommandQualifier,
  now_ms : Int64,
) -> Result[CommandDecision, String] {
  if ioa < 0 || now_ms < 0L {
    return Err("invalid command address or time")
  }
  if !qualifier.select_execute() {
    return Err("selection requires select_execute bit")
  }
  if self.selected_ioa is Some(_) && self.valid_time(now_ms) {
    return Err("another command is already selected")
  }
  self.selected_ioa = Some(ioa)
  self.selected_state = qualifier.state()
  self.selected_at = now_ms
  Ok(Selected)
}

///|
pub fn SelectBeforeExecute::execute(
  self : SelectBeforeExecute,
  ioa : Int,
  qualifier : @types.CommandQualifier,
  now_ms : Int64,
) -> Result[CommandDecision, String] {
  if qualifier.select_execute() {
    return Err("execution requires select_execute cleared")
  }
  if !self.valid_time(now_ms) {
    self.clear()
    return Err("selected command has expired")
  }
  match self.selected_ioa {
    Some(selected) =>
      if selected != ioa || self.selected_state != qualifier.state() {
        Err("execution does not match selected command")
      } else {
        self.clear()
        Ok(Executed)
      }
    None => Err("no command is selected")
  }
}

///|
pub fn SelectBeforeExecute::clear(self : SelectBeforeExecute) -> Unit {
  self.selected_ioa = None
  self.selected_state = false
  self.selected_at = 0L
}
