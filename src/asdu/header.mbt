// MoonBit IEC 104 - ASDU Header Structure and Codec

///|
pub struct ASDUHeader {
  type_id : Byte // Type Identifier (1..255)
  sq : Bool // Structure Qualifier (false=single IOAs, true=sequence)
  num_objects : Int // Number of information objects (1..127)
  cot : Int // Cause of Transmission (1..63)
  is_test : Bool // T bit (test bit)
  positive_ack : Bool // P/N bit (positive/negative ack)
  oa : Int // Originator Address (0..255)
  casdu : @types.CASDU // Common Address of ASDU (1..65535)
} derive(Debug, Eq)

///|
pub fn ASDUHeader::create(
  type_id~ : Byte,
  sq? : Bool = false,
  num_objects? : Int = 1,
  cot~ : Int,
  is_test? : Bool = false,
  positive_ack? : Bool = false,
  oa? : Int = 0,
  casdu~ : @types.CASDU,
) -> ASDUHeader {
  { type_id, sq, num_objects, cot, is_test, positive_ack, oa, casdu }
}

///|
pub fn ASDUHeader::type_id(self : ASDUHeader) -> Byte {
  self.type_id
}

///|
pub fn ASDUHeader::sq(self : ASDUHeader) -> Bool {
  self.sq
}

///|
pub fn ASDUHeader::num_objects(self : ASDUHeader) -> Int {
  self.num_objects
}

///|
pub fn ASDUHeader::cot(self : ASDUHeader) -> Int {
  self.cot
}

///|
pub fn ASDUHeader::is_test(self : ASDUHeader) -> Bool {
  self.is_test
}

///|
pub fn ASDUHeader::positive_ack(self : ASDUHeader) -> Bool {
  self.positive_ack
}

///|
pub fn ASDUHeader::oa(self : ASDUHeader) -> Int {
  self.oa
}

///|
pub fn ASDUHeader::casdu(self : ASDUHeader) -> @types.CASDU {
  self.casdu
}

///|
pub fn ASDUHeader::encode(self : ASDUHeader) -> Array[Byte] {
  let res : Array[Byte] = Array::make(6, b'\x00')
  res[0] = self.type_id

  let mut vsq = self.num_objects & 0x7F
  if self.sq {
    vsq = vsq | 0x80
  }
  res[1] = vsq.to_byte()

  let mut cot_b = self.cot & 0x3F
  if self.positive_ack {
    cot_b = cot_b | 0x40
  }
  if self.is_test {
    cot_b = cot_b | 0x80
  }
  res[2] = cot_b.to_byte()

  res[3] = (self.oa & 0xFF).to_byte()

  let casdu_bytes = self.casdu.to_bytes()
  res[4] = casdu_bytes[0]
  res[5] = casdu_bytes[1]
  res
}

///|
pub fn ASDUHeader::decode(bytes : Array[Byte]) -> Result[ASDUHeader, String] {
  if bytes.length() < 6 {
    return Err("ASDU Header buffer too short: expected 6 bytes")
  }

  let type_id = bytes[0]

  let vsq = bytes[1].to_int()
  let sq = (vsq & 0x80) != 0
  let num_objects = vsq & 0x7F

  let cot_b = bytes[2].to_int()
  let cot = cot_b & 0x3F
  let positive_ack = (cot_b & 0x40) != 0
  let is_test = (cot_b & 0x80) != 0

  let oa = bytes[3].to_int()

  let casdu_bytes : Array[Byte] = [bytes[4], bytes[5]]
  let casdu = match @types.CASDU::from_bytes(casdu_bytes) {
    Ok(c) => c
    Err(e) => return Err(e)
  }

  Ok({ type_id, sq, num_objects, cot, is_test, positive_ack, oa, casdu })
}
