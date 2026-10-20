# Hub startup proof

PR head: `8c3726341c5562884a7b5d7dfb52809b77661d21`.
Environment: Windows x64 source Debug build, fresh isolated profile and an owned
private desktop. This is not an installed Companion or live Gateway capture.

`hub-startup-after-redacted.png` is an actual owned-window PrintWindow capture.
Only the isolated loopback endpoint is masked. The shared input desktop was not
switched. The app logged unsupported optional tray construction and still
rendered the actual Connection Hub. `startup-runtime-redacted.log` contains the
copied runtime lines, not illustrative schema or invented output.

`baseline-runtime-redacted.log` is the retained real failure from public
`50d0b34a4e71a51286ad5346b57a388ebf805fd6`. The runtime-anchor and tray-owner
source bytes at that baseline match this PR's base
`431bd8f9c1aabd2b0c933afcbee82a07ac0646a8`. The before failure is historical;
the screenshot and after runtime trace were collected on the current PR head.

Current-head validation: full build passed; Shared 4,486 passed with 35 existing
opt-in skips; private-desktop Tray 4,304 passed without skips; two actual
startup/owned-child cleanup cases passed; documentation checks passed.

The hosted PR CI is still red. `ci-classification.json` identifies the actual
jobs and main comparisons: a native UI test-host abort with no failing assertion,
also observed on main before and after this PR, and an unchanged synthetic
WebSocket teardown failure in setup tests. The CI Gate is downstream of those
jobs. This evidence does not claim those jobs passed or establish the native
UI host crash's underlying cause.

ClawSweeper reported no code findings and requested real behavior proof and CI
classification. These files address those evidence requests; no new review
comment, ready transition or merge is requested.

Synthetic loopback tests, this real source-app/private-desktop capture, and the
earlier combined formal WSL/MXC 18/18 run are distinct evidence. The formal run
was not repeated on this extracted head. macOS and installed-Gateway external
PowerShell behavior remain unverified.
