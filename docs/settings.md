# Settings, choices and persistence

Coin Transfer v0.1.4 registers **no production Options/Settings entries**. Its controls below belong to the transfer window. Preferences are stored in the character's campaign database record, not a private per-user computer preference. GM and owning player use the same character choices.

| Control | Every available value | Initial/default | Effect and persistence |
| --- | --- | --- | --- |
| Operation | Withdraw from Party; Deposit to Party; Coins -> Items; Items -> Coins | Withdraw from Party | Moves party -> selected endpoint; selected endpoint -> party; native Treasure -> physical items; physical items -> native Treasure, respectively. Last choice persists per character across reloads. |
| Source/Destination | Treasure > Coins (Withdraw/Deposit only); Inventory (no container); each detected inventory container | Treasure > Coins for Withdraw/Deposit; Inventory (no container) for both item conversions | Each operation remembers its own selection per character in the campaign. Missing containers require reselection; duplicate names or container quantity other than 1 fail validation. No hardcoded container list: eligible records are detected from subtype, capacity or recognised name terms. |
| Currency quantities | Whole, non-negative amounts for each campaign currency, within source balance and supported limits | 0 on open/rebuild | Each amount applies to that denomination, with no exchange. Quantities are not persisted; rebuilds reset them. All Available fills available amounts; Clear sets zero; Refresh rebuilds current currency/endpoint data. |
| Campaign currency definitions | Campaign-provided names, monetary values and unit weights | Existing campaign definitions | Campaign data supplies item names, costs and weights. Coin Transfer does not add a currency Settings toggle or prescribe a new campaign-wide default. |

## Companion options are not Coin Transfer Settings

**MNM Coin Manager/Upgrade inventory mirroring** is read through `inventoryCoinsMNM`: its enabled (`yes`) state blocks every transfer whose source or destination is a physical-item endpoint, including Withdraw/Deposit to/from containers or loose inventory and both item conversions. Disabled (`no`) permits those transfers subject to the usual checks. Native Treasure/shared-pool transfers do not involve a physical endpoint and remain available. Coin Transfer tells the GM to disable the option; it does not register the production option, select its default, or define its storage/persistence. Those details belong to the installed MNM version. If MNM does not register the option, Coin Transfer does not create it and the guard is inactive.

The **QA harness** registers a disposable stand-in option only in its guarded synthetic test run. Its No/Yes values and No default are test scaffolding. The harness and its registration are excluded from the distributable, so they must not be advertised as product settings.

**Extraplanar Containers and Bag of Holding** supplies its own weight/capacity handling. Coin Transfer has no weight-exemption setting. The companion documents supported, uniquely named containers and **Carried, not Equipped**, contents for exemption; an ordinary backpack is not weightless. See [bmos's Forge instructions](https://forge.fantasygrounds.com/shop/items/13/view). Coin Transfer counts both Carried and Equipped physical coins in currency totals, independently of weight handling. The special weight exemption was not independently reverified with v0.1.4.

## Source verification

- [Window controls, defaults and DB preferences](../extension/scripts/coin_transfer_window.lua): `onInit`, `modeChanged`, `rebuild`, `selectionChanged`.
- [Endpoints, container validation and mirror guard](../extension/scripts/coin_transfer_service.lua): `containers`, `endpoint`, `mirrorEnabled`, `validate`; new item stacks inherit container carrying state.
- [Build exclusions](../build_release.py): the `CoinTransferTests` registration and harness file are absent from the archive.

These settings/control statements were checked against v0.1.4 source. They do not establish runtime certification of companion combinations; see [acceptance scope](testing.md).
