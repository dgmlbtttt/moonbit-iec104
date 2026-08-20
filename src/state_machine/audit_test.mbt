///|
test "connection audit log is bounded and queryable" {
  let audit = ConnectionAuditLog::new(2)
  audit.record(
    @state_machine.LinkStatus::unconnected(),
    @state_machine.LinkStatus::connecting(),
    10L,
  )
  audit.record(
    @state_machine.LinkStatus::connecting(),
    @state_machine.LinkStatus::stopped(),
    20L,
  )
  audit.record(
    @state_machine.LinkStatus::stopped(),
    @state_machine.LinkStatus::active(),
    30L,
  )
  assert_eq(audit.len(), 2)
  assert_eq(audit.latest().unwrap().at_ms(), 30L)
  assert_eq(audit.transitions_from(@state_machine.LinkStatus::connecting()), 1)
}
