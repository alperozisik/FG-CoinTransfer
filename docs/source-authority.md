# Source of truth

The Git checkout connected to `git@github.com:alperozisik/FG-CoinTransfer.git` is the sole source of truth for code, builds, documentation, and releases. Make future edits here and use Git history to review them.

The older sibling `CoinTransfer` work directory is a local historical/test archive. It is not a second development branch. Its diagnostics, copied ruleset references, campaign-derived fixture data, logs, and private validation notes are not publication inputs. Do not synchronize that directory over this checkout or upload it wholesale.

All new public fixtures are generated from literal synthetic data by `tests/build_fixture.py`. They must not read any existing FG campaign.

`release/CoinTransfer.ext` currently records the 0.1.3 publication lineage. Its existing working-tree modification was already present before release preparation: the working file matches the GitHub asset, while the committed archive has an older ZIP timestamp. Decompressed payloads are identical. Preserve both historical facts; do not silently replace the public asset to clean Git status.
