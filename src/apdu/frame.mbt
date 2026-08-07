// MoonBit IEC 104 - APCI Frame Types and Structures

///|
pub enum UFrameType {
  StartDTAct
  StartDTCon
  StopDTAct
  StopDTCon
  TestFRAct
  TestFRCon
} derive(Debug, Eq)

///|
pub fn UFrameType::start_dt_act() -> UFrameType {
  StartDTAct
}

///|
pub fn UFrameType::start_dt_con() -> UFrameType {
  StartDTCon
}

///|
pub fn UFrameType::stop_dt_act() -> UFrameType {
  StopDTAct
}

///|
pub fn UFrameType::stop_dt_con() -> UFrameType {
  StopDTCon
}

///|
pub fn UFrameType::test_fr_act() -> UFrameType {
  TestFRAct
}

///|
pub fn UFrameType::test_fr_con() -> UFrameType {
  TestFRCon
}

///|
pub enum APDU {
  IFormat(Int, Int, Array[Byte]) // send_seq, recv_seq, payload
  SFormat(Int) // recv_seq
  UFormat(UFrameType)
} derive(Debug, Eq)

///|
pub fn APDU::make_i(
  send_seq : Int,
  recv_seq : Int,
  payload : Array[Byte],
) -> APDU {
  IFormat(send_seq, recv_seq, payload)
}

///|
pub fn APDU::make_s(recv_seq : Int) -> APDU {
  SFormat(recv_seq)
}

///|
pub fn APDU::make_u(u_type : UFrameType) -> APDU {
  UFormat(u_type)
}

///|
pub fn UFrameType::to_byte(self : UFrameType) -> Byte {
  match self {
    StartDTAct => b'\x07'
    StartDTCon => b'\x0B'
    StopDTAct => b'\x13'
    StopDTCon => b'\x23'
    TestFRAct => b'\x43'
    TestFRCon => b'\x83'
  }
}

///|
pub fn UFrameType::from_byte(b : Byte) -> Result[UFrameType, String] {
  match b.to_int() {
    0x07 => Ok(StartDTAct)
    0x0B => Ok(StartDTCon)
    0x13 => Ok(StopDTAct)
    0x23 => Ok(StopDTCon)
    0x43 => Ok(TestFRAct)
    0x83 => Ok(TestFRCon)
    v => Err("Unknown U-Frame type byte: 0x" + @utils.byte_to_hex(v.to_byte()))
  }
}

///|
pub fn APDU::frame_type_name(self : APDU) -> String {
  match self {
    IFormat(_, _, _) => "I-Frame"
    SFormat(_) => "S-Frame"
    UFormat(u_type) =>
      match u_type {
        StartDTAct => "U-Frame (STARTDT ACT)"
        StartDTCon => "U-Frame (STARTDT CON)"
        StopDTAct => "U-Frame (STOPDT ACT)"
        StopDTCon => "U-Frame (STOPDT CON)"
        TestFRAct => "U-Frame (TESTFR ACT)"
        TestFRCon => "U-Frame (TESTFR CON)"
      }
  }
}
