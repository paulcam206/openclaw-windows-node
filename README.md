# Gateway themes proof assets

Screenshots for the stacked draft pull requests that bring OpenClaw dashboard themes to the Windows Companion
(openclaw/openclaw-windows-node). Everything here is synthetic: a fixture Gateway with made-up sessions, no real
accounts, tokens or paths.

Environment: Crabbox Hyper-V guest, Windows 11 Enterprise Insider Preview build 29683, interactive desktop at
1920x1080, Companion Debug builds launched by `OpenClaw.GatewayFixtureHost --scenario gateway-themes` with an
isolated profile, App theme Dark.

- `themes/`: Companion built from the themes PR head `feb7b394`. Settings › General and a chat with a running reply
  for Windows default, Tide, Manuscript, CRT and Phosphor; Follow Gateway theme off, on, and following a live switch to
  a plugin theme; Tide with Mica on and off.
- `branding/`: from the branding PR head `3c298fbb`. `branding-*.png` are renderings saved by
  `GatewayThemeBrandingTests` with `OPENCLAW_UI_PROOF_DIR` set (brand mark, then the working indicator); the `*-busy-dark.png`
  shots are the running Companion with a reply in progress.

- `upgrade/`: an isolated profile written by the stable v2026.11.1 portable Companion (App theme Dark and notifications
  changed in its own Settings), then this head on that profile: first launch, picking Manuscript, and a restart, from
  the themes PR head `5853ebd8`. `before-fix-2f103c4c-restart-settings.png` is the same restart before the startup fix.
