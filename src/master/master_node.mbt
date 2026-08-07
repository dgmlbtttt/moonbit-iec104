// MoonBit IEC 104 - Control Center Master Simulator Node

///|
pub struct MasterNode {
  target_casdu : @types.CASDU
  conn : @state_machine.ConnectionState
  received_telemetry : Map[Int, Double]
  received_telesignals : Map[Int, Bool]
} derive(Debug, Eq)

///|
pub fn MasterNode::new(target_casdu_addr : Int) -> MasterNode {
  {
    target_casdu: @types.CASDU::new(target_casdu_addr),
    conn: @state_machine.ConnectionState::new(is_master=true),
    received_telemetry: Map([]),
    received_telesignals: Map([]),
  }
}

///|
pub fn MasterNode::target_casdu(self : MasterNode) -> @types.CASDU {
  self.target_casdu
}

///|
pub fn MasterNode::conn(self : MasterNode) -> @state_machine.ConnectionState {
  self.conn
}

///|
pub fn MasterNode::received_telemetry(self : MasterNode) -> Map[Int, Double] {
  self.received_telemetry
}

///|
pub fn MasterNode::received_telesignals(self : MasterNode) -> Map[Int, Bool] {
  self.received_telesignals
}

///|
pub fn MasterNode::initiate_general_interrogation(
  self : MasterNode,
) -> Result[@apdu.APDU, String] {
  let hdr = @asdu.ASDUHeader::create(
    type_id=@types.TYPE_C_IC_NA_1,
    num_objects=1,
    cot=@types.COT_ACTIVATION,
    casdu=self.target_casdu,
  )
  let ioa = @types.IOA::new(0)
  let elem = @asdu.InformationElement::interrogation_command(
    ioa,
    @types.QOI_STATION_GI,
  )
  let asdu = @asdu.ASDU::create(hdr, [elem])
  self.conn.send_i_frame(asdu.encode())
}

///|
pub fn MasterNode::send_single_command(
  self : MasterNode,
  ioa_addr : Int,
  state : Bool,
  select_execute : Bool,
) -> Result[@apdu.APDU, String] {
  let hdr = @asdu.ASDUHeader::create(
    type_id=@types.TYPE_C_SC_NA_1,
    num_objects=1,
    cot=@types.COT_ACTIVATION,
    casdu=self.target_casdu,
  )
  let ioa = @types.IOA::new(ioa_addr)
  let qual = @types.CommandQualifier::create(state~, select_execute~)
  let elem = @asdu.InformationElement::single_command(ioa, qual)
  let asdu = @asdu.ASDU::create(hdr, [elem])
  self.conn.send_i_frame(asdu.encode())
}

///|
pub fn MasterNode::send_clock_sync(
  self : MasterNode,
  time : @types.CP56Time2a,
) -> Result[@apdu.APDU, String] {
  let hdr = @asdu.ASDUHeader::create(
    type_id=@types.TYPE_C_CS_NA_1,
    num_objects=1,
    cot=@types.COT_ACTIVATION,
    casdu=self.target_casdu,
  )
  let ioa = @types.IOA::new(0)
  let elem = @asdu.InformationElement::clock_sync(ioa, time)
  let asdu = @asdu.ASDU::create(hdr, [elem])
  self.conn.send_i_frame(asdu.encode())
}

///|
pub fn MasterNode::handle_apdu(
  self : MasterNode,
  apdu_frame : @apdu.APDU,
) -> Result[Unit, String] {
  let _ = match
    self.conn.process_event(
      @state_machine.ConnectionEvent::frame_received(apdu_frame),
    ) {
    Ok(frames) => frames
    Err(e) => return Err(e)
  }

  match apdu_frame {
    IFormat(_ns, _nr, payload) => {
      let asdu_frame = match @asdu.ASDU::decode(payload) {
        Ok(a) => a
        Err(e) => return Err(e)
      }
      let elements = asdu_frame.elements()

      for i = 0; i < elements.length(); i = i + 1 {
        match elements[i] {
          SinglePointElem(ioa, siq, _, _) =>
            self.received_telesignals.set(ioa.value(), siq.value())
          ShortFloatTelemetryElem(ioa, val, _, _, _) =>
            self.received_telemetry.set(ioa.value(), val)
          _ => ()
        }
      }
      Ok(())
    }
    _ => Ok(())
  }
}
