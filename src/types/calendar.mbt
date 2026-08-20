// Calendar validation helpers for CP56Time2a consumers.

///|
pub fn is_leap_year(year : Int) -> Bool {
  year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}

///|
pub fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    2 => if is_leap_year(year) { 29 } else { 28 }
    4 | 6 | 9 | 11 => 30
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    _ => 0
  }
}

///|
pub fn validate_calendar_date(
  year : Int,
  month : Int,
  day : Int,
) -> Result[Unit, String] {
  let max_day = days_in_month(year, month)
  if year < 0 || year > 99 {
    return Err("calendar year must be in 0..99")
  }
  if max_day == 0 {
    return Err("calendar month must be in 1..12")
  }
  if day < 1 || day > max_day {
    return Err("calendar day is outside month range")
  }
  Ok(())
}

///|
pub fn CP56Time2a::validate_calendar(self : CP56Time2a) -> Result[Unit, String] {
  match self.validate() {
    Err(e) => Err(e)
    Ok(_) =>
      validate_calendar_date(self.year(), self.month(), self.day_of_month())
  }
}
