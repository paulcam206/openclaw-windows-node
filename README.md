# Current-head proof for #1773 and #1795 (2026-10-29)

Throwaway crabbox Hyper-V guests (provider `hyperv`, template `windows-readiness-template-v3`), Windows 11 Enterprise Insider Preview 10.0.29683 x64, 1024x768, interactive console session. WindowsAppRuntime 2.6.4 installed in each guest. Both guests are deleted.

- #1773 head `ef5821c587dc29db4f1b8537c45721b7759062f8` (lease `cbx_76a0383535c2`). App built in-guest; WindowsAppSDK 2.6.4 in deps.json.
  - `native/`: `NativeMarkdownProof` captures (Light, Dark, HighContrast) with `OPENCLAW_VISUAL_TEST=1`; each theme passed in its own process, plus the inert-content case.
  - `real-hub/`: the unmodified PR-head `OpenClaw.Tray.WinUI.exe` against the loopback fixture Gateway serving `method/canned-transcript.json` (harness seam: `method/harness-seam.diff`, applied only to a separate fixture-host clone). UIA `ExpandCollapsePattern` drove expand/collapse; `report-*.txt` are the UIA logs.
- #1795 head `99e9597b63774b9c0ba509330b818f8e4e442e9d` (lease `cbx_cbc09cb6594f`).
  - `continuity/`: `scripts/test-gateway-fixture.ps1 -Screenshots` captures, including the new ordinary-composer `chat.send` after the held/released roster reconnect, and the unsupported `agents.list` path.
  - `settings-host/`: guest-only harness `method/GatewayFixtureSettingsHostContinuityProof.cs` (not part of the PR). Settings opens inside the Workspace window, the roster is held across a reconnect, chat returns with the same assistant and conversation, and the ordinary composer sends. `settings-host-gateway-requests.txt` is the fixture Gateway's request record, which ends in `chat.send session=agent:research:fixture-other outcome=ok`.

All data is synthetic fixture data. No credentials, live providers or host paths are included.
