# MoonBit IEC 60870-5-104

[![CI](https://github.com/dgmlbtttt/moonbit-iec104/actions/workflows/ci.yml/badge.svg)](https://github.com/dgmlbtttt/moonbit-iec104/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

A pure MoonBit IEC 60870-5-104 telecontrol library with APCI/ASDU codecs, link state handling, bounded event delivery, master/slave helpers, and deterministic substation simulation. It is suitable for SCADA integration prototypes, edge telemetry adapters, protocol experiments, and reproducible test fixtures. It does not open sockets itself.

## Features

- APCI I/S/U frames, incremental stream reassembly, structured diagnostics, and modulo-15-bit sequence windows.
- ASDU headers, information elements, CP24/CP56 time tags, quality and address validation, object layouts, bounded batches, and codec registration.
- Master GI tracking, telemetry freshness/quality storage, command retry/history, and link health counters.
- Slave point snapshots, bounded spontaneous events, select-before-execute control, and alarm history.
- Deterministic 110 kV substation, PV, BESS, protection, scenario, dispatch, replay, and benchmark components.

## Repository layout

| Path | Responsibility |
| --- | --- |
| `src/utils` | Buffers, readers, checksums, bit operations, bounded buffers, retry utilities. |
| `src/types` | IEC identifiers, addresses, time tags, quality, limits, catalogs, validation. |
| `src/apdu` | APCI frames, codecs, stream decoder, diagnostics, sequence windows. |
| `src/asdu` | ASDU headers, information elements, file transfer, layouts, batches, registry. |
| `src/state_machine` | Connection states, events, and transition audit history. |
| `src/timer` | Protocol timers and deterministic deadlines. |
| `src/master` | Master node, GI session, telemetry, command queue/history, health. |
| `src/slave` | RTU node, point database, snapshots, events, control policy, alarms. |
| `src/simulation` | Substation, microgrid, protection, scenarios, dispatch, replay, limits. |
| `cmd/main` | Runnable integration demonstration and native APCI benchmark. |

## Quick start

Install the current stable MoonBit toolchain, then run:

```bash
moon version --all
moon update
moon fmt --check
moon check --deny-warn --target all
moon test --deny-warn --target wasm-gc
```

On Unix-like systems, the native test and demonstration can also be run:

```bash
moon test --deny-warn --target native
moon run --target native cmd/main
```

The CLI exercises link startup, general interrogation, telemetry, protection, remote control, and the codec benchmark. The benchmark prints operation count, elapsed microseconds, and throughput measured during that run; results are machine-dependent and are not hard-coded here.

## Library usage

```moonbit
import {
  "dgmlbtttt/iec104/src/apdu"
  "dgmlbtttt/iec104/src/types"
}

fn encode_status() -> Array[Byte] {
  @apdu.encode_apdu(@apdu.APDU::make_s(12))
}
```

For transport input, create `@apdu.APDUStreamDecoder`, pass each received byte chunk to `push`, and handle the complete frames returned. Malformed input is returned as an error without unbounded buffering.

## Testing and quality gates

CI runs the stable toolchain on Ubuntu, macOS, and Windows. It checks all targets, runs the complete test suite, formats the project, regenerates public interfaces, and verifies generated changes are committed.

```bash
moon check --deny-warn --target all
moon test --deny-warn --target wasm-gc
moon fmt
moon info
moon coverage analyze
```

Count actual MoonBit source lines without interfaces or build artifacts:

```powershell
$lines = rg --files -g '*.mbt' | ForEach-Object { (Get-Content -LiteralPath $_ | Measure-Object -Line).Lines }
($lines | Measure-Object -Sum).Sum
```

## Publishing

The module namespace is `dgmlbtttt/iec104`, matching the GitHub account namespace used for Mooncakes publishing. After local checks, authenticate with `moon login` and run:

```bash
moon publish
```

A manual GitHub Actions workflow provides a guarded publish job using a `MOONCAKES_TOKEN` secret.

## License

Apache License 2.0. See [LICENSE](LICENSE).
