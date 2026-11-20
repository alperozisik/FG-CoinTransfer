# Coin Transfer

Draft listing — do not publish until the candidate passes FG acceptance and its public GitHub Release exists.

Move money between shared party treasure and a character's sheet, or carry individual coins as normal weighted inventory items. The interface is in English and opens from **Inventory > Coin Transfer**, with an additional button for Floating Tabs inventory.

## Four operations

- **Withdraw from Party:** take shared Party Sheet coins into Treasure > Coins, loose inventory, or a selected container.
- **Deposit to Party:** return Treasure coins or physical coin items to the shared party pool.
- **Coins -> Items:** turn Treasure balances into corresponding inventory coin quantities.
- **Items -> Coins:** return physical coin quantities to Treasure balances.

Players can send transfers from their owned Party Sheet character without a separate GM approval click. The connected host checks membership and available balances before processing the request. Each denomination stays the same; this is not a currency-exchange, banking, or shop extension.

The window remembers the character's last operation and container. Containers must have unique names and quantity one. Shared coin item templates use campaign currency names, costs, and unit weights, reusing suitable existing items where possible. Party Sheet carried currency totals combine Treasure balances with Carried/Equipped physical coin items into one entry per character and denomination. Not Carried coin items do not contribute to that combined total.

## Installation and updates

Install the Forge-delivered extension or the `.ext` asset from the matching public GitHub Release. For manual installation, close the campaign, copy `CoinTransfer.ext` into the Fantasy Grounds data folder's `extensions` directory, and enable Coin Transfer in the launcher. Keep one installed copy; do not install the unpacked source beside the archive. The host enables it for the campaign. The startup chat message identifies the loaded version.

Back up and close the campaign before replacing an older archive. Existing campaign balances/items remain. Removing the extension does not automatically convert physical coin items back to Treasure: use Items -> Coins first if native-only accounting is wanted. Full instructions: https://github.com/alperozisik/FG-CoinTransfer#readme

## Compatibility and limits

Targets the Fantasy Grounds **5E ruleset**. Version 0.1.4 passed 44 native checks and all four operations from a separate owning player on FG 5.1.15 (2026-10-28), 5E/CoreRPG 2026-10-06, Default theme, with only Coin Transfer enabled. These are tested versions, not proven minimum versions. Separate 2014/2024 configurations are unverified.

MNM Coin Manager/Upgrade's inventory coin mirroring must be disabled for physical transfers. Historical sessions included those extensions, Floating Tabs, Extraplanar Containers, and Party Item Weight; those combinations were not rerun with 0.1.4 and remain unverified for this release. New MNM Coin and Trade has not been runtime-verified. Container extensions remain responsible for their special weight rules; do not promise Bag of Holding weight exemption without its test result.

## Source, support, and license

MIT license, with notice included in the new standalone candidate. Source and public release assets: https://github.com/alperozisik/FG-CoinTransfer

Report issues at https://github.com/alperozisik/FG-CoinTransfer/issues with FG/ruleset/extension versions, GM or player role, operation, reproduction steps, and a sanitized error message. Never upload a full campaign database, credentials, or private player records.

The first listing image is an illustrative cover, not a screenshot. Five real product screenshots from the synthetic acceptance campaign follow it. The Forge file must be the unchanged public GitHub Release asset, verified by SHA-256.
