// MoonBit IEC 104 - Link State Definitions and Event Model

///|
pub enum LinkStatus {
  Unconnected
  Connecting
  Stopped
  PendingActive
  Active
  PendingStop
} derive(Debug, Eq)

///|
pub fn LinkStatus::unconnected() -> LinkStatus {
  Unconnected
}

///|
pub fn LinkStatus::connecting() -> LinkStatus {
  Connecting
}

///|
pub fn LinkStatus::stopped() -> LinkStatus {
  Stopped
}

///|
pub fn LinkStatus::pending_active() -> LinkStatus {
  PendingActive
}

///|
pub fn LinkStatus::active() -> LinkStatus {
  Active
}

///|
pub fn LinkStatus::pending_stop() -> LinkStatus {
  PendingStop
}

///|
pub enum ConnectionEvent {
  EventConnected
  EventDisconnected
  EventStartDTAct
  EventStartDTCon
  EventStopDTAct
  EventStopDTCon
  EventFrameReceived(@apdu.APDU)
  EventTimeoutT1
  EventTimeoutT2
  EventTimeoutT3
} derive(Debug, Eq)

///|
pub fn ConnectionEvent::connected() -> ConnectionEvent {
  EventConnected
}

///|
pub fn ConnectionEvent::disconnected() -> ConnectionEvent {
  EventDisconnected
}

///|
pub fn ConnectionEvent::start_dt_act() -> ConnectionEvent {
  EventStartDTAct
}

///|
pub fn ConnectionEvent::start_dt_con() -> ConnectionEvent {
  EventStartDTCon
}

///|
pub fn ConnectionEvent::stop_dt_act() -> ConnectionEvent {
  EventStopDTAct
}

///|
pub fn ConnectionEvent::stop_dt_con() -> ConnectionEvent {
  EventStopDTCon
}

///|
pub fn ConnectionEvent::frame_received(frame : @apdu.APDU) -> ConnectionEvent {
  EventFrameReceived(frame)
}

///|
pub fn ConnectionEvent::timeout_t1() -> ConnectionEvent {
  EventTimeoutT1
}

///|
pub fn ConnectionEvent::timeout_t2() -> ConnectionEvent {
  EventTimeoutT2
}

///|
pub fn ConnectionEvent::timeout_t3() -> ConnectionEvent {
  EventTimeoutT3
}

///|
pub fn LinkStatus::to_string(self : LinkStatus) -> String {
  match self {
    Unconnected => "UNCONNECTED"
    Connecting => "CONNECTING"
    Stopped => "STOPPED"
    PendingActive => "PENDING_ACTIVE"
    Active => "ACTIVE"
    PendingStop => "PENDING_STOP"
  }
}
