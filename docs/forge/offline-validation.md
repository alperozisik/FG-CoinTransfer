# Offline validation — 2026-11-20

Working source: 0.1.4 candidate, based on public commit `a910f00`. Public v0.1.4 Release was subsequently published and the downloaded asset was verified; Forge item 3794 was subsequently submitted and awaits approval/review, with the build queued for processing; the forum is published. See READINESS.md. Runtime acceptance followed the initial offline preparation.

Command: `python -m unittest discover -s tests -v` — **8 tests passed**:

1. Published artifact overwrite is refused and its bytes remain unchanged.
2. Synthetic fixture round-trips through XML and refuses to overwrite an existing directory.
3. Missing standalone LICENSE prevents a build.
4. Source timestamp and LF/CRLF changes do not change the archive bytes in this build environment.
5. Archive integrity, exact allowlisted payload, complete license, source match, startup/manifest version, and absence of the development harness.
6. Correct synthetic Party Sheet membership, excluded outsider, tests disabled by default, and no copied holders/tokens/modules.
7. Startup/manifest version drift prevents a build.

`git diff --check` passed. The fixture was generated into ignored `dist/sandbox/` with tests **off**. The source-drawn 96 px icon was visually reviewed as a local image; no FG UI was opened. The supplied illustrative cover is a 1200x800 JPEG of 214,427 bytes, with its generation prompt/provenance retained. It is not a product screenshot.

## Artifact identities

- Existing published v0.1.3 asset, still unchanged: `204c47bfaaa95ad8e56b420acaf693e8a3a994751f47227daa0aa42489830aa5`.
- Current 0.1.4 candidate at `dist/CoinTransfer.ext`: `0bd91cd26823a51befb031733b3a51d3ab824ea00c0d5d01f97d3e625d3beda0`.
- Candidate entries: `extension.xml`, three runtime Lua scripts, `windows/coin_transfer.xml`, `LICENSE.txt` (six files total).

The existing modified `release/CoinTransfer.ext` status predates this work and remains unchanged. Its payload equals the committed v0.1.3 payload; its timestamp metadata matches the public asset.

## Runtime evidence

The subsequent FG session passed 44 native assertions and all four connected-player operations; see [../testing.md](../testing.md). The offline tests additionally reject disallowed Forge archive suffixes (eighth test). Packaging checks alone do not establish FG compatibility.
