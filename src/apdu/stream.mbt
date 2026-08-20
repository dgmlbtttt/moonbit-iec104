// Incremental APCI input for transports that may split or combine TCP reads.

///|
pub struct APDUStreamDecoder {
  mut buffer : Array[Byte]
  max_frame_length : Int
} derive(Debug)

///|
pub fn APDUStreamDecoder::new() -> APDUStreamDecoder {
  { buffer: [], max_frame_length: @types.MAX_APDU_LEN }
}

///|
pub fn APDUStreamDecoder::pending_bytes(self : APDUStreamDecoder) -> Int {
  self.buffer.length()
}

///|
pub fn APDUStreamDecoder::reset(self : APDUStreamDecoder) -> Unit {
  self.buffer = []
}

///|
fn copy_bytes(bytes : Array[Byte], start : Int, count : Int) -> Array[Byte] {
  let result : Array[Byte] = Array::make(count, b'\x00')
  for i = 0; i < count; i = i + 1 {
    result[i] = bytes[start + i]
  }
  result
}

///|
pub fn APDUStreamDecoder::push(
  self : APDUStreamDecoder,
  chunk : Array[Byte],
) -> Result[Array[APDU], String] {
  self.buffer.append(chunk)
  let frames : Array[APDU] = []
  while self.buffer.length() > 0 {
    if self.buffer[0] != @types.START_BYTE {
      return Err("Invalid IEC 104 stream prefix: expected 0x68")
    }
    if self.buffer.length() < 2 {
      break
    }
    let apdu_len = self.buffer[1].to_int()
    if apdu_len < 4 {
      return Err("Invalid IEC 104 stream length: expected at least 4")
    }
    let frame_length = apdu_len + 2
    if frame_length > self.max_frame_length {
      return Err("IEC 104 stream frame exceeds maximum length")
    }
    if self.buffer.length() < frame_length {
      break
    }
    let frame = copy_bytes(self.buffer, 0, frame_length)
    match parse_apdu(frame) {
      Ok(apdu) => {
        frames.push(apdu)
        self.buffer = copy_bytes(
          self.buffer,
          frame_length,
          self.buffer.length() - frame_length,
        )
      }
      Err(message) => return Err(message)
    }
  }
  Ok(frames)
}
