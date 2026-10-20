# Gateway fixture cancellation proof

Current head: `f560ab37b08562bc234130e2c678c365301dd6c4`.
This is a test-only loopback fixture change, not an installed or live Gateway
capture. No product command, permission or native executor changed.

The deterministic cases use real loopback authentication, the actual
FixturePeer reader/disposal owner, and a replacement connection that completes
a real chat exchange. Only the external receive exception is injected.
The proof does not claim the platform always throws that exception.

- `behavior-receipt.txt`: copied actual focused terminal output. Before owned
  cancellation the injected exception propagates unchanged; after owned
  cancellation the reader/disposal completes. Both replacement peers work.
- The same two cases with only the cancellation-scoped guard removed produced
  one failure and one pass. Restoring it produced two passes. Existing assertions,
  timeouts and skips were not relaxed.
- `baseline-receipt.txt`: a separate actual socket ObjectDisposedException
  captured in the unchanged guard-absent fixture during the independent baseline
  suite. This is distinct from the deterministic injected-boundary experiment.
- `validation-receipt.json`: full build passed, Shared 4,488 passed/35 existing
  opt-in skips, private-desktop Tray 4,304 passed/zero skips. Full validation used
  identical final source before commit creation; focused proof ran again on the
  committed head.

Prior-head CI passed and ClawSweeper found no code defects, requesting executed
behavior proof. The new head requires its own automatic CI/review result.
macOS, installed/live Gateway behavior and native executor behavior are not
claimed or required by this test-only change.
