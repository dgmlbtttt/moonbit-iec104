// MoonBit IEC 104 - Full ASDU Frame Container and Payload Codecs

///|
pub struct ASDU {
  header : ASDUHeader
  elements : Array[InformationElement]
} derive(Debug, Eq)

///|
pub fn ASDU::create(
  header : ASDUHeader,
  elements : Array[InformationElement],
) -> ASDU {
  { header, elements }
}

///|
pub fn ASDU::header(self : ASDU) -> ASDUHeader {
  self.header
}

///|
pub fn ASDU::elements(self : ASDU) -> Array[InformationElement] {
  self.elements
}

///|
pub fn ASDU::encode(self : ASDU) -> Array[Byte] {
  let buf = @utils.ByteBuffer::new(256)
  let hdr_bytes = self.header.encode()
  buf.write_bytes(hdr_bytes)

  let type_id = self.header.type_id()

  for i = 0; i < self.elements.length(); i = i + 1 {
    let elem = self.elements[i]
    match elem {
      SinglePointElem(ioa, siq, time24, time56) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint8(siq.to_byte())
        if type_id == @types.TYPE_M_SP_TA_1 {
          match time24 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP24Time2a::create().to_bytes())
          }
        } else if type_id == @types.TYPE_M_SP_TB_1 {
          match time56 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP56Time2a::default().to_bytes())
          }
        }
      }
      DoublePointElem(ioa, diq, time24, time56) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint8(diq.to_byte())
        if type_id == @types.TYPE_M_DP_TA_1 {
          match time24 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP24Time2a::create().to_bytes())
          }
        } else if type_id == @types.TYPE_M_DP_TB_1 {
          match time56 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP56Time2a::default().to_bytes())
          }
        }
      }
      StepPositionElem(ioa, vti, qds, time56) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_int8(vti)
        buf.write_uint8(qds.to_byte())
        if type_id == @types.TYPE_M_ST_TB_1 {
          match time56 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP56Time2a::default().to_bytes())
          }
        }
      }
      NormalizedTelemetryElem(ioa, val, qds, time24, time56) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint16_le(val)
        buf.write_uint8(qds.to_byte())
        if type_id == @types.TYPE_M_ME_TA_1 {
          match time24 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP24Time2a::create().to_bytes())
          }
        } else if type_id == @types.TYPE_M_ME_TD_1 {
          match time56 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP56Time2a::default().to_bytes())
          }
        }
      }
      ScaledTelemetryElem(ioa, val, qds, time24, time56) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint16_le(val)
        buf.write_uint8(qds.to_byte())
        if type_id == @types.TYPE_M_ME_TB_1 {
          match time24 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP24Time2a::create().to_bytes())
          }
        } else if type_id == @types.TYPE_M_ME_TE_1 {
          match time56 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP56Time2a::default().to_bytes())
          }
        }
      }
      ShortFloatTelemetryElem(ioa, val, qds, time24, time56) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_float32_le(val)
        buf.write_uint8(qds.to_byte())
        if type_id == @types.TYPE_M_ME_TC_1 {
          match time24 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP24Time2a::create().to_bytes())
          }
        } else if type_id == @types.TYPE_M_ME_TF_1 {
          match time56 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP56Time2a::default().to_bytes())
          }
        }
      }
      IntegratedTotalsElem(
        ioa,
        counter_val,
        seq,
        invalid,
        adjusted,
        overflow,
        time56
      ) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint32_le(counter_val)
        let mut b = seq & 0x1F
        if invalid {
          b = b | 0x80
        }
        if adjusted {
          b = b | 0x40
        }
        if overflow {
          b = b | 0x20
        }
        buf.write_uint8(b.to_byte())
        if type_id == @types.TYPE_M_IT_TB_1 {
          match time56 {
            Some(t) => buf.write_bytes(t.to_bytes())
            None => buf.write_bytes(@types.CP56Time2a::default().to_bytes())
          }
        }
      }
      SingleCommandElem(ioa, cmd_qual) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint8(cmd_qual.to_byte())
      }
      DoubleCommandElem(ioa, cmd_qual) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint8(cmd_qual.to_byte())
      }
      SetPointNormalizedElem(ioa, val, cmd_qual) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint16_le(val)
        buf.write_uint8(cmd_qual.to_byte())
      }
      SetPointScaledElem(ioa, val, cmd_qual) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint16_le(val)
        buf.write_uint8(cmd_qual.to_byte())
      }
      SetPointFloatElem(ioa, val, cmd_qual) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_float32_le(val)
        buf.write_uint8(cmd_qual.to_byte())
      }
      InterrogationCommandElem(ioa, qoi) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint8(qoi)
      }
      CounterInterrogationElem(ioa, qcc) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint8(qcc)
      }
      ClockSyncElem(ioa, time) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_bytes(time.to_bytes())
      }
      ResetProcessElem(ioa, qrp) => {
        buf.write_bytes(ioa.to_bytes())
        buf.write_uint8(qrp)
      }
    }
  }

  buf.to_array()
}

///|
pub fn ASDU::decode(bytes : Array[Byte]) -> Result[ASDU, String] {
  if bytes.length() < 6 {
    return Err("ASDU buffer too short")
  }

  let hdr = match ASDUHeader::decode(bytes) {
    Ok(h) => h
    Err(e) => return Err(e)
  }

  let buf = @utils.ByteBuffer::from_bytes(bytes)
  let _ = buf.read_bytes(6) // Skip header

  let elements : Array[InformationElement] = []
  let type_id = hdr.type_id()
  let num_objs = hdr.num_objects()

  for _i = 0; _i < num_objs; _i = _i + 1 {
    let ioa_bytes = match buf.read_bytes(3) {
      Ok(b) => b
      Err(e) => return Err(e)
    }
    let ioa = match @types.IOA::from_bytes(ioa_bytes) {
      Ok(a) => a
      Err(e) => return Err(e)
    }

    if type_id == @types.TYPE_M_SP_NA_1 {
      let siq_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let siq = @types.SIQ::from_byte(siq_b)
      elements.push(SinglePointElem(ioa, siq, None, None))
    } else if type_id == @types.TYPE_M_SP_TB_1 {
      let siq_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let siq = @types.SIQ::from_byte(siq_b)
      let t_bytes = match buf.read_bytes(7) {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let time56 = match @types.CP56Time2a::from_bytes(t_bytes) {
        Ok(t) => t
        Err(e) => return Err(e)
      }
      elements.push(SinglePointElem(ioa, siq, None, Some(time56)))
    } else if type_id == @types.TYPE_M_DP_NA_1 {
      let diq_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let diq = @types.DIQ::from_byte(diq_b)
      elements.push(DoublePointElem(ioa, diq, None, None))
    } else if type_id == @types.TYPE_M_DP_TB_1 {
      let diq_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let diq = @types.DIQ::from_byte(diq_b)
      let t_bytes = match buf.read_bytes(7) {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let time56 = match @types.CP56Time2a::from_bytes(t_bytes) {
        Ok(t) => t
        Err(e) => return Err(e)
      }
      elements.push(DoublePointElem(ioa, diq, None, Some(time56)))
    } else if type_id == @types.TYPE_M_ME_NA_1 {
      let val = match buf.read_uint16_le() {
        Ok(v) => v
        Err(e) => return Err(e)
      }
      let qds_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let qds = @types.QDS::from_byte(qds_b)
      elements.push(NormalizedTelemetryElem(ioa, val, qds, None, None))
    } else if type_id == @types.TYPE_M_ME_NC_1 {
      let val = match buf.read_float32_le() {
        Ok(v) => v
        Err(e) => return Err(e)
      }
      let qds_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let qds = @types.QDS::from_byte(qds_b)
      elements.push(ShortFloatTelemetryElem(ioa, val, qds, None, None))
    } else if type_id == @types.TYPE_M_ME_TF_1 {
      let val = match buf.read_float32_le() {
        Ok(v) => v
        Err(e) => return Err(e)
      }
      let qds_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let qds = @types.QDS::from_byte(qds_b)
      let t_bytes = match buf.read_bytes(7) {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let time56 = match @types.CP56Time2a::from_bytes(t_bytes) {
        Ok(t) => t
        Err(e) => return Err(e)
      }
      elements.push(ShortFloatTelemetryElem(ioa, val, qds, None, Some(time56)))
    } else if type_id == @types.TYPE_M_IT_NA_1 {
      let cval = match buf.read_uint32_le() {
        Ok(v) => v
        Err(e) => return Err(e)
      }
      let b = match buf.read_uint8() {
        Ok(v) => v.to_int()
        Err(e) => return Err(e)
      }
      let seq = b & 0x1F
      let overflow = (b & 0x20) != 0
      let adjusted = (b & 0x40) != 0
      let invalid = (b & 0x80) != 0
      elements.push(
        IntegratedTotalsElem(ioa, cval, seq, invalid, adjusted, overflow, None),
      )
    } else if type_id == @types.TYPE_C_SC_NA_1 {
      let q_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let qual = @types.CommandQualifier::from_byte(q_b)
      elements.push(SingleCommandElem(ioa, qual))
    } else if type_id == @types.TYPE_C_DC_NA_1 {
      let q_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let qual = @types.CommandQualifier::from_byte(q_b)
      elements.push(DoubleCommandElem(ioa, qual))
    } else if type_id == @types.TYPE_C_SE_NC_1 {
      let val = match buf.read_float32_le() {
        Ok(v) => v
        Err(e) => return Err(e)
      }
      let q_b = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let qual = @types.CommandQualifier::from_byte(q_b)
      elements.push(SetPointFloatElem(ioa, val, qual))
    } else if type_id == @types.TYPE_C_IC_NA_1 {
      let qoi = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      elements.push(InterrogationCommandElem(ioa, qoi))
    } else if type_id == @types.TYPE_C_CI_NA_1 {
      let qcc = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      elements.push(CounterInterrogationElem(ioa, qcc))
    } else if type_id == @types.TYPE_C_CS_NA_1 {
      let t_bytes = match buf.read_bytes(7) {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      let time56 = match @types.CP56Time2a::from_bytes(t_bytes) {
        Ok(t) => t
        Err(e) => return Err(e)
      }
      elements.push(ClockSyncElem(ioa, time56))
    } else if type_id == @types.TYPE_C_RP_NA_1 {
      let qrp = match buf.read_uint8() {
        Ok(b) => b
        Err(e) => return Err(e)
      }
      elements.push(ResetProcessElem(ioa, qrp))
    } else {
      return Err(
        "Unsupported ASDU type identifier: " + type_id.to_int().to_string(),
      )
    }
  }

  Ok({ header: hdr, elements })
}
