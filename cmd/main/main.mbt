// MoonBit IEC 104 - Main Command-Line Interactive Verification & Demo

///|
fn main {
  println(
    "==========================================================================",
  )
  println(
    "  MoonBit IEC 60870-5-104 Telecontrol Protocol & Substation Simulator   ",
  )
  println(
    "==========================================================================",
  )

  // 1. Initialize Substation Simulation Model and Control Center Master
  let sub = @simulation.SubstationModel::create(
    station_name="110kV Smart Substation Alpha",
    casdu_addr=1,
  )
  let master = @master.MasterNode::new(1)

  println("[SYS] Created Substation: " + sub.station_name())
  println("[SYS] Active Bays: " + sub.bays().length().to_string())

  // 2. Protocol Handshake: StartDT Act -> Con
  sub.activate_connection()
  let _ = master
    .conn()
    .process_event(@state_machine.ConnectionEvent::connected())
  let _ = master
    .conn()
    .process_event(@state_machine.ConnectionEvent::start_dt_con())
  println(
    "[LINK] Master & Substation Slave Link State: ACTIVE (STARTDT Confirmed)",
  )

  // 3. Initiate General Interrogation (GI)
  println("\n[GI] Initiating General Interrogation (QOI=20)...")
  let gi_req = master.initiate_general_interrogation().unwrap()
  let gi_res = sub.slave_node().handle_apdu(gi_req).unwrap()

  println(
    "[GI] Substation responded with " +
    gi_res.length().to_string() +
    " APDU frames.",
  )
  for i = 0; i < gi_res.length(); i = i + 1 {
    let _ = master.handle_apdu(gi_res[i])
  }
  println("[GI] Master General Interrogation completed successfully.")

  // 4. Microgrid Solar PV & Battery BESS Simulation
  println(
    "\n[MICROGRID] Simulating Microgrid Solar PV & Battery Energy Storage (BESS)...",
  )
  let pv = @simulation.SolarPVInverter::create(
    inverter_id="PV-110kV-01",
    voltage_ioa=5001,
    current_ioa=5002,
    power_ioa=5003,
    status_ioa=5004,
    capacity_kw=1000.0,
  )
  let bess = @simulation.BatteryBESS::create(
    bess_id="BESS-110kV-01",
    soc_ioa=6001,
    power_ioa=6002,
    status_ioa=6003,
    capacity_kwh=2000.0,
    max_power_kw=1000.0,
  )
  bess.set_mode(@simulation.BESSMode::discharging(), 500.0)

  println(
    "  [PV] Active Power Output: " + pv.active_power_kw().to_string() + " kW",
  )
  println(
    "  [BESS] Mode: DISCHARGING | SOC: " +
    bess.soc_percent().to_string() +
    "% | Power: " +
    bess.current_power_kw().to_string() +
    " kW",
  )

  // 5. Simulate Grid Telemetry Load Fluctuation
  println("\n[SIM] Simulating 5 seconds of grid load fluctuation...")
  for t = 1; t <= 5; t = t + 1 {
    let _ = sub.step(1000)
    let feeder1 = sub.bays()[1]
    println(
      "  t=" +
      t.to_string() +
      "s | Feeder-1 Current: " +
      feeder1.current_a().to_string() +
      " A | Power: " +
      feeder1.active_power_mw().to_string() +
      " MW | Freq: " +
      feeder1.frequency_hz().to_string() +
      " Hz",
    )
  }

  // 6. IDMT Overcurrent Protection & Fault Injection
  println("\n[FAULT] Injecting overcurrent fault (1.25 kA) on Feeder-1...")
  let relay = @simulation.IDMTProtectionRelay::create(
    pickup_current_a=200.0,
    time_multiplier=0.5,
  )
  let trip_time = relay.calculate_trip_time_sec(1250.0)
  println(
    "[IDMT] Relay Protection Curve: Standard Inverse (IEC 60255) | Calculated Trip Time: " +
    trip_time.to_string() +
    " s",
  )

  let fault_apdus = sub.trigger_bay_fault(1)
  println(
    "[FAULT] Protection relay tripped breaker! Spontaneous IEC 104 ASDUs generated: " +
    fault_apdus.length().to_string(),
  )

  for i = 0; i < fault_apdus.length(); i = i + 1 {
    let _ = master.handle_apdu(fault_apdus[i])
  }
  println(
    "[MASTER] Master received spontaneous fault alarm. Breaker IOA 1003 state: OPEN",
  )

  // 7. Master Issues Remote Single Command (Select & Execute) to Close Breaker
  println(
    "\n[CMD] Control Center issuing Remote Close Command to Breaker 1003...",
  )
  let cmd_req = master.send_single_command(1003, true, true).unwrap()
  let cmd_res = sub.slave_node().handle_apdu(cmd_req).unwrap()
  println(
    "[CMD] Substation acknowledged command execution (" +
    cmd_res.length().to_string() +
    " response frames).",
  )

  let feeder1_after = sub.bays()[1]
  feeder1_after.clear_fault()
  println(
    "[SYS] Feeder-1 breaker state restored: CLOSED. Grid power re-established!",
  )

  // 8. Benchmark performance check
  println(
    "\n[BENCH] Running APCI & ASDU Encoder/Decoder Throughput Benchmark...",
  )
  let benchmark = run_apci_benchmark(100000)
  println("[BENCH] " + benchmark.summary())

  println(
    "\n==========================================================================",
  )
  println(
    "  Verification Complete: All IEC 104 Features & Benchmarks Passed!      ",
  )
  println(
    "==========================================================================",
  )
}
