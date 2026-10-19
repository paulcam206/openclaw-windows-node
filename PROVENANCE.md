# Proof assets for the native Markdown disclosure PR

Synthetic content only (a canned fixture conversation); nothing from a real profile, gateway or conversation. This branch only hosts images for the PR description and can be deleted after the PR lands.

# Real Hub proof: provenance (rebased onto origin/main 50d0b34a)

Supersedes `PROVENANCE-superseded-pre-rebase.md` (captured at 9a6faced on base 037c17dc).
Captured 2026-10-19 13:16-13:18 PDT (20:16-20:18 UTC) on Paul's dev machine, after a reboot, as the
real `OpenClaw.Tray.WinUI.exe` (Release, unpackaged, win-x64) rendering a canned conversation through
the production chat timeline. Not the standalone preview, not the synthetic WinUI test fixture, not the
installed MSIX Hub.

## Builds

| Role | Commit | Worktree | `OpenClaw.Tray.WinUI.exe` SHA-256 | `OpenClaw.Tray.WinUI.dll` SHA-256 |
|---|---|---|---|---|
| AFTER (disclosure change) | `7ef24b11` (`47d19134` + test-only commit) on origin/main `50d0b34a` | `paulcam206-crispy-sniffle` | `B93F693C036F0613BA66E01A5CB0DB199A064C7817E029BFD0DAD043ADA38895` | `B57CDCCEC6C91F6C566F95C86335B8F258C55864CF6F88D6E5C1B8A77CF5BDCF` |
| BEFORE (main) | `50d0b34a` (origin/main, detached) | `proof-base` | `FC037B1A2851847656F6EC444F8338A2FCE1E2AC8225D478EB7CC2A304E742AF` | `25F44A755ABF4E63F5B0BF5F5264835D29C9EFF7DAF67D0C97B50FD64441E13F` |

`OpenClaw.Chat.dll`: AFTER `98B9FC86F313CC884DE6A1614DBEEE0DAD615D2D4D2864DC43E29983A965D019`,
BEFORE `6A0C44B993DA988CAA1FD7A2F49ADC3022D7ADC401397DD78EA42C84F611F557`.
Both built with `./build.ps1 -Configuration Release` (all projects succeeded; logs `rebase-build-release.log`
and `proof-base-build.log`). Exe path: `src\OpenClaw.Tray.WinUI\bin\Release\net10.0-windows10.0.22621.0\win-x64\`.

## Isolation seam and canned content

Same as the pre-rebase run: `tests\OpenClaw.GatewayFixtureHost` (loopback fixture Gateway plus an isolated
real app with a temp profile, inherited `OPENCLAW_*` stripped, random token and ports, autostart, node mode,
notifications and telemetry off). Paul's installed Hub (PID 17616, started after the reboot) and gateway were
running and not touched; only PIDs this script launched were stopped; temp profiles were removed.

The local, uncommitted seam (`harness-seam.patch`: env vars `OPENCLAW_PROOF_MAIN_TRANSCRIPT` and
`OPENCLAW_PROOF_THEME`) was re-applied cleanly to a throwaway detached worktree `proof-harness` at `7ef24b11`
and not committed anywhere. `canned-transcript.json` is unchanged. Capture method is unchanged
(`Capture-HubProof.ps1`: own-HWND `PrintWindow`, resize of only that window, UIA `ExpandCollapsePattern`).

Runs (UTC): branch-light 20:16:16 (PID 32024), branch-dark 20:16:55 (PID 21176),
base-main-light 20:16:41 (PID 43076), base-main-dark 20:17:19 (PID 18252). UIA log lines are in
`provenance\report-*.txt`: "Sources and evidence" and "Raw command output" each Collapsed -> Expanded,
then both Collapsed again.

## Did upstream (#1705 welcome, usage freshness, placement picker) change disclosure rendering?

No. `ReactorChatTimeline.BuildSafeMarkdown` remains the only Markdown entry point (call sites at the entry
text and the empty-text fallback); the rebase applied cleanly. The recapture shows the same BEFORE (literal
tags on main) and AFTER (native expanders), Light and Dark. Differences versus the pre-rebase set are
unrelated upstream chrome only: the sidebar toggle icon, and the BEFORE shots are scrolled to the bottom of
the long message so the tags are visible mid-message rather than at the top.

## Files in `for-pr` (SHA-256 prefix)

| File | Prefix |
|---|---|
| real-hub-AFTER-light-1-collapsed.png | 196093BF3211 |
| real-hub-AFTER-light-2-expanded-nested.png | 91951B90B923 |
| real-hub-AFTER-light-3-all-expanded.png | 84B53BDDA525 |
| real-hub-AFTER-light-4-recollapsed.png | 68A46696C496 |
| real-hub-AFTER-dark-1-collapsed.png | A0A655DF14D6 |
| real-hub-AFTER-dark-2-expanded-nested.png | 400ED1C82512 |
| real-hub-AFTER-dark-3-all-expanded.png | 4579CAD402F9 |
| real-hub-AFTER-dark-4-recollapsed.png | 01820A621172 |
| real-hub-BEFORE-main-light-literal-tags.png | 8C16DF889D17 |
| real-hub-BEFORE-main-dark-literal-tags.png | 523010CA01D2 |

`for-pr\secondary-fixture` holds the six synthetic test-host PNGs captured pre-rebase on 9a6faced. They are
secondary; the rebased native proofs pass again (see the PR body) but those images were not regenerated.

## Not verified

Installed MSIX Hub; Narrator or any screen reader; real Windows High Contrast (not captured); physical
mouse or keyboard input (UIA invoke only); a real Gateway or model-produced message.

## AFTER images recaptured on the final head `bc268cef` (2026-10-19 15:05 PDT, 22:05-22:06 UTC)

The `real-hub-AFTER-*` files in `for-pr` were replaced with captures of `bc268cef` (three parser-only fixes after `7ef24b11`). Same method, harness seam, canned transcript, base and BEFORE images as above. AFTER exe built with `./build.ps1 -Configuration Release` from `bc268cef`: `OpenClaw.Tray.WinUI.exe` SHA-256 `2A315B221C8FEB6684FC0A6F013B313B51A13588A09DD0C2B3F56E2E3E94E1E2`, `OpenClaw.Tray.WinUI.dll` `28D73018DD3F4C445E3C402A0652B39CAA5BB79DC0BCFBCAF29B6D7A130082ED`. Runs: branch-light 22:05:17Z, branch-dark 22:05:42Z; UIA log lines in `provenance-after-bc268cef`. Several images are byte-identical to the 7ef24b11 set because the rendering did not change. The 7ef24b11 images are kept in `for-pr-superseded-7ef24b11`. The table prefixes above for AFTER files are superseded by: dark-1 D173A344AC17, dark-2 9AB32990116A, dark-3 2A252EF9B650, dark-4 81178C6435B5, light-1 196093BF3211, light-2 91951B90B923, light-3 84B53BDDA525, light-4 E27B667A7168.


## AFTER images recaptured on the FINAL head cca9bb9a (2026-10-19 15:41 PDT)

Supersedes the bc268cef section above. Same method, harness seam, transcript, base and BEFORE images. AFTER built with ./build.ps1 -Configuration Release from cca9bb9a: `OpenClaw.Tray.WinUI.exe` SHA-256 `3D50507F00EC1015163BC72A1F9027F51CC1D738C578A5F3999407BDA553A3AE`, `OpenClaw.Tray.WinUI.dll` `62554DF1B07A17D177F31C494EB891BADFE88687CE07A5ED0490EB7695D90F60`. Runs: branch-dark 10/19/2026 22:50:01; branch-light 10/19/2026 22:49:36 (UTC). UIA log: both disclosures Collapsed -> Expanded -> Collapsed (provenance-after-cca9bb9a). Current for-pr AFTER prefixes: dark-1-collapsed 2BBACB1FA672, dark-2-expanded-nested 9C1BBF084B96, dark-3-all-expanded D98419654E7C, dark-4-recollapsed F7311B8EC440, light-1-collapsed D812D0A57710, light-2-expanded-nested 612A0D2D10C1, light-3-all-expanded E62832987AEA, light-4-recollapsed 14C97A30446C. Earlier AFTER sets are kept in for-pr-superseded-7ef24b11 and for-pr-superseded-bc268cef.



## AFTER images on the FINAL head f5ecc7b9 (2026-10-19 16:38 PDT, 23:38-23:39 UTC)

Supersedes the cca9bb9a and bc268cef sections. Same method, harness seam, transcript, base and BEFORE images. AFTER built with `./build.ps1 -Configuration Release` from `f5ecc7b9`: `OpenClaw.Tray.WinUI.exe` SHA-256 `45DB8ECE6CC35552DF7E30CAC2F6A882E6A9CF7BD03CC344B39E481344346DAD`, `OpenClaw.Tray.WinUI.dll` `FEFB6BEBD0D791E08D501BACA5B58667E5FF670AA81ED1BEF752B7D858031FDA`. Runs 23:38:36Z (light) and 23:39:16Z (dark); both disclosures Collapsed -> Expanded -> Collapsed through UIA. AFTER image prefixes: dark-1-collapsed 7337075EC917, dark-2-expanded-nested 7C3C80708D79, dark-3-all-expanded 9AC148F6F241, dark-4-recollapsed D03F381B9647, light-1-collapsed 9BE9FFDE875A, light-2-expanded-nested 15B5A4778F8B, light-3-all-expanded 182F42833197, light-4-recollapsed 601D415EBB1E.


