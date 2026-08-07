// MoonBit IEC 104 - Information Object Address (IOA) & Common Address (CASDU)

// 24-bit 3-Byte Information Object Address

///|
pub struct IOA {
  value : Int // 0..16777215 (0x000000..0xFFFFFF)
} derive(Debug, Eq, Hash)

///|
pub fn IOA::new(addr : Int) -> IOA {
  { value: addr & 0xFFFFFF }
}

///|
pub fn IOA::value(self : IOA) -> Int {
  self.value
}

///|
pub fn IOA::to_bytes(self : IOA) -> Array[Byte] {
  let res : Array[Byte] = Array::make(3, b'\x00')
  let v = self.value
  res[0] = (v & 0xFF).to_byte()
  res[1] = ((v >> 8) & 0xFF).to_byte()
  res[2] = ((v >> 16) & 0xFF).to_byte()
  res
}

///|
pub fn IOA::from_bytes(bytes : Array[Byte]) -> Result[IOA, String] {
  if bytes.length() < 3 {
    return Err("Invalid IOA length: expected 3 bytes")
  }
  let b0 = bytes[0].to_int()
  let b1 = bytes[1].to_int()
  let b2 = bytes[2].to_int()
  let addr = b0 | (b1 << 8) | (b2 << 16)
  Ok({ value: addr })
}

///|
pub fn IOA::to_string(self : IOA) -> String {
  "IOA(" + self.value.to_string() + ")"
}

// 16-bit 2-Byte Common Address of ASDU (CASDU / Station Address)

///|
pub struct CASDU {
  address : Int // 1..65534 (0x0001..0xFFFE), 65535 (0xFFFF) = Global broadcast
} derive(Debug, Eq, Hash)

///|
pub fn CASDU::new(addr : Int) -> CASDU {
  { address: addr & 0xFFFF }
}

///|
pub fn CASDU::address(self : CASDU) -> Int {
  self.address
}

///|
pub fn CASDU::to_bytes(self : CASDU) -> Array[Byte] {
  let res : Array[Byte] = Array::make(2, b'\x00')
  let v = self.address
  res[0] = (v & 0xFF).to_byte()
  res[1] = ((v >> 8) & 0xFF).to_byte()
  res
}

///|
pub fn CASDU::from_bytes(bytes : Array[Byte]) -> Result[CASDU, String] {
  if bytes.length() < 2 {
    return Err("Invalid CASDU length: expected 2 bytes")
  }
  let b0 = bytes[0].to_int()
  let b1 = bytes[1].to_int()
  let addr = b0 | (b1 << 8)
  Ok({ address: addr })
}

///|
pub fn CASDU::is_broadcast(self : CASDU) -> Bool {
  self.address == 0xFFFF
}
