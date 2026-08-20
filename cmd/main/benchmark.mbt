// Reproducible native benchmark for the public APCI codec path.

///|
pub struct BenchmarkResult {
  operations : Int
  successful : Int
  elapsed_us : Double
} derive(Debug, Eq)

///|
pub fn BenchmarkResult::operations(self : BenchmarkResult) -> Int {
  self.operations
}

///|
pub fn BenchmarkResult::successful(self : BenchmarkResult) -> Int {
  self.successful
}

///|
pub fn BenchmarkResult::elapsed_us(self : BenchmarkResult) -> Double {
  self.elapsed_us
}

///|
pub fn BenchmarkResult::operations_per_second(self : BenchmarkResult) -> Double {
  if self.elapsed_us <= 0.0 {
    0.0
  } else {
    self.successful.to_double() * 1000000.0 / self.elapsed_us
  }
}

///|
pub fn BenchmarkResult::summary(self : BenchmarkResult) -> String {
  "operations=" +
  self.operations.to_string() +
  ", successful=" +
  self.successful.to_string() +
  ", elapsed_us=" +
  self.elapsed_us.to_string() +
  ", operations_per_second=" +
  self.operations_per_second().to_string()
}

///|
pub fn run_apci_benchmark(iterations : Int) -> BenchmarkResult {
  let count = if iterations < 0 { 0 } else { iterations }
  let start = @bench.monotonic_clock_start()
  let mut successful = 0
  for i = 0; i < count; i = i + 1 {
    let frame = @apdu.APDU::make_s(i % 32768)
    let bytes = @apdu.encode_apdu(frame)
    match @apdu.parse_apdu(bytes) {
      Ok(_) => successful = successful + 1
      Err(_) => ()
    }
  }
  {
    operations: count,
    successful,
    elapsed_us: @bench.monotonic_clock_end(start),
  }
}

///|
test "benchmark reports successful codec operations" {
  let result = run_apci_benchmark(32)
  assert_eq(result.operations(), 32)
  assert_eq(result.successful(), 32)
  assert_true(result.elapsed_us() >= 0.0)
  assert_true(result.summary().contains("operations_per_second="))
}
