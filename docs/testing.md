# Fantasy Grounds acceptance — 2026-11-20

Version: Coin Transfer 0.1.4. FG 5.1.15 (2026-10-28), 5E/CoreRPG 2026-10-06, Default theme. Only Coin Transfer QA 0.1.4 enabled. All records were invented synthetic fixtures; production campaign data was not used.

## Automated native checks

The guarded development harness passed **44 assertions** in FG. The complete sanitized transcript is [fg-44-20261120.txt](evidence/fg-44-20261120.txt). It covers corrected Party Sheet membership, outsider rejection, transfer accounting, invalid/insufficient requests, replay rejection, sequential pool exhaustion, conservation, container linkage, item cost/weight, template reuse, and Carried/Equipped/Not Carried/zero-count totals.

The first harness attempt encountered an unregistered MNM option in bare 5E. The harness was corrected to register a sandbox-only stand-in option; all 44 checks then passed. This option test does not establish compatibility with the actual MNM extensions.

## Connected player acceptance

A separate owning client connected to the LAN host. Each operation completed without a host approval click:

| Operation | Before | After |
| --- | --- | --- |
| Withdraw 5 GP to Bag of Holding | Party 274; Bag 15 | Party 269; Bag 20 |
| Deposit 5 GP from Bag | Party 269; Bag 20 | Party 274; Bag 15 |
| Coins -> Items, 2 GP to Backpack | Treasure 106; Backpack 5 | Treasure 104; Backpack 7 |
| Items -> Coins, 2 GP from Backpack | Treasure 104; Backpack 7 | Treasure 106; Backpack 5 |

The harness was absent during these player tests. The clean QA archive used the candidate runtime payload with only its display name changed to avoid replacing the existing installed production extension. The QA package used the earlier standalone LICENSE filename; the final deterministic package changes that entry to LICENSE.txt for the Forge suffix allowlist. Runtime XML/Lua is unchanged.

Party Sheet showed **226 GP**: Test 1 combined **126** (106 Treasure + 5 Backpack + 15 Bag), Test 2 **100**. Shared Loot remained **274 GP**, separate from carried totals. The GP item showed cost **1 GP** and unit weight **0.02**. Actual product screenshots are in [forge/images](forge/images/).

After closing both client and host normally, the clean sandbox was reopened: startup chat reported v0.1.4, Treasure was 106 GP, Backpack 5 GP, Bag 15 GP; the window restored Items -> Coins and Backpack with zero requested quantities. The prior request did not execute again. No runtime error dialog appeared. Bare 5E logs contain the known optional charsheets_inventoryft merge-target warning because Floating Tabs was absent.

## Limits

This run did not load MNM, Floating Tabs, Extraplanar Containers, Party Item Weight, custom themes, or New MNM Coin and Trade. This run does not certify those combinations for 0.1.4. Separate 2014/2024 configurations and simultaneous two-client latency/stress behavior were not tested in this automated/connected-client run. The separate author-confirmed Bag of Holding result is recorded below. Sequential pool rejection is not a simultaneous network stress test. Historical observations are not a substitute for these missing checks.

## Reproduction

Run `python tests/build_fixture.py --enable-tests --output <new directory>` to prepare invented data. Install the guarded development source only into a disposable sandbox, with its exact fixture marker. Never run the harness on a real campaign. Build `python build_release.py` for a clean archive with no harness; offline checks use `python -m unittest discover -s tests -v`.

## Additional user-confirmed acceptance — 2026-11-20

The author confirms that the Bag of Holding weight exemption with the bmos companion was tested successfully (user confirmation, 2026-11-20). No additional version matrix or test-environment details were supplied with that confirmation. This is accepted user-supplied test evidence, separate from the recorded bare-5E harness/client run. It removes the earlier outstanding Bag of Holding exemption check; it does not expand the automated test matrix or certify other integrations. Coin Transfer moves the coins; Extraplanar Containers supplies the exemption for supported, uniquely named containers with Carried (not Equipped) contents. Container quantity one remains a Coin Transfer requirement.
