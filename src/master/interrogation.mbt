// Deterministic state tracking for General Interrogation (GI).

///|
pub enum InterrogationStatus {
  Idle
  AwaitingConfirmation
  ReceivingData
  Complete
  Failed
} derive(Debug, Eq)

///|
pub fn InterrogationStatus::receiving_data() -> InterrogationStatus {
  ReceivingData
}

///|
pub fn InterrogationStatus::complete() -> InterrogationStatus {
  Complete
}

///|
pub struct InterrogationSession {
  target : @types.CASDU
  batch_size : Int
  mut phase : InterrogationStatus
  mut batches : Int
  mut objects : Int
} derive(Debug, Eq)

///|
pub fn InterrogationSession::new(
  target : @types.CASDU,
  batch_size : Int,
) -> InterrogationSession {
  {
    target,
    batch_size: if batch_size < 1 {
      1
    } else {
      batch_size
    },
    phase: Idle,
    batches: 0,
    objects: 0,
  }
}

///|
pub fn InterrogationSession::status(
  self : InterrogationSession,
) -> InterrogationStatus {
  self.phase
}

///|
pub fn InterrogationSession::batch_size(self : InterrogationSession) -> Int {
  self.batch_size
}

///|
pub fn InterrogationSession::batches(self : InterrogationSession) -> Int {
  self.batches
}

///|
pub fn InterrogationSession::received_objects(
  self : InterrogationSession,
) -> Int {
  self.objects
}

///|
pub fn InterrogationSession::start(
  self : InterrogationSession,
) -> Result[Unit, String] {
  match self.phase {
    Idle => {
      self.phase = AwaitingConfirmation
      Ok(())
    }
    _ => Err("GI session is already in progress or complete")
  }
}

///|
fn same_station(expected : @types.CASDU, actual : @types.CASDU) -> Bool {
  expected.address() == actual.address()
}

///|
pub fn InterrogationSession::accept(
  self : InterrogationSession,
  asdu : @asdu.ASDU,
) -> Result[Unit, String] {
  if !same_station(self.target, asdu.header().casdu()) {
    self.phase = Failed
    return Err("GI response belongs to a different station")
  }
  let header = asdu.header()
  if self.phase == Idle && header.type_id() != @types.TYPE_C_IC_NA_1 {
    return Ok(())
  }
  if self.phase == Complete && header.type_id() != @types.TYPE_C_IC_NA_1 {
    return Ok(())
  }
  if header.type_id() != @types.TYPE_M_SP_NA_1 &&
    header.type_id() != @types.TYPE_C_IC_NA_1 {
    if self.phase == ReceivingData {
      self.objects = self.objects + asdu.elements().length()
      self.batches = self.batches + 1
      return Ok(())
    }
    return Err("unexpected non-GI ASDU before activation confirmation")
  }
  let cot = header.cot()
  if cot == @types.COT_ACTIVATION_CON {
    if self.phase != AwaitingConfirmation {
      self.phase = Failed
      return Err("duplicate or out-of-order GI activation confirmation")
    }
    self.phase = ReceivingData
    return Ok(())
  }
  if cot == @types.COT_ACTIVATION_TERMINATED {
    if self.phase != ReceivingData {
      self.phase = Failed
      return Err("GI activation termination arrived before data")
    }
    self.phase = Complete
    return Ok(())
  }
  if cot == @types.COT_INTERROGATED_STATION {
    if self.phase != ReceivingData {
      self.phase = Failed
      return Err("GI data arrived before activation confirmation")
    }
    self.objects = self.objects + asdu.elements().length()
    self.batches = self.batches + 1
    Ok(())
  } else {
    Err("unsupported GI cause of transmission")
  }
}
