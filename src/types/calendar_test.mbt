///|
test "calendar helpers handle leap days" {
  assert_eq(days_in_month(24, 2), 29)
  assert_eq(days_in_month(25, 2), 28)
  assert_true(validate_calendar_date(24, 2, 29) is Ok(_))
  assert_true(validate_calendar_date(25, 2, 29) is Err(_))
  let tag = CP56Time2a::create(year=24, month=2, day_of_month=29)
  assert_true(tag.validate_calendar() is Ok(_))
}
