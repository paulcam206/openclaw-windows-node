param(
    [Parameter(Mandatory)][string]$AppExe,
    [Parameter(Mandatory)][string]$Label,        # e.g. branch-light
    [Parameter(Mandatory)][ValidateSet('Light','Dark')][string]$Theme,
    [Parameter(Mandatory)][string]$HostDll,
    [Parameter(Mandatory)][string]$OutDir,
    [Parameter(Mandatory)][string]$Transcript,
    [switch]$Expand
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes, System.Drawing
Add-Type @'
using System; using System.Runtime.InteropServices; using System.Text; using System.Collections.Generic;
public static class W {
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr dc, uint flags);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr a, int x, int y, int cx, int cy, uint f);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc p, IntPtr l);
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  public static List<IntPtr> ForPid(uint pid) {
    var r = new List<IntPtr>();
    EnumWindows((h, l) => { uint p; GetWindowThreadProcessId(h, out p); if (p == pid && IsWindowVisible(h)) r.Add(h); return true; }, IntPtr.Zero);
    return r;
  }
}
'@
[void][W]::SetProcessDPIAware()
New-Item -ItemType Directory $OutDir -Force | Out-Null
$artifacts = Join-Path $OutDir "host-artifacts-$Label"
$log = Join-Path $OutDir "host-$Label.log"

$psi = New-Object Diagnostics.ProcessStartInfo
$psi.FileName = 'dotnet'
$psi.Arguments = "`"$HostDll`" --app `"$AppExe`" --artifacts `"$artifacts`" --duration-seconds 240"
$psi.UseShellExecute = $false; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
$psi.EnvironmentVariables['OPENCLAW_PROOF_THEME'] = $Theme
$psi.EnvironmentVariables['OPENCLAW_PROOF_MAIN_TRANSCRIPT'] = $Transcript
$startedAt = (Get-Date).ToUniversalTime().ToString('o')
$hostProc = [Diagnostics.Process]::Start($psi)
$lines = New-Object Collections.Concurrent.ConcurrentQueue[string]
Register-ObjectEvent $hostProc OutputDataReceived -Action { $Event.MessageData.Enqueue($EventArgs.Data) } -MessageData $lines | Out-Null
Register-ObjectEvent $hostProc ErrorDataReceived  -Action { $Event.MessageData.Enqueue('ERR: ' + $EventArgs.Data) } -MessageData $lines | Out-Null
$hostProc.BeginOutputReadLine(); $hostProc.BeginErrorReadLine()

$all = New-Object Collections.Generic.List[string]
$appPid = $null; $profile = $null
$deadline = (Get-Date).AddSeconds(90)
while ((Get-Date) -lt $deadline -and -not $appPid) {
    $l = $null
    while ($lines.TryDequeue([ref]$l)) { $all.Add($l); if ($l -match 'App PID: (\d+)') { $appPid = [int]$Matches[1] }; if ($l -match '^Profile: (.+)$') { $profile = $Matches[1] } }
    Start-Sleep -Milliseconds 300
}
Start-Sleep 1
$l = $null; while ($lines.TryDequeue([ref]$l)) { $all.Add($l); if ($l -match '^Profile: (.+)$') { $profile = $Matches[1] } }
if (-not $appPid) { $all | Set-Content $log; Stop-Process -Id $hostProc.Id -Force; throw "Host did not become ready. See $log" }

try {
    # Own window only: pick the largest visible top-level window of this PID.
    $hwnd = [IntPtr]::Zero
    for ($i = 0; $i -lt 60 -and $hwnd -eq [IntPtr]::Zero; $i++) {
        $best = 0
        foreach ($h in [W]::ForPid([uint32]$appPid)) {
            $r = New-Object W+RECT; [void][W]::GetWindowRect($h, [ref]$r)
            $area = ($r.R - $r.L) * ($r.B - $r.T)
            if ($area -gt 90000 -and $area -gt $best) { $best = $area; $hwnd = $h }
        }
        if ($hwnd -eq [IntPtr]::Zero) { Start-Sleep -Milliseconds 500 }
    }
    if ($hwnd -eq [IntPtr]::Zero) { throw 'No visible app window found.' }
    function Fit {
        # 0x0014 = SWP_NOZORDER | SWP_NOACTIVATE; resizes only this owned window.
        [void][W]::SetWindowPos($hwnd, [IntPtr]::Zero, 0, 0, 1000, 740, 0x0014)
        Start-Sleep -Milliseconds 800
    }
    Fit
    $root = [Windows.Automation.AutomationElement]::FromHandle($hwnd)
    if ($root.Current.ProcessId -ne $appPid) { throw 'UIA root is not the owned app window.' }

    function Find-Name($name) {
        $c = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::NameProperty, $name)
        $root.FindFirst([Windows.Automation.TreeScope]::Descendants, $c)
    }
    function Find-NameLike($text) {
        $els = $root.FindAll([Windows.Automation.TreeScope]::Descendants, [Windows.Automation.Condition]::TrueCondition)
        foreach ($e in $els) { if ($e.Current.Name -like "*$text*") { return $e } }
        return $null
    }
    function Save-Window($name) {
        Fit
        $r = New-Object W+RECT; [void][W]::GetWindowRect($hwnd, [ref]$r)
        $w = $r.R - $r.L; $h = $r.B - $r.T
        $bmp = New-Object Drawing.Bitmap $w, $h
        $g = [Drawing.Graphics]::FromImage($bmp); $dc = $g.GetHdc()
        $ok = [W]::PrintWindow($hwnd, $dc, 2)   # PW_RENDERFULLCONTENT: owned HWND only, no foreground or desktop copy
        $g.ReleaseHdc($dc); $g.Dispose()
        $path = Join-Path $OutDir "$Label-$name.png"
        $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
        "{0} printwindow={1} {2}x{3}" -f (Split-Path $path -Leaf), $ok, $w, $h
    }

    # Wait for the canned conversation to load in the chat timeline.
    $loaded = $false
    for ($i = 0; $i -lt 60 -and -not $loaded; $i++) {
        $loaded = $null -ne (Find-NameLike 'normal message for contrast')
        if (-not $loaded) { Start-Sleep -Milliseconds 500 }
    }
    Start-Sleep 2
    $report = @()
    $report += "chat loaded: $loaded"
    $report += Save-Window '01-initial'

    if ($Expand) {
        $header = Find-Name 'Sources and evidence'
        if (-not $header) { throw 'Disclosure "Sources and evidence" not found in UIA tree.' }
        $report += "uia: found '$($header.Current.Name)' type=$($header.Current.LocalizedControlType)"
        $pat = $header.GetCurrentPattern([Windows.Automation.ExpandCollapsePattern]::Pattern)
        $report += "uia: state before = $($pat.Current.ExpandCollapseState)"
        $pat.Expand(); Start-Sleep 2
        try { $header.GetCurrentPattern([Windows.Automation.ScrollItemPattern]::Pattern).ScrollIntoView() } catch {}
        Start-Sleep 1
        $report += "uia: state after Expand = $($pat.Current.ExpandCollapseState)"
        $report += Save-Window '02-sources-expanded-nested-open'
        $raw = Find-Name 'Raw command output'
        if ($raw) {
            $p2 = $raw.GetCurrentPattern([Windows.Automation.ExpandCollapsePattern]::Pattern)
            $report += "uia: second disclosure before = $($p2.Current.ExpandCollapseState)"
            $p2.Expand(); Start-Sleep 2
            $report += "uia: second disclosure after Expand = $($p2.Current.ExpandCollapseState)"
            $report += Save-Window '03-all-expanded'
            $p2.Collapse(); $pat.Collapse(); Start-Sleep 2
            $report += "uia: after Collapse both = $($pat.Current.ExpandCollapseState)/$($p2.Current.ExpandCollapseState)"
            $report += Save-Window '04-recollapsed'
        }
    }
    $report | Set-Content (Join-Path $OutDir "report-$Label.txt")
    $report
}
finally {
    $all | Set-Content $log
    # Cleanup of this run only: the app first, then the host (which owns the scratch profile).
    Stop-Process -Id $appPid -ErrorAction SilentlyContinue
    Start-Sleep 2
    $hostProc.WaitForExit(30000) | Out-Null
    if (-not $hostProc.HasExited) { Stop-Process -Id $hostProc.Id -Force }
}
[pscustomobject]@{
    label = $Label; theme = $Theme; startedAtUtc = $startedAt; appExe = $AppExe; appPid = $appPid
    profile = $profile; hostDll = $HostDll
    appSha256 = (Get-FileHash $AppExe -Algorithm SHA256).Hash
    commandLine = "dotnet `"$HostDll`" --app `"$AppExe`" --artifacts `"$artifacts`" --duration-seconds 240"
    env = @{ OPENCLAW_PROOF_THEME = $Theme; OPENCLAW_PROOF_MAIN_TRANSCRIPT = $Transcript }
} | ConvertTo-Json | Set-Content (Join-Path $OutDir "run-$Label.json")
