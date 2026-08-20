// Deterministic t1/t2/t3 deadline registry for event-loop integrations.

///|
pub enum TimerKind {
  T1
  T2
  T3
} derive(Debug, Eq)

///|
pub fn TimerKind::t1() -> TimerKind {
  T1
}

///|
pub fn TimerKind::t2() -> TimerKind {
  T2
}

///|
pub fn TimerKind::t3() -> TimerKind {
  T3
}

///|
pub struct TimerDeadline {
  kind : TimerKind
  deadline_ms : Int64
} derive(Debug, Eq)

///|
pub fn TimerDeadline::kind(self : TimerDeadline) -> TimerKind {
  self.kind
}

///|
pub fn TimerDeadline::deadline_ms(self : TimerDeadline) -> Int64 {
  self.deadline_ms
}

///|
pub struct ProtocolTimerScheduler {
  t1_ms : Int64
  t2_ms : Int64
  t3_ms : Int64
  mut active : Array[TimerDeadline]
  mut last_now_ms : Int64
} derive(Debug, Eq)

///|
pub fn ProtocolTimerScheduler::new(
  t1_ms? : Int64 = 15000L,
  t2_ms? : Int64 = 10000L,
  t3_ms? : Int64 = 20000L,
) -> ProtocolTimerScheduler {
  {
    t1_ms: if t1_ms < 1L {
      1L
    } else {
      t1_ms
    },
    t2_ms: if t2_ms < 1L {
      1L
    } else {
      t2_ms
    },
    t3_ms: if t3_ms < 1L {
      1L
    } else {
      t3_ms
    },
    active: [],
    last_now_ms: 0L,
  }
}

///|
fn ProtocolTimerScheduler::duration(
  self : ProtocolTimerScheduler,
  kind : TimerKind,
) -> Int64 {
  match kind {
    T1 => self.t1_ms
    T2 => self.t2_ms
    T3 => self.t3_ms
  }
}

///|
pub fn ProtocolTimerScheduler::active_count(
  self : ProtocolTimerScheduler,
) -> Int {
  self.active.length()
}

///|
pub fn ProtocolTimerScheduler::is_active(
  self : ProtocolTimerScheduler,
  kind : TimerKind,
) -> Bool {
  for timer in self.active {
    if timer.kind == kind {
      return true
    }
  }
  false
}

///|
pub fn ProtocolTimerScheduler::arm(
  self : ProtocolTimerScheduler,
  kind : TimerKind,
  now_ms : Int64,
) -> Result[Unit, String] {
  if now_ms < self.last_now_ms {
    return Err("timer clock moved backwards")
  }
  if self.is_active(kind) {
    return Err("protocol timer is already active")
  }
  self.last_now_ms = now_ms
  self.active.push({ kind, deadline_ms: now_ms + self.duration(kind) })
  Ok(())
}

///|
pub fn ProtocolTimerScheduler::cancel(
  self : ProtocolTimerScheduler,
  kind : TimerKind,
) -> Bool {
  let mut found = false
  let remaining : Array[TimerDeadline] = []
  for timer in self.active {
    if timer.kind == kind {
      found = true
    } else {
      remaining.push(timer)
    }
  }
  self.active = remaining
  found
}

///|
pub fn ProtocolTimerScheduler::expired_at(
  self : ProtocolTimerScheduler,
  now_ms : Int64,
) -> Result[Array[TimerKind], String] {
  if now_ms < self.last_now_ms {
    return Err("timer clock moved backwards")
  }
  self.last_now_ms = now_ms
  let expired : Array[TimerKind] = []
  let remaining : Array[TimerDeadline] = []
  for timer in self.active {
    if timer.deadline_ms <= now_ms {
      expired.push(timer.kind)
    } else {
      remaining.push(timer)
    }
  }
  self.active = remaining
  Ok(expired)
}
