// Common quality policy decisions for master and simulator consumers.

///|
pub fn quality_is_usable(qds : QDS) -> Bool {
  !qds.invalid() && !qds.blocked()
}

///|
pub fn signal_is_usable(siq : SIQ) -> Bool {
  !siq.invalid()
}

///|
pub fn double_point_is_valid(diq : DIQ) -> Bool {
  !diq.invalid() && diq.dpi() >= 1 && diq.dpi() <= 2
}

///|
pub fn quality_byte_has_reserved_bits(byte : Byte) -> Bool {
  (byte.to_int() & 0x0E) != 0
}

///|
pub fn normalize_quality_byte(byte : Byte) -> Byte {
  (byte.to_int() & 0xF1).to_byte()
}

///|
pub fn command_is_select(qualifier : CommandQualifier) -> Bool {
  qualifier.select_execute()
}

///|
pub fn command_pulse_is_valid(qualifier : CommandQualifier) -> Bool {
  qualifier.pulse_duration() >= 0 && qualifier.pulse_duration() <= 31
}

///|
pub fn validate_quality_for_measurement(
  qds : QDS,
  value : Double,
) -> Result[Unit, String] {
  if value != value {
    return Err("measurement cannot be NaN")
  }
  if !quality_is_usable(qds) {
    return Err("measurement quality is not usable")
  }
  Ok(())
}
