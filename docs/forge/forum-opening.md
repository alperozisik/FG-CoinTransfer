# [5E Extension] Coin Transfer — party transfers and physical coins

Repository companion to the published [forum thread 88613](https://www.fantasygrounds.com/forums/showthread.php?88613). Its first three posts are 775980 (introduction/benefits), 775981 (usage, complete choices and MNM settings), and 775982 (release/support), posted by morfil. The thread links to Forge item 3794, which awaits approval; its build is queued, not yet verified Live.

Pool adventure loot and player contributions in one shared Party Sheet fund. Players can withdraw money for supplies and return spare coins through their own character sheets. The English window also turns native Treasure coins into weighted inventory items with monetary cost, and converts them back.

Players can transfer from their owned Party Sheet character without the GM clicking a distribution/approval button for every request. The connected host validates balances and membership. Container selection is remembered, and Carried/Equipped physical coin quantities are included in the Party Sheet's combined per-character currency total.

For heavy hoards, send physical coins directly to a Bag of Holding. The free [Extraplanar Containers and Bag of Holding by bmos](https://forge.fantasygrounds.com/shop/items/13/view) supplies special weight handling; Coin Transfer moves the coins. Use supported, uniquely named containers with quantity one and keep coin contents **Carried**, rather than Equipped, for the companion's exemption. The author confirms that the Bag of Holding weight exemption with the bmos companion was tested successfully (user confirmation, 2026-11-20). No additional version matrix or test-environment details were supplied with that confirmation. Shared Loot and each character's combined carried total remain separate.

**Settings:** Coin Transfer adds no production campaign Settings entries. Its initial operation is Withdraw from Party, and operation/endpoint choices persist per character in the campaign. See the [complete choices/defaults reference](../settings.md). MNM inventory mirroring is MNM's option, which the GM must disable before physical transfers; the QA dummy option is not included in the release.

**Get it:** [Forge listing — awaiting approval](https://forge.fantasygrounds.com/shop/items/3794/view). [GitHub source and Releases](https://github.com/alperozisik/FG-CoinTransfer). **Version:** 0.1.4. **License:** MIT.

**Images:** illustrative cover first, followed by real transfer/container/item/Party Sheet screenshots from the synthetic test campaign. The cover is not a rendering of the UI.

**Install:** until Forge approval and verified Live updater delivery, use the public GitHub asset. Close the campaign, place the public Release's `CoinTransfer.ext` in the FG data `extensions` directory, and enable Coin Transfer. Avoid an unpacked/archived duplicate. Back up before updates. Removing the extension leaves physical coin items in the campaign; convert them back first if desired.

**Tested environment:** FG 5.1.15 (2026-10-28), 5E/CoreRPG 2026-10-06, Default theme, only Coin Transfer enabled. 44 native checks and all four operations from a separate owning client passed. Minimum-version and separate 2014/2024 compatibility claims are not established yet.

**Compatibility:** MNM Coin Manager inventory mirroring must be off for physical transfers. MNM, Floating Tabs, Extraplanar Containers and Party Item Weight combinations were not rerun with 0.1.4 and are unverified for this version. New MNM Coin and Trade remains unverified unless specifically tested. Special container weight handling belongs to the installed container extension. Transfers preserve denominations; no banking, exchange, or shops are included.

Please report problems through [GitHub Issues](https://github.com/alperozisik/FG-CoinTransfer/issues), including the loaded version, FG/ruleset versions, other relevant extensions, GM/player role, and clear reproduction steps. Share only sanitized logs/screenshots, not complete campaign files.

The temporary pending-approval notice in forum post 775980 must remain until the Forge item and build are actually Live and delivery has been verified. Do not create a duplicate thread for a status update.
