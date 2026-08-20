// MoonBit IEC 104 - Substation RTU/Slave Simulator Node

///|
pub struct SlaveNode {
  casdu : @types.CASDU
  db : PointDatabase
  conn : @state_machine.ConnectionState
  spontaneous_queue : EventQueue
} derive(Debug, Eq)

///|
pub fn SlaveNode::new(casdu_addr : Int) -> SlaveNode {
  {
    casdu: @types.CASDU::new(casdu_addr),
    db: PointDatabase::new(),
    conn: @state_machine.ConnectionState::new(is_master=false),
    spontaneous_queue: EventQueue::new(256),
  }
}

///|
pub fn SlaveNode::casdu(self : SlaveNode) -> @types.CASDU {
  self.casdu
}

///|
pub fn SlaveNode::db(self : SlaveNode) -> PointDatabase {
  self.db
}

///|
pub fn SlaveNode::conn(self : SlaveNode) -> @state_machine.ConnectionState {
  self.conn
}

///|
pub fn SlaveNode::pending_spontaneous_count(self : SlaveNode) -> Int {
  self.spontaneous_queue.len()
}

///|
pub fn SlaveNode::dropped_spontaneous_count(self : SlaveNode) -> Int {
  self.spontaneous_queue.dropped_count()
}

///|
pub fn SlaveNode::drain_spontaneous(
  self : SlaveNode,
  limit : Int,
) -> Array[QueuedEvent] {
  self.spontaneous_queue.drain(limit)
}

///|
pub fn SlaveNode::handle_apdu(
  self : SlaveNode,
  apdu_frame : @apdu.APDU,
) -> Result[Array[@apdu.APDU], String] {
  let responses : Array[@apdu.APDU] = []

  let conn_res = match
    self.conn.process_event(
      @state_machine.ConnectionEvent::frame_received(apdu_frame),
    ) {
    Ok(frames) => frames
    Err(e) => return Err(e)
  }
  for i = 0; i < conn_res.length(); i = i + 1 {
    responses.push(conn_res[i])
  }

  match apdu_frame {
    IFormat(_ns, _nr, payload) => {
      let asdu_frame = match @asdu.ASDU::decode(payload) {
        Ok(a) => a
        Err(e) => return Err(e)
      }
      let type_id = asdu_frame.header().type_id()

      if type_id == @types.TYPE_C_IC_NA_1 {
        // General Interrogation (GI)
        let act_con_hdr = @asdu.ASDUHeader::create(
          type_id=@types.TYPE_C_IC_NA_1,
          num_objects=1,
          cot=@types.COT_ACTIVATION_CON,
          casdu=self.casdu,
        )
        let ioa = @types.IOA::new(0)
        let elem = @asdu.InformationElement::interrogation_command(
          ioa,
          @types.QOI_STATION_GI,
        )
        let act_con_asdu = @asdu.ASDU::create(act_con_hdr, [elem])
        let send_res1 = match self.conn.send_i_frame(act_con_asdu.encode()) {
          Ok(f) => f
          Err(e) => return Err(e)
        }
        responses.push(send_res1)

        // Send all GI data points
        let gi_asdus = self.db.build_gi_asdus(self.casdu)
        for i = 0; i < gi_asdus.length(); i = i + 1 {
          let gi_f = match self.conn.send_i_frame(gi_asdus[i].encode()) {
            Ok(f) => f
            Err(e) => return Err(e)
          }
          responses.push(gi_f)
        }

        // Send Activation Termination
        let act_term_hdr = @asdu.ASDUHeader::create(
          type_id=@types.TYPE_C_IC_NA_1,
          num_objects=1,
          cot=@types.COT_ACTIVATION_TERMINATED,
          casdu=self.casdu,
        )
        let act_term_asdu = @asdu.ASDU::create(act_term_hdr, [elem])
        let send_res2 = match self.conn.send_i_frame(act_term_asdu.encode()) {
          Ok(f) => f
          Err(e) => return Err(e)
        }
        responses.push(send_res2)
      } else if type_id == @types.TYPE_C_SC_NA_1 {
        // Single Command Control
        let elem = asdu_frame.elements()[0]
        match elem {
          SingleCommandElem(cmd_ioa, cmd_qual) => {
            let state = cmd_qual.state()
            self.db.set_single_point(cmd_ioa.value(), state)

            // Echo Activation Confirmation
            let act_con_hdr = @asdu.ASDUHeader::create(
              type_id=@types.TYPE_C_SC_NA_1,
              num_objects=1,
              cot=@types.COT_ACTIVATION_CON,
              casdu=self.casdu,
            )
            let act_con_asdu = @asdu.ASDU::create(act_con_hdr, [elem])
            let f = match self.conn.send_i_frame(act_con_asdu.encode()) {
              Ok(frame) => frame
              Err(e) => return Err(e)
            }
            responses.push(f)
          }
          _ => ()
        }
      } else if type_id == @types.TYPE_C_CS_NA_1 {
        // Clock Synchronization
        let act_con_hdr = @asdu.ASDUHeader::create(
          type_id=@types.TYPE_C_CS_NA_1,
          num_objects=1,
          cot=@types.COT_ACTIVATION_CON,
          casdu=self.casdu,
        )
        let act_con_asdu = @asdu.ASDU::create(
          act_con_hdr,
          asdu_frame.elements(),
        )
        let f = match self.conn.send_i_frame(act_con_asdu.encode()) {
          Ok(frame) => frame
          Err(e) => return Err(e)
        }
        responses.push(f)
      }
    }
    _ => ()
  }

  Ok(responses)
}

///|
pub fn SlaveNode::report_spontaneous_single_point(
  self : SlaveNode,
  ioa_addr : Int,
  value : Bool,
) -> Result[@apdu.APDU, String] {
  self.db.set_single_point(ioa_addr, value)

  let ioa = @types.IOA::new(ioa_addr)
  let siq = @types.SIQ::create(value~, invalid=false)
  let elem = @asdu.InformationElement::single_point(ioa, siq)

  let hdr = @asdu.ASDUHeader::create(
    type_id=@types.TYPE_M_SP_NA_1,
    num_objects=1,
    cot=@types.COT_SPONTANEOUS,
    casdu=self.casdu,
  )
  let asdu = @asdu.ASDU::create(hdr, [elem])
  let _ = self.spontaneous_queue.push(asdu)
  self.conn.send_i_frame(asdu.encode())
}
