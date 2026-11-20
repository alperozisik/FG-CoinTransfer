# Coin Transfer

Version **0.1.4**: reproducible standalone package with the MIT notice included. Acceptance passed 44 native FG checks and four connected-player operations; see [recorded scope and limits](docs/testing.md). Forge publication is pending.

English interface for Fantasy Grounds 5E. Open a character's Inventory tab and click **Coin Transfer**. The same button is added to Floating Tabs inventory. Players can also use `/cointransfer` with an active identity; the GM can use `/cointransfer <character name>`.

## Install

1. Download **CoinTransfer.ext** from a [public GitHub Release](https://github.com/alperozisik/FG-CoinTransfer/releases). Use the attached asset, not the automatically generated Source code ZIP.
2. Close the campaign. Use Fantasy Grounds' data-folder shortcut to locate your data directory, then copy the asset into its `extensions` directory.
3. Keep one installation: remove an older unpacked `CoinTransfer` source folder from `extensions` if present. Do not load an archive and unpacked copy together.
4. In the campaign launcher, enable **Coin Transfer**, then load your 5E campaign. The startup chat message includes the extension version.

The host installs/enables the extension; connected players receive its campaign functionality through Fantasy Grounds. Player party transfers require an owned character on the Party Sheet and a connected host. Party shared coins are player-visible. Currency item templates are shared with players automatically.

## Update

Back up the campaign and close it. Replace the existing `.ext` with the asset from the new public Release, keep a single installed copy, and load the campaign again. Check the version in chat. Players should reconnect if their session was interrupted by the reload. Never replace or edit `db.xml` to update the extension. Existing balances, coin items, preferences, and transaction records are campaign data and remain in place.

## Disable or remove

To return to native Treasure-only accounting, first use **Items -> Coins** for physical coins in each inventory location. This is optional: disabling the extension does not delete remaining coin items or turn them into Treasure balances automatically. Close the campaign and uncheck **Coin Transfer** in the launcher; the `.ext` can then be removed from `extensions`. Existing items retain their normal cost and weight, but native Party Sheet coin totals may no longer include physical coin items. Re-enable the extension to use its conversion and combined totals again. Automatic shared templates and stored preferences/ledger entries are not automatically deleted on uninstall.

## Operations

- **Withdraw from Party:** take shared Party Sheet coins into Treasure > Coins, loose inventory, or a container.
- **Deposit to Party:** return Treasure coins or physical coin items to the shared Party Sheet pool.
- **Coins -> Items:** remove Treasure coins and create the corresponding inventory quantities.
- **Items -> Coins:** remove physical quantities and credit Treasure coins.

Select whole coin quantities and click **Transfer**. The last operation and container are saved per character. A missing or ambiguous container must be selected again. Container stacks must have quantity 1 and unique names.

Party Sheet > Inventory > Carried currency totals include both Treasure coins and physical coin items marked Carried or Equipped, across all containers. Each character appears once per denomination with the combined amount. The shared Loot pool remains separate. Not Carried items, zero-count items, ordinary valuables, and MNM's aggregate Currency mirror are excluded from this currency total. Changing an item's carrying status updates the total.

Party transfers require Party Sheet membership and available shared money. The host processes player requests automatically; the GM does not approve each request. Balances are rechecked on the host, and replayed requests are rejected. Multi-currency requests are fully validated before changing balances. Transfers preserve denominations; currency exchange is outside this extension's scope.

## Currency items and compatibility

The extension reads campaign Currencies for names, values and unit weights. It reuses matching denomination items where available, otherwise creates shared templates such as **Gold Piece (GP)**, type Treasure, unit cost **1 GP**, and the configured weight. Compatible custom currencies are supported. Generic valuables and MNM's aggregate **Currency** mirror are never treated as denomination coins.

MNM Coin Manager and Upgrade retain their own controls. Physical transfers require MNM's inventory coin mirroring option to be disabled, so the same money is not represented twice. Native container location references are used so existing container and encumbrance extensions can apply their rules. Extraplanar Containers remains responsible for Bag of Holding weight behavior.

New MNM Coin and Trade was not installed during development. Native currency data and normal Treasure item costs are used, but its runtime compatibility has not been verified. No proprietary APIs are patched.

## Tested environment and support limits

Current 0.1.4 acceptance used **Fantasy Grounds 5.1.15**, **5E/CoreRPG 2026-10-06**, Default theme and only Coin Transfer enabled. All four operations passed on a separate owning player client. See [acceptance evidence](docs/testing.md) and [real product screenshots](docs/forge/images/). Historical testing used **Fantasy Grounds 5.1.13**, with **5E/CoreRPG dated 2026-07-14**. This is a tested environment, not a proven minimum version. The extension targets the shared **5E ruleset**; separate 2014 and 2024 character/rules configurations have not yet completed a recorded acceptance matrix. Do not interpret the 5E label as certification for both editions or every later FG update.

Historical combined-session observations covered MNM Core v83, Coin Manager v16, Upgrade v3, Extraplanar Containers v1.21, Party Item Weight v1.11, Floating Tabs v1.7, Winnowing Pursuits v2.7.6, and Core Dark. This does not certify all features or versions of those extensions. Bag of Holding weight exemption remains the container extension's responsibility and was not independently verified. Acceptance evidence and limits are in [docs/testing.md](docs/testing.md).

Transfers preserve denominations; no exchange, banking, shop, or trade automation is provided. Physical coin stacks with zero quantity can remain as inventory records and contribute zero to this extension's currency totals. Editing campaign currency weights later updates owned templates when definitions are ensured; it is not a migration of every existing inventory stack.

## Development

This Git checkout is the [source of truth](docs/source-authority.md). `extension/` is the editable source. With Python 3.9+ run `python build_release.py` to produce a reproducible **candidate** at `dist/CoinTransfer.ext`, containing the full MIT license and excluding the development harness. Run `python -m unittest discover -s tests -v` for offline package/fixture checks. FG runtime acceptance is separate.

The development test harness requires a separate synthetic sandbox campaign and is excluded from release builds. Do not run development tests against a real campaign.

Published files in `release/` are historical artifacts and are not overwritten by candidate builds. Forge distribution must use the exact asset downloaded from a **public GitHub Release**, with its SHA-256 verified; see [docs/releasing.md](docs/releasing.md).

## License

MIT. See [LICENSE](LICENSE). Fantasy Grounds and third-party extensions are separate products and are not included.
