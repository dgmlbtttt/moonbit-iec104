// MoonBit IEC 104 - Quality Descriptors and Control Command Flags

// Quality Descriptor for Telemetry (QDS)
///|
pub struct QDS {
  invalid : Bool // IV (bit 7): 0=valid, 1=invalid
  not_topical : Bool // NT (bit 6): 0=topical, 1=not topical
  substituted : Bool // SB (bit 5): 0=not substituted, 1=substituted
  blocked : Bool // BL (bit 4): 0=not blocked, 1=blocked
  overflow : Bool // OV (bit 0): 0=no overflow, 1=overflow
} derive(Debug, Eq)

///|
pub fn QDS::default() -> QDS {
  {
    invalid: false,
    not_topical: false,
    substituted: false,
    blocked: false,
    overflow: false,
  }
}

///|
pub fn QDS::create(
  invalid? : Bool = false,
  not_topical? : Bool = false,
  substituted? : Bool = false,
  blocked? : Bool = false,
  overflow? : Bool = false,
) -> QDS {
  { invalid, not_topical, substituted, blocked, overflow }
}

///|
pub fn QDS::invalid(self : QDS) -> Bool {
  self.invalid
}

///|
pub fn QDS::not_topical(self : QDS) -> Bool {
  self.not_topical
}

///|
pub fn QDS::substituted(self : QDS) -> Bool {
  self.substituted
}

///|
pub fn QDS::blocked(self : QDS) -> Bool {
  self.blocked
}

///|
pub fn QDS::overflow(self : QDS) -> Bool {
  self.overflow
}

///|
pub fn QDS::to_byte(self : QDS) -> Byte {
  let mut val = 0
  if self.invalid {
    val = val | 0x80
  }
  if self.not_topical {
    val = val | 0x40
  }
  if self.substituted {
    val = val | 0x20
  }
  if self.blocked {
    val = val | 0x10
  }
  if self.overflow {
    val = val | 0x01
  }
  val.to_byte()
}

///|
pub fn QDS::from_byte(b : Byte) -> QDS {
  let v = b.to_int()
  {
    invalid: (v & 0x80) != 0,
    not_topical: (v & 0x40) != 0,
    substituted: (v & 0x20) != 0,
    blocked: (v & 0x10) != 0,
    overflow: (v & 0x01) != 0,
  }
}

// Single-Point Information Quality (SIQ)

///|
pub struct SIQ {
  value : Bool // SPI (bit 0): false=off, true=on
  invalid : Bool // IV (bit 7)
  not_topical : Bool // NT (bit 6)
  substituted : Bool // SB (bit 5)
  blocked : Bool // BL (bit 4)
} derive(Debug, Eq)

///|
pub fn SIQ::create(
  value? : Bool = false,
  invalid? : Bool = false,
  not_topical? : Bool = false,
  substituted? : Bool = false,
  blocked? : Bool = false,
) -> SIQ {
  { value, invalid, not_topical, substituted, blocked }
}

///|
pub fn SIQ::value(self : SIQ) -> Bool {
  self.value
}

///|
pub fn SIQ::invalid(self : SIQ) -> Bool {
  self.invalid
}

///|
pub fn SIQ::to_byte(self : SIQ) -> Byte {
  let mut val = if self.value { 1 } else { 0 }
  if self.invalid {
    val = val | 0x80
  }
  if self.not_topical {
    val = val | 0x40
  }
  if self.substituted {
    val = val | 0x20
  }
  if self.blocked {
    val = val | 0x10
  }
  val.to_byte()
}

///|
pub fn SIQ::from_byte(b : Byte) -> SIQ {
  let v = b.to_int()
  {
    value: (v & 0x01) != 0,
    invalid: (v & 0x80) != 0,
    not_topical: (v & 0x40) != 0,
    substituted: (v & 0x20) != 0,
    blocked: (v & 0x10) != 0,
  }
}

// Double-Point Information Quality (DIQ)

///|
pub struct DIQ {
  dpi : Int // DPI (bits 0..1): 0=indeterminate, 1=off, 2=on, 3=indeterminate
  invalid : Bool // IV (bit 7)
  not_topical : Bool // NT (bit 6)
  substituted : Bool // SB (bit 5)
  blocked : Bool // BL (bit 4)
} derive(Debug, Eq)

///|
pub fn DIQ::create(
  dpi? : Int = 0,
  invalid? : Bool = false,
  not_topical? : Bool = false,
  substituted? : Bool = false,
  blocked? : Bool = false,
) -> DIQ {
  { dpi, invalid, not_topical, substituted, blocked }
}

///|
pub fn DIQ::dpi(self : DIQ) -> Int {
  self.dpi
}

///|
pub fn DIQ::invalid(self : DIQ) -> Bool {
  self.invalid
}

///|
pub fn DIQ::to_byte(self : DIQ) -> Byte {
  let mut val = self.dpi & 0x03
  if self.invalid {
    val = val | 0x80
  }
  if self.not_topical {
    val = val | 0x40
  }
  if self.substituted {
    val = val | 0x20
  }
  if self.blocked {
    val = val | 0x10
  }
  val.to_byte()
}

///|
pub fn DIQ::from_byte(b : Byte) -> DIQ {
  let v = b.to_int()
  {
    dpi: v & 0x03,
    invalid: (v & 0x80) != 0,
    not_topical: (v & 0x40) != 0,
    substituted: (v & 0x20) != 0,
    blocked: (v & 0x10) != 0,
  }
}

// Single Command Qualifier (SCO / DCO)

///|
pub struct CommandQualifier {
  state : Bool // Command state: false=OFF/DESELECT, true=ON/SELECT
  select_execute : Bool // SE (bit 7): false=EXECUTE, true=SELECT
  pulse_duration : Int // QU (bits 2..6): 0=no pulse, 1=short pulse, 2=long pulse, 3=persistent
} derive(Debug, Eq)

///|
pub fn CommandQualifier::create(
  state? : Bool = false,
  select_execute? : Bool = false,
  pulse_duration? : Int = 0,
) -> CommandQualifier {
  { state, select_execute, pulse_duration }
}

///|
pub fn CommandQualifier::state(self : CommandQualifier) -> Bool {
  self.state
}

///|
pub fn CommandQualifier::select_execute(self : CommandQualifier) -> Bool {
  self.select_execute
}

///|
pub fn CommandQualifier::pulse_duration(self : CommandQualifier) -> Int {
  self.pulse_duration
}

///|
pub fn CommandQualifier::to_byte(self : CommandQualifier) -> Byte {
  let mut val = if self.state { 1 } else { 0 }
  let qu = (self.pulse_duration & 0x1F) << 2
  val = val | qu
  if self.select_execute {
    val = val | 0x80
  }
  val.to_byte()
}

///|
pub fn CommandQualifier::from_byte(b : Byte) -> CommandQualifier {
  let v = b.to_int()
  {
    state: (v & 0x01) != 0,
    select_execute: (v & 0x80) != 0,
    pulse_duration: (v >> 2) & 0x1F,
  }
}
