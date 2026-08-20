// Structured diagnostics around the string-based legacy APDU parser.

///|
pub enum APDUErrorKind {
  Truncated
  InvalidPrefix
  InvalidLength
  UnsupportedFormat
  InvalidUFrame
  Unknown
} derive(Debug, Eq)

///|
pub fn APDUErrorKind::truncated() -> APDUErrorKind {
  Truncated
}

///|
pub fn APDUErrorKind::invalid_prefix() -> APDUErrorKind {
  InvalidPrefix
}

///|
pub fn APDUErrorKind::invalid_length() -> APDUErrorKind {
  InvalidLength
}

///|
pub fn APDUErrorKind::unsupported_format() -> APDUErrorKind {
  UnsupportedFormat
}

///|
pub fn APDUErrorKind::invalid_u_frame() -> APDUErrorKind {
  InvalidUFrame
}

///|
pub fn APDUErrorKind::unknown() -> APDUErrorKind {
  Unknown
}

///|
pub struct APDUDecodeError {
  kind : APDUErrorKind
  message : String
  input_length : Int
} derive(Debug, Eq)

///|
pub fn APDUDecodeError::kind(self : APDUDecodeError) -> APDUErrorKind {
  self.kind
}

///|
pub fn APDUDecodeError::message(self : APDUDecodeError) -> String {
  self.message
}

///|
pub fn APDUDecodeError::input_length(self : APDUDecodeError) -> Int {
  self.input_length
}

///|
fn classify_error(message : String) -> APDUErrorKind {
  if message.contains("too short") || message.contains("Truncated") {
    Truncated
  } else if message.contains("start byte") {
    InvalidPrefix
  } else if message.contains("length") {
    InvalidLength
  } else if message.contains("U-Frame") {
    InvalidUFrame
  } else if message.contains("format") {
    UnsupportedFormat
  } else {
    Unknown
  }
}

///|
pub fn parse_apdu_diagnostic(
  bytes : Array[Byte],
) -> Result[APDU, APDUDecodeError] {
  match parse_apdu(bytes) {
    Ok(frame) => Ok(frame)
    Err(message) =>
      Err({
        kind: classify_error(message),
        message,
        input_length: bytes.length(),
      })
  }
}
