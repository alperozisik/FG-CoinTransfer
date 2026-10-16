# Coin Transfer 0.1.3

English interface for Fantasy Grounds 5E. Enable **Coin Transfer** in the campaign launcher. Open a character's Inventory tab and click **Coin Transfer**. The same button is added to Floating Tabs inventory. Players can also use `/cointransfer` with an active identity; the GM can use `/cointransfer <character name>`.

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

## Development

`extension/` is the editable source. `build_release.py` produces `release/CoinTransfer.ext` without diagnostics or the development test harness. Do not install both an unpacked CoinTransfer folder and the .ext archive in the same Fantasy Grounds extensions directory.

The development test harness requires a separate synthetic sandbox campaign and is excluded from release builds. Do not run development tests against a real campaign.

## License

MIT. See [LICENSE](LICENSE). Fantasy Grounds and third-party extensions are separate products and are not included.
