# Current-head normal onboarding failure and retry

Source: `fed3ec72294497568756fcbf50ca9888f156e45e`.
Capture completed 2026-10-21T21:39:34Z on Windows.

The actual source-built application used a new throwaway application profile.
It was not the installed Hub, a mounted test page, fixture mode or preview mode.
Normal Welcome, Existing Gateway selection, Next and two Check invocations
produced the application's real missing-credentials validation error.
No credentials were provided, no Gateway was installed/provisioned, and no
request to port18789 was made.

Both images were captured only from the exact owned app HWND using
PrintWindow(PW_RENDERFULLCONTENT), with strict nonblank qualification.
They are1080x960physical pixels (720x640DIP at150percent scaling).
The error bar's bottom is66physical pixels above the navigation buttons.
Back, Check connection and Next remain visible and enabled. Next performs its
own check before saving; these captures do not claim an authenticated connection
or successful completion. The second image follows a separate real Check
invocation, demonstrating the existing retry action remains usable.

Solid rectangles redact the address and setup-code input regions. No other
pixels were altered. The error itself, navigation and layout remain visible.
The diagnostics files retain only safe product strings, relative geometry,
binary/image hashes and process timing; no endpoint value, token, user path or
profile content is included.

The exact app PID53640 exited and was verified absent immediately afterward.
All helpers completed. The desktop slot was released before offline redaction.
