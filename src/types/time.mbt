// MoonBit IEC 104 - Protocol Time Tag Representations (CP56Time2a & CP24Time2a)

// 7-Byte Full Time Tag (CP56Time2a)
///|
pub struct CP56Time2a {
  milliseconds : Int // 0..59999 (2 bytes LE)
  minutes : Int // 0..59 (6 bits)
  invalid : Bool // IV (bit 7 of minute byte)
  substituted : Bool // SU (bit 6 of minute byte)
  hours : Int // 0..23 (5 bits)
  day_of_week : Int // 1..7 (3 bits of hour/day byte)
  day_of_month : Int // 1..31 (5 bits)
  month : Int // 1..12 (4 bits)
  year : Int // 0..99 (7 bits)
} derive(Debug, Eq)

///|
pub fn CP56Time2a::create(
  milliseconds? : Int = 0,
  minutes? : Int = 0,
  invalid? : Bool = false,
  substituted? : Bool = false,
  hours? : Int = 0,
  day_of_week? : Int = 1,
  day_of_month? : Int = 1,
  month? : Int = 1,
  year? : Int = 26,
) -> CP56Time2a {
  {
    milliseconds,
    minutes,
    invalid,
    substituted,
    hours,
    day_of_week,
    day_of_month,
    month,
    year,
  }
}

///|
pub fn CP56Time2a::default() -> CP56Time2a {
  CP56Time2a::create()
}

///|
pub fn CP56Time2a::milliseconds(self : CP56Time2a) -> Int {
  self.milliseconds
}

///|
pub fn CP56Time2a::minutes(self : CP56Time2a) -> Int {
  self.minutes
}

///|
pub fn CP56Time2a::hours(self : CP56Time2a) -> Int {
  self.hours
}

///|
pub fn CP56Time2a::day_of_month(self : CP56Time2a) -> Int {
  self.day_of_month
}

///|
pub fn CP56Time2a::day_of_week(self : CP56Time2a) -> Int {
  self.day_of_week
}

///|
pub fn CP56Time2a::month(self : CP56Time2a) -> Int {
  self.month
}

///|
pub fn CP56Time2a::year(self : CP56Time2a) -> Int {
  self.year
}

///|
pub fn CP56Time2a::to_bytes(self : CP56Time2a) -> Array[Byte] {
  let res : Array[Byte] = Array::make(7, b'\x00')
  let ms = self.milliseconds & 0xFFFF
  res[0] = (ms & 0xFF).to_byte()
  res[1] = ((ms >> 8) & 0xFF).to_byte()

  let mut min_b = self.minutes & 0x3F
  if self.substituted {
    min_b = min_b | 0x40
  }
  if self.invalid {
    min_b = min_b | 0x80
  }
  res[2] = min_b.to_byte()

  let hr_b = self.hours & 0x1F
  res[3] = hr_b.to_byte()

  let day_b = (self.day_of_month & 0x1F) | ((self.day_of_week & 0x07) << 5)
  res[4] = day_b.to_byte()

  let mon_b = self.month & 0x0F
  res[5] = mon_b.to_byte()

  let yr_b = self.year & 0x7F
  res[6] = yr_b.to_byte()

  res
}

///|
pub fn CP56Time2a::from_bytes(
  bytes : Array[Byte],
) -> Result[CP56Time2a, String] {
  if bytes.length() < 7 {
    return Err("Invalid CP56Time2a length: expected 7 bytes")
  }
  let ms0 = bytes[0].to_int()
  let ms1 = bytes[1].to_int()
  let ms = ms0 | (ms1 << 8)

  let min_byte = bytes[2].to_int()
  let minutes = min_byte & 0x3F
  let substituted = (min_byte & 0x40) != 0
  let invalid = (min_byte & 0x80) != 0

  let hr_byte = bytes[3].to_int()
  let hours = hr_byte & 0x1F

  let day_byte = bytes[4].to_int()
  let day_of_month = day_byte & 0x1F
  let day_of_week = (day_byte >> 5) & 0x07

  let mon_byte = bytes[5].to_int()
  let month = mon_byte & 0x0F

  let yr_byte = bytes[6].to_int()
  let year = yr_byte & 0x7F

  Ok({
    milliseconds: ms,
    minutes,
    invalid,
    substituted,
    hours,
    day_of_week,
    day_of_month,
    month,
    year,
  })
}

///|
pub fn CP56Time2a::to_string(self : CP56Time2a) -> String {
  let yr_str = "20" +
    (if self.year < 10 {
      "0" + self.year.to_string()
    } else {
      self.year.to_string()
    })
  let mon_str = if self.month < 10 {
    "0" + self.month.to_string()
  } else {
    self.month.to_string()
  }
  let day_str = if self.day_of_month < 10 {
    "0" + self.day_of_month.to_string()
  } else {
    self.day_of_month.to_string()
  }
  let hr_str = if self.hours < 10 {
    "0" + self.hours.to_string()
  } else {
    self.hours.to_string()
  }
  let min_str = if self.minutes < 10 {
    "0" + self.minutes.to_string()
  } else {
    self.minutes.to_string()
  }
  let sec = self.milliseconds / 1000
  let sec_str = if sec < 10 { "0" + sec.to_string() } else { sec.to_string() }
  let ms_rem = self.milliseconds % 1000
  let ms_str = if ms_rem < 10 {
    "00" + ms_rem.to_string()
  } else if ms_rem < 100 {
    "0" + ms_rem.to_string()
  } else {
    ms_rem.to_string()
  }

  yr_str +
  "-" +
  mon_str +
  "-" +
  day_str +
  " " +
  hr_str +
  ":" +
  min_str +
  ":" +
  sec_str +
  "." +
  ms_str
}

// 3-Byte Short Time Tag (CP24Time2a)

///|
pub struct CP24Time2a {
  milliseconds : Int // 0..59999
  minutes : Int // 0..59
  invalid : Bool
} derive(Debug, Eq)

///|
pub fn CP24Time2a::create(
  milliseconds? : Int = 0,
  minutes? : Int = 0,
  invalid? : Bool = false,
) -> CP24Time2a {
  { milliseconds, minutes, invalid }
}

///|
pub fn CP24Time2a::to_bytes(self : CP24Time2a) -> Array[Byte] {
  let res : Array[Byte] = Array::make(3, b'\x00')
  let ms = self.milliseconds & 0xFFFF
  res[0] = (ms & 0xFF).to_byte()
  res[1] = ((ms >> 8) & 0xFF).to_byte()

  let mut min_b = self.minutes & 0x3F
  if self.invalid {
    min_b = min_b | 0x80
  }
  res[2] = min_b.to_byte()
  res
}

///|
pub fn CP24Time2a::from_bytes(
  bytes : Array[Byte],
) -> Result[CP24Time2a, String] {
  if bytes.length() < 3 {
    return Err("Invalid CP24Time2a length: expected 3 bytes")
  }
  let ms0 = bytes[0].to_int()
  let ms1 = bytes[1].to_int()
  let ms = ms0 | (ms1 << 8)

  let min_b = bytes[2].to_int()
  let minutes = min_b & 0x3F
  let invalid = (min_b & 0x80) != 0

  Ok({ milliseconds: ms, minutes, invalid })
}
