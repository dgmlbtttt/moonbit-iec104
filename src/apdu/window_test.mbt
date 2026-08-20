///|
test "reliable sequence window enforces k and acknowledges cumulatively" {
  let window = ReliableSequenceWindow::new(max_send=2, ack_threshold=2)
  assert_eq(window.reserve_send().unwrap(), 0)
  assert_eq(window.reserve_send().unwrap(), 1)
  assert_true(window.reserve_send() is Err(_))
  assert_true(window.receive(0) is Ok(_))
  assert_true(window.receive(1) is Ok(_))
  assert_true(window.should_ack())
  assert_true(window.acknowledge(1) is Ok(_))
  assert_eq(window.pending_send(), 1)
}

///|
test "reliable sequence window handles modulo 15-bit wrap" {
  let window = ReliableSequenceWindow::new(max_send=4, ack_threshold=2)
  window.set_send_sequence(32767)
  assert_eq(window.reserve_send().unwrap(), 32767)
  assert_eq(window.reserve_send().unwrap(), 0)
  window.set_receive_sequence(32767)
  assert_true(window.receive(32767) is Ok(_))
  assert_true(window.receive(0) is Ok(_))
  assert_eq(window.receive_next(), 1)
}
