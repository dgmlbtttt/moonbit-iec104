// MoonBit IEC 104 - Protocol Timer Config and Management (t1, t2, t3)

///|
pub struct TimerConfig {
  t1_seconds : Int // t1: Response timeout (default 15s)
  t2_seconds : Int // t2: S-Frame ack timeout (default 10s)
  t3_seconds : Int // t3: Idle keepalive timeout (default 20s)
} derive(Debug, Eq)

///|
pub fn TimerConfig::default() -> TimerConfig {
  { t1_seconds: 15, t2_seconds: 10, t3_seconds: 20 }
}

///|
pub fn TimerConfig::create(
  t1? : Int = 15,
  t2? : Int = 10,
  t3? : Int = 20,
) -> TimerConfig {
  { t1_seconds: t1, t2_seconds: t2, t3_seconds: t3 }
}

///|
pub fn TimerConfig::t1_seconds(self : TimerConfig) -> Int {
  self.t1_seconds
}

///|
pub fn TimerConfig::t2_seconds(self : TimerConfig) -> Int {
  self.t2_seconds
}

///|
pub fn TimerConfig::t3_seconds(self : TimerConfig) -> Int {
  self.t3_seconds
}

///|
pub enum TimerExpired {
  ExpiredT1
  ExpiredT2
  ExpiredT3
} derive(Debug, Eq)

///|
pub fn TimerExpired::expired_t1() -> TimerExpired {
  ExpiredT1
}

///|
pub fn TimerExpired::expired_t2() -> TimerExpired {
  ExpiredT2
}

///|
pub fn TimerExpired::expired_t3() -> TimerExpired {
  ExpiredT3
}

///|
pub struct ProtocolTimerManager {
  config : TimerConfig
  mut t1_elapsed_ms : Int
  mut t2_elapsed_ms : Int
  mut t3_elapsed_ms : Int
  mut t1_active : Bool
  mut t2_active : Bool
  mut t3_active : Bool
} derive(Debug, Eq)

///|
pub fn ProtocolTimerManager::new(
  config? : TimerConfig = TimerConfig::default(),
) -> ProtocolTimerManager {
  {
    config,
    t1_elapsed_ms: 0,
    t2_elapsed_ms: 0,
    t3_elapsed_ms: 0,
    t1_active: false,
    t2_active: false,
    t3_active: true,
  }
}

///|
pub fn ProtocolTimerManager::start_t1(self : ProtocolTimerManager) -> Unit {
  self.t1_elapsed_ms = 0
  self.t1_active = true
}

///|
pub fn ProtocolTimerManager::stop_t1(self : ProtocolTimerManager) -> Unit {
  self.t1_elapsed_ms = 0
  self.t1_active = false
}

///|
pub fn ProtocolTimerManager::start_t2(self : ProtocolTimerManager) -> Unit {
  self.t2_elapsed_ms = 0
  self.t2_active = true
}

///|
pub fn ProtocolTimerManager::stop_t2(self : ProtocolTimerManager) -> Unit {
  self.t2_elapsed_ms = 0
  self.t2_active = false
}

///|
pub fn ProtocolTimerManager::reset_t3(self : ProtocolTimerManager) -> Unit {
  self.t3_elapsed_ms = 0
  self.t3_active = true
}

///|
pub fn ProtocolTimerManager::tick(
  self : ProtocolTimerManager,
  delta_ms : Int,
) -> Array[TimerExpired] {
  let expired : Array[TimerExpired] = []

  if self.t1_active {
    self.t1_elapsed_ms = self.t1_elapsed_ms + delta_ms
    if self.t1_elapsed_ms >= self.config.t1_seconds() * 1000 {
      expired.push(ExpiredT1)
      self.t1_elapsed_ms = 0
    }
  }

  if self.t2_active {
    self.t2_elapsed_ms = self.t2_elapsed_ms + delta_ms
    if self.t2_elapsed_ms >= self.config.t2_seconds() * 1000 {
      expired.push(ExpiredT2)
      self.t2_elapsed_ms = 0
    }
  }

  if self.t3_active {
    self.t3_elapsed_ms = self.t3_elapsed_ms + delta_ms
    if self.t3_elapsed_ms >= self.config.t3_seconds() * 1000 {
      expired.push(ExpiredT3)
      self.t3_elapsed_ms = 0
    }
  }

  expired
}
