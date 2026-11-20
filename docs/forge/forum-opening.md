# [5E Extension] Coin Transfer — party transfers and physical coins

Draft forum opening. Do not post before the public Release and separately authorized Forge listing exist.

Coin Transfer provides an English window for moving shared Party Sheet money to and from a character's Treasure or inventory containers. Coins can also become normal inventory items with quantity, unit weight, and monetary cost, then be converted back.

Players can transfer from their owned Party Sheet character without the GM clicking a distribution/approval button for every request. The connected host validates balances and membership. Container selection is remembered, and Carried/Equipped physical coin quantities are included in the Party Sheet's combined per-character currency total.

**Get it:** [Forge listing — add only after publication]. [GitHub source and Releases](https://github.com/alperozisik/FG-CoinTransfer). **Version:** 0.1.4. **License:** MIT.

**Images:** illustrative cover first, followed by real transfer/container/item/Party Sheet screenshots from the synthetic test campaign. The cover is not a rendering of the UI.

**Install:** close the campaign, place the public Release's `CoinTransfer.ext` in the FG data `extensions` directory, and enable Coin Transfer. Avoid an unpacked/archived duplicate. Back up before updates. Removing the extension leaves physical coin items in the campaign; convert them back first if desired.

**Tested environment:** FG 5.1.15 (2026-10-28), 5E/CoreRPG 2026-10-06, Default theme, only Coin Transfer enabled. 44 native checks and all four operations from a separate owning client passed. Minimum-version and separate 2014/2024 compatibility claims are not established yet.

**Compatibility:** MNM Coin Manager inventory mirroring must be off for physical transfers. MNM, Floating Tabs, Extraplanar Containers and Party Item Weight combinations were not rerun with 0.1.4 and are unverified for this version. New MNM Coin and Trade remains unverified unless specifically tested. Special container weight handling belongs to the installed container extension. Transfers preserve denominations; no banking, exchange, or shops are included.

Please report problems through [GitHub Issues](https://github.com/alperozisik/FG-CoinTransfer/issues), including the loaded version, FG/ruleset versions, other relevant extensions, GM/player role, and clear reproduction steps. Share only sanitized logs/screenshots, not complete campaign files.
