// Generic deterministic retry budget used by transport-facing adapters.

///|
pub struct RetryBudget {
  limit : Int
  mut attempts : Int
} derive(Debug, Eq)

///|
pub fn RetryBudget::new(limit : Int) -> RetryBudget {
  { limit: if limit < 1 { 1 } else { limit }, attempts: 0 }
}

///|
pub fn RetryBudget::limit(self : RetryBudget) -> Int {
  self.limit
}

///|
pub fn RetryBudget::attempts(self : RetryBudget) -> Int {
  self.attempts
}

///|
pub fn RetryBudget::remaining(self : RetryBudget) -> Int {
  self.limit - self.attempts
}

///|
pub fn RetryBudget::take(self : RetryBudget) -> Bool {
  if self.attempts >= self.limit {
    false
  } else {
    self.attempts += 1
    true
  }
}

///|
pub fn RetryBudget::reset(self : RetryBudget) -> Unit {
  self.attempts = 0
}

///|
pub fn RetryBudget::exhausted(self : RetryBudget) -> Bool {
  self.attempts >= self.limit
}
