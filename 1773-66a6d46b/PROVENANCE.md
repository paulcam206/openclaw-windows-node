# PR #1773 proof assets for head 66a6d46b

- PR head: `66a6d46b890d1dc4616702f5ced37da6a654060e` (tree `63935bb279911611f1bbb068ba079e047ce1915c`), rebased on `main` `4aee38a1bfaa2f7d241130a3548d94f0547a3c9c`.
- BEFORE: `main` `4aee38a1bfaa2f7d241130a3548d94f0547a3c9c`, built in the same guest.
- Guest: crabbox Hyper-V lease `cbx_9a6a8b6516bb` (VM `crabbox-63a4-pr1773-b2f3ead2`, released after capture), Windows 11 Enterprise Insider Preview 10.0.29683 x64, 6 vCPU, interactive session 1. WindowsAppRuntime installer 2.6.4 (Authenticode valid, Microsoft Corporation) registered `Microsoft.WindowsAppRuntime.2` 2.6.5.0 and `WinAppRuntime.Main.2` 2.6.4.0.
- App binaries (built in-guest with `./build.ps1`):
  - PR: `OpenClaw.Tray.WinUI.exe` SHA-256 `938BBB16E76B7335C8F802016C1C57B70C42808348C731E0E84E31D9F1D08CA8`, version `2026.11.1-paulcam206-markdown-details-disclosures.1+63...Sha.66a6d46b890d1dc4616702f5ced37da6a654060e`.
  - main: `OpenClaw.Tray.WinUI.exe` SHA-256 `77439EFBE56767876D369E7A51AD74137031A9B434A8E09A69A2D0DC069D5D2C`, version `2026.11.1-alpha.1+Branch.main.Sha.4aee38a1bfaa2f7d241130a3548d94f0547a3c9c`.
- Gateway: the loopback fixture Gateway (`tests/OpenClaw.GatewayFixtureHost`, SHA-256 `7CB43F90C70FDDFB8B3482D8D07CADD3F42A166640C638A49BC63151AA3DDAA0`) served a canned transcript. The theme and transcript seam is applied only to a separate host clone (`harness-seam.diff.txt`); the app binaries are unmodified builds of the pinned commits.
- Command: `dotnet <GatewayFixtureHost.dll> --app <OpenClaw.Tray.WinUI.exe> --artifacts <dir> --duration-seconds 240`, with `OPENCLAW_PROOF_THEME` and `OPENCLAW_PROOF_MAIN_TRANSCRIPT` set (`run-*.json`).
- Interaction: UI Automation `ExpandCollapsePattern` and `ScrollPattern` on the owned app window. Captures are owned-HWND `PrintWindow` images at 1000x740 (`report-*.txt` holds the UIA log).
- Not covered: physical mouse or keyboard input, Narrator, real Windows High Contrast, the installed MSIX Hub, and a real Gateway with a model-produced message.
