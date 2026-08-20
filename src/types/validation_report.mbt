// Aggregated validation report for admission checks at protocol boundaries.

///|
pub struct ValidationIssue {
  field : String
  message : String
} derive(Debug, Eq)

///|
pub fn ValidationIssue::field(self : ValidationIssue) -> String {
  self.field
}

///|
pub fn ValidationIssue::message(self : ValidationIssue) -> String {
  self.message
}

///|
pub struct ValidationReport {
  issues : Array[ValidationIssue]
} derive(Debug, Eq)

///|
pub fn ValidationReport::new() -> ValidationReport {
  { issues: [] }
}

///|
pub fn ValidationReport::issues(
  self : ValidationReport,
) -> Array[ValidationIssue] {
  self.issues
}

///|
pub fn ValidationReport::is_valid(self : ValidationReport) -> Bool {
  self.issues.length() == 0
}

///|
pub fn ValidationReport::add(
  self : ValidationReport,
  field : String,
  message : String,
) -> Unit {
  self.issues.push({ field, message })
}

///|
pub fn ValidationReport::merge(
  self : ValidationReport,
  other : ValidationReport,
) -> Unit {
  for issue in other.issues {
    self.issues.push(issue)
  }
}

///|
pub fn validate_protocol_addresses(ioa : Int, casdu : Int) -> ValidationReport {
  let report = ValidationReport::new()
  if ioa < 0 || ioa > MAX_IOA {
    report.add("ioa", "value outside 24-bit range")
  }
  if casdu < 1 || casdu > MAX_CASDU {
    report.add("casdu", "value outside station range")
  }
  report
}

///|
pub fn validate_frame_window(
  send_seq : Int,
  recv_seq : Int,
) -> ValidationReport {
  let report = ValidationReport::new()
  if validate_sequence(send_seq) is Err(_) {
    report.add("send_seq", "value outside 15-bit range")
  }
  if validate_sequence(recv_seq) is Err(_) {
    report.add("recv_seq", "value outside 15-bit range")
  }
  report
}
