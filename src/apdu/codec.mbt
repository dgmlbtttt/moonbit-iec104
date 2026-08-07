// MoonBit IEC 104 - APCI/APDU Frame Codec (Encode and Decode)

///|
pub fn encode_apdu(apdu : APDU) -> Array[Byte] {
  let buf = @utils.ByteBuffer::new(256)
  buf.write_uint8(@types.START_BYTE)

  match apdu {
    IFormat(send_seq, recv_seq, payload) => {
      let apci_payload_len = 4 + payload.length()
      buf.write_uint8(apci_payload_len.to_byte())

      // Control Field Octet 1 & 2 (Send Sequence Number N(S))
      let ns = (send_seq & 0x7FFF) << 1
      buf.write_uint8((ns & 0xFF).to_byte())
      buf.write_uint8(((ns >> 8) & 0xFF).to_byte())

      // Control Field Octet 3 & 4 (Receive Sequence Number N(R))
      let nr = (recv_seq & 0x7FFF) << 1
      buf.write_uint8((nr & 0xFF).to_byte())
      buf.write_uint8(((nr >> 8) & 0xFF).to_byte())

      // ASDU Payload
      buf.write_bytes(payload)
    }
    SFormat(recv_seq) => {
      buf.write_uint8(b'\x04') // Length is 4 control octets
      buf.write_uint8(b'\x01') // S-Frame marker (bit 0 = 1, bit 1 = 0)
      buf.write_uint8(b'\x00')

      let nr = (recv_seq & 0x7FFF) << 1
      buf.write_uint8((nr & 0xFF).to_byte())
      buf.write_uint8(((nr >> 8) & 0xFF).to_byte())
    }
    UFormat(u_type) => {
      buf.write_uint8(b'\x04')
      buf.write_uint8(u_type.to_byte())
      buf.write_uint8(b'\x00')
      buf.write_uint8(b'\x00')
      buf.write_uint8(b'\x00')
    }
  }

  buf.to_array()
}

///|
pub fn parse_apdu(bytes : Array[Byte]) -> Result[APDU, String] {
  if bytes.length() < @types.MIN_APDU_LEN {
    return Err("APDU buffer too short: expected at least 6 bytes")
  }

  let start_b = bytes[0]
  if start_b != @types.START_BYTE {
    return Err("Invalid IEC 104 start byte: expected 0x68")
  }

  let apdu_len = bytes[1].to_int()
  if apdu_len < 4 || apdu_len > 253 {
    return Err("Invalid APDU length: " + apdu_len.to_string())
  }

  if bytes.length() < apdu_len + 2 {
    return Err("Truncated APDU buffer: length mismatch")
  }

  let b0 = bytes[2].to_int()
  let b1 = bytes[3].to_int()
  let b2 = bytes[4].to_int()
  let b3 = bytes[5].to_int()

  if (b0 & 0x01) == 0 {
    // I-Format Frame
    let send_seq = ((b0 | (b1 << 8)) >> 1) & 0x7FFF
    let recv_seq = ((b2 | (b3 << 8)) >> 1) & 0x7FFF
    let payload_len = apdu_len - 4
    let payload : Array[Byte] = Array::make(payload_len, b'\x00')
    for i = 0; i < payload_len; i = i + 1 {
      payload[i] = bytes[6 + i]
    }
    Ok(IFormat(send_seq, recv_seq, payload))
  } else if (b0 & 0x03) == 1 {
    // S-Format Frame
    let recv_seq = ((b2 | (b3 << 8)) >> 1) & 0x7FFF
    Ok(SFormat(recv_seq))
  } else if (b0 & 0x03) == 3 {
    // U-Format Frame
    match UFrameType::from_byte(bytes[2]) {
      Ok(u_type) => Ok(UFormat(u_type))
      Err(e) => Err(e)
    }
  } else {
    Err("Unknown control octet format")
  }
}
