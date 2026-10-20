# Private-desktop validation proof

Head: `e37970aa1660a3746d6e08e862f61f663311b87a`.
This changes test infrastructure, not the Hub product, SDK or sandbox policy.

`runtime-receipt.json` contains actual runtime results from the committed real
shipped-SDK desktop regression. The native child reports its token/mitigation
before dynamically loading USER32. The old NULL-security desktop is retained as
a negative control; the new owned desktop copies Default's DACL and mandatory
label without changing any existing desktop.

The four cases require old-desktop USER32/PowerShell failure, new-desktop USER32
load and the exact controlled PowerShell marker, with contained exit 0 and no
timeout for the positive cases. The negative case does not infer a timeout from
English text or elapsed time. Every owned desktop must be removed.

Additional actual-launch guards prove that exact desktop names are rejected,
the child's observed generated name avoids a retained live contender, the
contender's security is unchanged, and caller environment values and unset
variables survive success and a real missing-executable failure. The child
reports the intended isolated overrides. Existing native compositor/input proof
guards are not involved or weakened.

The initial independent review found two ownership/environment issues; both
were fixed and the actual remediation was independently re-reviewed without
remaining P0-P3 findings. This is a source review, not a helper-isolation or
runtime-model attestation.

Exact runtime command, with private argument values replaced by aliases:

```powershell
tests\OpenClaw.DesktopHarness\Test-DesktopFidelity.ps1 -NativeExecutable <verified-shipped-executor> -ExpectedNativeSha256 <verified-digest> -OutputDirectory <empty-proof-directory>
```

Full build, Shared, private-desktop Tray, and documentation checks passed on
this head. Counts and actual native digest are in the receipt. No installed
Companion, live Gateway, mock Gateway, macOS or upstream CI success is claimed.
Earlier combined formal WSL/MXC 18/18 is separate historical evidence. Its first
failure was this harness desktop-security mismatch; it passed after that
environment correction, without a native or product-policy patch.

Known shipped limitation: native serialization drops typed timeout provenance.
The Hub cannot truthfully classify every native deadline failure from existing
output, which can retain exit -1 and timedOut=false. No message/duration guess
or dependency on an unpublished native change is introduced here.
