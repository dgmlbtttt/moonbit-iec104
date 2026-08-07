// MoonBit IEC 104 - Connection State Machine Engine

///|
pub struct ConnectionState {
  mut status : LinkStatus
  sequence_mgr : @apdu.SequenceManager
  is_master : Bool
  mut last_activity_time : Int64
} derive(Debug, Eq)

///|
pub fn ConnectionState::new(is_master~ : Bool) -> ConnectionState {
  {
    status: Unconnected,
    sequence_mgr: @apdu.SequenceManager::new(),
    is_master,
    last_activity_time: 0L,
  }
}

///|
pub fn ConnectionState::status(self : ConnectionState) -> LinkStatus {
  self.status
}

///|
pub fn ConnectionState::is_active(self : ConnectionState) -> Bool {
  self.status == Active
}

///|
pub fn ConnectionState::sequence_mgr(
  self : ConnectionState,
) -> @apdu.SequenceManager {
  self.sequence_mgr
}

///|
pub fn ConnectionState::last_activity_time(self : ConnectionState) -> Int64 {
  self.last_activity_time
}

///|
pub fn ConnectionState::update_activity_time(
  self : ConnectionState,
  now : Int64,
) -> Unit {
  self.last_activity_time = now
}

///|
pub fn ConnectionState::process_event(
  self : ConnectionState,
  event : ConnectionEvent,
) -> Result[Array[@apdu.APDU], String] {
  let responses : Array[@apdu.APDU] = []

  match (self.status, event) {
    (Unconnected, EventConnected) => {
      self.status = Stopped
      if self.is_master {
        self.status = PendingActive
        responses.push(@apdu.APDU::make_u(@apdu.UFrameType::start_dt_act()))
      }
      Ok(responses)
    }
    (Stopped, EventStartDTAct) => {
      self.status = Active
      responses.push(@apdu.APDU::make_u(@apdu.UFrameType::start_dt_con()))
      Ok(responses)
    }
    (PendingActive, EventStartDTCon) => {
      self.status = Active
      Ok(responses)
    }
    (Active, EventStopDTAct) => {
      self.status = Stopped
      responses.push(@apdu.APDU::make_u(@apdu.UFrameType::stop_dt_con()))
      Ok(responses)
    }
    (Active, EventTimeoutT3) => {
      // Send keepalive test frame
      responses.push(@apdu.APDU::make_u(@apdu.UFrameType::test_fr_act()))
      Ok(responses)
    }
    (Active, EventFrameReceived(frame)) =>
      match frame {
        UFormat(TestFRAct) => {
          responses.push(@apdu.APDU::make_u(@apdu.UFrameType::test_fr_con()))
          Ok(responses)
        }
        UFormat(TestFRCon) => Ok(responses)
        SFormat(recv_seq) => {
          self.sequence_mgr.update_ack(recv_seq)
          Ok(responses)
        }
        IFormat(remote_ns, remote_nr, _payload) => {
          match self.sequence_mgr.confirm_recv(remote_ns) {
            Ok(_) => ()
            Err(e) => return Err(e)
          }
          self.sequence_mgr.update_ack(remote_nr)
          if self.sequence_mgr.should_send_s_frame() {
            let s_frame = @apdu.APDU::make_s(self.sequence_mgr.recv_seq())
            responses.push(s_frame)
          }
          Ok(responses)
        }
        _ => Ok(responses)
      }
    (_, EventDisconnected) => {
      self.status = Unconnected
      self.sequence_mgr.reset()
      Ok(responses)
    }
    _ => Ok(responses)
  }
}

///|
pub fn ConnectionState::send_i_frame(
  self : ConnectionState,
  payload : Array[Byte],
) -> Result[@apdu.APDU, String] {
  if self.status != Active {
    return Err(
      "Cannot send I-frame: connection state is " + self.status.to_string(),
    )
  }
  if !self.sequence_mgr.can_send_i_frame() {
    return Err("Transmission blocked: max unacknowledged frames reached")
  }
  let ns = self.sequence_mgr.next_send_seq()
  let nr = self.sequence_mgr.recv_seq()
  Ok(@apdu.APDU::make_i(ns, nr, payload))
}
