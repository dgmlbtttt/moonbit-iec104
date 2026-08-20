///|
test "command queue retries and completes in FIFO order" {
  let queue = ControlCommandQueue::new(2, 3)
  assert_true(queue.enqueue(1001, true) is Ok(_))
  assert_true(queue.enqueue(1002, false) is Ok(_))
  assert_true(queue.enqueue(1003, true) is Err(_))
  assert_eq(queue.next().unwrap().ioa(), 1001)
  assert_true(queue.retry_current())
  assert_true(queue.retry_current())
  assert_true(queue.retry_current())
  assert_false(queue.retry_current())
  assert_true(queue.complete_current())
  assert_eq(queue.next().unwrap().ioa(), 1002)
}
