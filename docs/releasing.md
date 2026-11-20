# Release provenance and Forge handoff

**Forge always receives the exact `.ext` asset from a public GitHub Release, with the same SHA-256. No separate Forge build is permitted.**

1. Build the candidate with `python build_release.py`; its destination is `dist/`.
2. Run the offline checks and the FG acceptance matrix against the candidate's version and source. Record environment, test log, asset hash, and synthetic product screenshots. A development-harness build is not the distributable.
3. Finish runtime fixes and repeat any affected checks. Packaging-only changes such as embedding LICENSE still require the final clean archive to load in FG without diagnostics.
4. Review the source diff, MIT notice, source/runtime versions, and exact archive entries. Commit the approved source using the SSH remote, then create the corresponding GitHub tag and **public Release**. Attach the tested archive. Do not publish a final release before FG acceptance finishes.
5. Download that public asset and calculate SHA-256 locally. Compare it to the accepted candidate and the digest GitHub displays. Keep the digest with the release record.
6. Upload **that downloaded file**, unchanged, to Forge. Record the public Release URL, tag/commit, asset filename, digest, and the Forge upload result. Forge/forum publication still requires the user's separate go-ahead for the prepared listing.
7. A license, code, asset, or packaging change after publication goes through a new appropriate GitHub version first. Never patch only the Forge copy or silently replace an existing public asset.

Candidate 0.1.4 completed the acceptance scope recorded in testing.md; [public Release v0.1.4](https://github.com/alperozisik/FG-CoinTransfer/releases/tag/v0.1.4) is published and its downloaded asset hash matches the accepted candidate. See releases/v0.1.4.md. The existing 0.1.3 asset SHA-256 is `204c47bfaaa95ad8e56b420acaf693e8a3a994751f47227daa0aa42489830aa5`; its difference from the committed ZIP is metadata-only. The historical 0.1.3 standalone package did not embed LICENSE. That gap is addressed in the new candidate rather than by changing the published asset.

## Build properties

The stdlib builder fixes entry timestamps, entry order, permissions, compression settings, and text line endings, rejects mismatched startup/manifest versions, embeds the repository LICENSE as `LICENSE.txt`, and excludes the test harness. It rejects archive entries outside the Forge file-extension allowlist. The root source repository keeps its conventional extensionless `LICENSE`. Rebuild equality is checked in the same Python/zlib environment; use the recorded artifact hash as the publication identity rather than assuming every possible compression-library version produces identical bytes.
