///|
test "command history retains recent outcomes" {
  let history = CommandHistory::new(2)
  history.append(
    CommandHistoryEntry::new(
      id=1,
      ioa=1,
      outcome=CommandOutcome::accepted(),
      at_ms=1L,
    ),
  )
  history.append(
    CommandHistoryEntry::new(
      id=2,
      ioa=2,
      outcome=CommandOutcome::completed(),
      at_ms=2L,
    ),
  )
  history.append(
    CommandHistoryEntry::new(
      id=3,
      ioa=3,
      outcome=CommandOutcome::timed_out(),
      at_ms=3L,
    ),
  )
  assert_eq(history.len(), 2)
  assert_eq(history.count_outcome(CommandOutcome::completed()), 1)
  assert_eq(history.entries()[0].id(), 2)
}
