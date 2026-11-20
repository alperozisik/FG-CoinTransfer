# Coin Transfer

Repository copy of the submitted Forge description. [Forge item 3794](https://forge.fantasygrounds.com/shop/items/3794/view) awaits approval/review; its v0.1.4 build is **QUEUED FOR PROCESSING**, not yet verified Live. [Forum thread 88613](https://www.fantasygrounds.com/forums/showthread.php?88613) is published. Current direct download: [GitHub v0.1.4](https://github.com/alperozisik/FG-CoinTransfer/releases/tag/v0.1.4).

Keep a shared fund for supplies, pool adventure loot and character contributions, and let players withdraw what they need or return spare coins through their own character sheets. When the hoard gets heavy, move it into a Bag of Holding as physical coin items and pair with Extraplanar Containers for its supported weight exemption. The English interface opens from **Inventory > Coin Transfer**, with an additional button for Floating Tabs inventory.

## One party, one shared purse

Pool adventure loot and player contributions in the Party Sheet's shared Loot coins. A character can withdraw money for supplies, then deposit the unused coins back through their own sheet. For example, starting with **300 GP**, a **25 GP** withdrawal leaves **275 GP** in the shared pool; returning **10 GP** brings it to **285 GP**. Another character's **20 GP** contribution brings the common fund to **305 GP**.

Party transfers use the connected host's balance and membership checks and require no separate GM distribution or approval click. The shared pool is not a character's carried balance: moving money between them changes where it is held, without adding it twice. GP stays GP and SP stays SP; currency exchange, shops and banking are outside the scope.

## Four operations

- **Withdraw from Party:** take shared Party Sheet coins into Treasure > Coins, loose inventory, or a selected container.
- **Deposit to Party:** return Treasure coins or physical coin items to the shared party pool.
- **Coins -> Items:** turn Treasure balances into corresponding inventory coin quantities.
- **Items -> Coins:** return physical coin quantities to Treasure balances.

Players can send transfers from their owned Party Sheet character without a separate GM approval click. The connected host checks membership and available balances before processing the request. Each denomination stays the same; this is not a currency-exchange, banking, or shop extension.

The window remembers the character's last operation and container. Containers must have unique names and quantity one. Shared coin item templates use campaign currency names, costs, and unit weights, reusing suitable existing items where possible. Party Sheet carried currency totals combine Treasure balances with Carried/Equipped physical coin items into one entry per character and denomination. Not Carried coin items do not contribute to that combined total.

## From heavy hoard to Bag of Holding

At a campaign weight of **0.02 lb per coin**, 4,000 GP weighs **80 lb**. Choose **Coins -> Items** and select your Bag of Holding to move existing Treasure GP into it, or **Withdraw from Party** to send shared loot directly to the bag. The coins become normal inventory stacks with quantity, monetary cost and unit weight.

Recommended companion: **[Extraplanar Containers and Bag of Holding](https://forge.fantasygrounds.com/shop/items/13/view) by bmos**, available free on Forge. Coin Transfer puts the coins in the bag; this companion supplies the special container-weight rules. Coin Transfer alone does not make bag contents weightless.

For the companion's documented exemption, use a supported, uniquely named container such as **Bag of Holding**, and mark the coin contents **Carried**, rather than Equipped. Names containing `of holding`, `portable hole`, `handy haversack`, `extraplanar` or `weightless` are among its supported matches. An ordinary backpack gets container features, not weightless contents. Coin Transfer additionally requires the destination container's quantity to be **1**. Check the resulting coin stack's carrying state: newly created stacks inherit the selected container's state.

The author confirms that the Bag of Holding weight exemption with the bmos companion was tested successfully (user confirmation, 2026-11-20). No additional version matrix or test-environment details were supplied with that confirmation. Follow the companion's current setup instructions and capacity limits. Carried/Equipped coin items both count in Coin Transfer's currency totals; that money-counting rule is separate from the companion's weight exemption.

## Settings

Coin Transfer adds no campaign Settings entries. The operation defaults to **Withdraw from Party**. Withdraw/Deposit initially use **Treasure > Coins**; Coins -> Items/Items -> Coins initially use **Inventory (no container)**. Available selections are native Treasure for party operations, loose inventory, and eligible inventory containers. Last operation and a separate source/destination for each operation are saved per character in the campaign, shared by the GM and character owner, and survive reloads. Quantities start at zero on window/operation rebuild and are not remembered. Campaign Currencies definitions supply coin names, values and unit weights.

When using MNM Coin Manager/Upgrade, **disable inventory coin mirroring** before physical coin transfers. Enabled mirroring blocks physical conversions to avoid representing the same money twice; disabled mirroring allows them. This option belongs to MNM: the GM must disable it, and Coin Transfer does not register it or set its default or persistence. Native Treasure-to-party transfers are unaffected by this guard. The development harness dummy option is not in the release and is not a product setting. Extraplanar Containers supplies its own container-weight rules; Coin Transfer adds no weight-exemption switch.

## Installation and updates

While Forge approval and Live delivery are pending, install the `.ext` asset from the public GitHub Release. After approval and verified Live delivery, the Forge updater can deliver the extension. For manual installation, close the campaign, copy `CoinTransfer.ext` into the Fantasy Grounds data folder's `extensions` directory, and enable Coin Transfer in the launcher. Keep one installed copy; do not install the unpacked source beside the archive. The host enables it for the campaign. The startup chat message identifies the loaded version.

Back up and close the campaign before replacing an older archive. Existing campaign balances/items remain. Removing the extension does not automatically convert physical coin items back to Treasure: use Items -> Coins first if native-only accounting is wanted. Full instructions: https://github.com/alperozisik/FG-CoinTransfer#readme

## Compatibility and limits

Targets the Fantasy Grounds **5E ruleset**. Version 0.1.4 passed 44 native checks and all four operations from a separate owning player on FG 5.1.15 (2026-10-28), 5E/CoreRPG 2026-10-06, Default theme, with only Coin Transfer enabled. These are tested versions, not proven minimum versions. Separate 2014/2024 configurations are unverified.

MNM Coin Manager/Upgrade's inventory coin mirroring must be disabled for physical transfers. Historical sessions included those extensions, Floating Tabs, Extraplanar Containers, and Party Item Weight; those combinations were not rerun with 0.1.4 and remain unverified for this release. New MNM Coin and Trade has not been runtime-verified. The bmos companion remains responsible for special weight rules; the author confirms its Bag of Holding exemption was tested successfully. This does not establish a complete companion-version matrix.

## Source, support, and license

MIT license, with the full notice included in the v0.1.4 standalone archive. Source and public release assets: https://github.com/alperozisik/FG-CoinTransfer

Report issues at https://github.com/alperozisik/FG-CoinTransfer/issues with FG/ruleset/extension versions, GM or player role, operation, reproduction steps, and a sanitized error message. Never upload a full campaign database, credentials, or private player records.

The first listing image is an illustrative cover, not a screenshot. Seven listing images have been uploaded and activated, with the illustrative cover primary; actual product screenshots are clearly distinguished from artwork. The Forge file must be the unchanged public GitHub Release asset, verified by SHA-256.
