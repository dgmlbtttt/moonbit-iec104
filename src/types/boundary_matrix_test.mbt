///|
test "IOA checked constructor accepts all representative boundaries" {
  let valid : Array[Int] = [0, 1, 255, 65535, 0xFFFFFF]
  for value in valid {
    assert_true(IOA::try_new(value) is Ok(_))
  }
  let invalid : Array[Int] = [-100, -1, 0x1000000, 0x7FFFFFFF]
  for value in invalid {
    assert_true(IOA::try_new(value) is Err(_))
  }
}

///|
test "CASDU checked constructor distinguishes station and broadcast" {
  for value = 1; value <= 3; value = value + 1 {
    assert_true(CASDU::try_new(value) is Ok(_))
  }
  assert_true(CASDU::try_new(0) is Err(_))
  let broadcast = CASDU::try_new(0xFFFF).unwrap()
  assert_true(broadcast.is_broadcast())
}

///|
test "CP24 millisecond and minute boundaries are explicit" {
  assert_true(CP24Time2a::create(milliseconds=0, minutes=0).validate() is Ok(_))
  assert_true(
    CP24Time2a::create(milliseconds=59999, minutes=59).validate() is Ok(_),
  )
  assert_true(CP24Time2a::create(milliseconds=-1).validate() is Err(_))
  assert_true(CP24Time2a::create(milliseconds=60000).validate() is Err(_))
  assert_true(CP24Time2a::create(minutes=-1).validate() is Err(_))
  assert_true(CP24Time2a::create(minutes=60).validate() is Err(_))
}

///|
test "CP56 calendar boundaries cover every invalid field" {
  assert_true(CP56Time2a::create(hours=-1).validate() is Err(_))
  assert_true(CP56Time2a::create(hours=24).validate() is Err(_))
  assert_true(CP56Time2a::create(day_of_week=0).validate() is Err(_))
  assert_true(CP56Time2a::create(day_of_week=8).validate() is Err(_))
  assert_true(CP56Time2a::create(day_of_month=0).validate() is Err(_))
  assert_true(CP56Time2a::create(month=0).validate() is Err(_))
  assert_true(CP56Time2a::create(month=13).validate() is Err(_))
  assert_true(CP56Time2a::create(year=-1).validate() is Err(_))
  assert_true(CP56Time2a::create(year=100).validate() is Err(_))
}
