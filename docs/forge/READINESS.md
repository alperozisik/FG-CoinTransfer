# Forge preparation — 2026-11-20

Status: acceptance complete within the recorded bare-5E scope; [public GitHub v0.1.4 Release](https://github.com/alperozisik/FG-CoinTransfer/releases/tag/v0.1.4) is published and its downloaded asset hash is verified. Forge and forum have not been submitted.

- Authoritative source: this Git checkout; the older sibling workspace is an archive.
- v0.1.4 candidate SHA-256: `0bd91cd26823a51befb031733b3a51d3ab824ea00c0d5d01f97d3e625d3beda0`.
- Eight offline tests and 44 native FG assertions passed. Four operations passed from a separate owning client, followed by persisted-balance/preference reload checks. See [testing evidence](../testing.md).
- The final archive contains six allowlisted entries including LICENSE.txt and no development harness.
- Five actual synthetic-campaign screenshots follow the illustrative cover in `images/`. The source-drawn icon is listing artwork; no runtime icon control was added.
- Tested: FG 5.1.15, 5E/CoreRPG 2026-10-06, Default theme, only Coin Transfer. Other extensions, separate 2014/2024 configurations, special container weights, and simultaneous network stress are unverified for this version and are explicitly described as such.
- Both FG sessions were closed; the previous Damage_Workbench_Sandbox launcher selection and port 1802 were restored. The unique QA install and campaign were removed. Production extension/campaign files were not replaced.
- English descriptions and forum opening remain unsubmitted drafts. Add the Forge link only after authorized publication.
- Distribution sequence: public GitHub v0.1.4 Release -> download asset -> verify SHA-256 -> unchanged file to Forge when separately authorized. No separate Forge build.

Release source commit: `3e670dd8579a284885b8d6a555cead8182b74153`. Downloaded public asset: `dist/downloaded-v0.1.4/CoinTransfer.ext` (local/ignored). This exact downloaded file is the future Forge upload input. See [release record](../releases/v0.1.4.md).
