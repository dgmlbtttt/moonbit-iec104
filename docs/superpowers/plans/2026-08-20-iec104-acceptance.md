# IEC 104 Acceptance Enhancement Implementation Plan

> **For agentic workers:** Execute task-by-task with a fresh verification gate after each task.

**Goal:** Extend the existing pure MoonBit IEC 104 library with production-relevant protocol boundaries, deterministic scenario tooling, honest benchmarks, and acceptance-grade repository engineering.

**Architecture:** Preserve existing package boundaries and public APIs. Add focused files for streaming APDU input, time-tagged ASDU values, slave/master event flow, simulation scenarios, and CLI benchmarking; validate every addition through black-box tests before refactoring.

**Tech Stack:** MoonBit stable toolchain, `moon check/test/fmt/info`, GitHub Actions, Apache-2.0.

## Global Constraints

- Do not modify `PROPOSAL.md` or overwrite its pre-existing user change.
- Count only actual `.mbt` source lines; exclude `.mbti`, `_build`, and generated artifacts.
- Do not hard-code benchmark claims; print measurements produced by the current run.
- Keep the package namespace `dgmlbtttt/iec104` and avoid new third-party dependencies.
- Keep README free of internal submission, applicant, completion, and contributor statements.

### Task 1: Persistent project records and APDU stream decoder

**Files:** Create `src/apdu/stream.mbt`, `src/apdu/stream_test.mbt`; modify `src/apdu/moon.pkg` only if required.

- [ ] Add tests for split header/body, multiple frames in one chunk, noise prefix, zero length, over-limit length, and incomplete frame.
- [ ] Run `moon test src/apdu/stream_test.mbt --deny-warn` and verify the new tests fail for missing symbols.
- [ ] Implement bounded `APDUStreamDecoder` with `push(Array[Byte]) -> Result[Array[APDU], String]`, `pending_bytes() -> Int`, and `reset() -> Unit`, using existing `parse_apdu`.
- [ ] Re-run targeted tests, then `moon check --deny-warn`.

### Task 2: Time-tag and information-element boundary coverage

**Files:** Create focused files under `src/types` and `src/asdu`; modify corresponding test files.

- [ ] Add failing round-trip tests for CP24/CP56 valid limits and invalid minute/hour/day/month values.
- [ ] Add failing tests for time-tagged single point, normalized/scaled/float telemetry, bitstring, step position, and command qualifier boundaries.
- [ ] Implement only the minimal constructors/encoders/decoders needed by the tests, reusing `ByteBuffer` and existing ASDU dispatch.
- [ ] Verify targeted ASDU/types tests and all current tests.

### Task 3: Slave event queue and master interrogation flow

**Files:** Create `src/slave/event_queue.mbt`, `src/slave/event_queue_test.mbt`, `src/master/interrogation.mbt`, `src/master/interrogation_test.mbt`; modify existing point database/node files only for integration.

- [ ] Add tests for FIFO ordering, bounded overflow behavior, spontaneous event creation, point snapshots, GI batches, activation confirmation, and termination.
- [ ] Run targeted tests red.
- [ ] Implement bounded event storage and deterministic GI batch state without changing existing constructors.
- [ ] Verify targeted tests, full `moon test`, and `moon check --target all`.

### Task 4: Deterministic simulation scenario and benchmark harness

**Files:** Create `src/simulation/scenario.mbt`, `src/simulation/scenario_test.mbt`, `cmd/main/benchmark.mbt`; modify `cmd/main/main.mbt` to expose the command without duplicating simulation logic.

- [ ] Add tests for a fixed-step normal run, overcurrent trip/recovery, event count, and repeatability.
- [ ] Run red tests.
- [ ] Implement a scenario runner with explicit seed/configuration, event records, and bounded steps; implement benchmark output with toolchain version, operation count, elapsed time, and operations/sec.
- [ ] Verify native CLI execution and both target test modes.

### Task 5: Repository documentation, CI, metadata, and release workflow

**Files:** Modify `README.md`, `README.mbt.md`, `moon.mod`, `.github/workflows/ci.yml`; create `.github/workflows/publish.yml`; do not modify `PROPOSAL.md`.

- [ ] Replace stale scale/test/benchmark claims with command-derived instructions and current measured output format.
- [ ] Set repository URL, description, keywords, and stable MoonBit metadata without changing package namespace.
- [ ] Align CI with MoonBit community checks: three OSes, `moon update`, all-target check/test, formatting, `moon info`, and clean diff verification.
- [ ] Add a manual publish workflow using a secret and cleanup-safe credentials handling.
- [ ] Verify README code blocks, workflow YAML structure, and license links.

### Task 6: Full verification, self-review, commit, push, and publish

**Files:** Generated `.mbti` updates as produced by `moon info`; optional `docs/acceptance-check.md` with evidence.

- [ ] Run `moon fmt`, `moon info`, `moon fmt --check`, `moon check --deny-warn --target all`, `moon test --deny-warn --target all`, and native CLI benchmark.
- [ ] Count `.mbt` lines with an explicit PowerShell command and capture real output.
- [ ] Run repository self-review against structure, README, license, history, default branch, MoonBit scale, CI, and Mooncakes readiness.
- [ ] Inspect `git diff`, ensure `PROPOSAL.md` remains untouched, commit meaningful changes, push `main` to GitHub, verify remote default branch, then run `moon publish` using the already authorized local account.
