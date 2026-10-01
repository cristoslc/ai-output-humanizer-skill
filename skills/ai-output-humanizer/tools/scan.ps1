# Mechanical regex-scan engine (Windows PowerShell 5.1+; runs under pwsh too).
# One of the four catalog engines. Parses ..\..\references\regex-scan.md at
# run time and never duplicates patterns into code. Catalog patterns are
# consumed near-verbatim: .NET regex honors \uXXXX escapes, lookaheads, and
# backreferences.
#
# Contract (identical across engines): engine [file|-] [--json]
# Exit: 0 within gate; 1 gate violation; 2 usage or catalog parse error.
#
# Run: powershell -NoProfile -File scan.ps1 input.txt

$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$catalogPath = Join-Path $here '..\references\regex-scan.md'
if (-not (Test-Path $catalogPath)) {
    [Console]::Error.WriteLine("scan: catalog not found: $catalogPath")
    exit 2
}

function Write-ScanStderr([string]$msg) {
    [Console]::Error.WriteLine("scan: $msg")
}

# UTF-8 in, matching JS/Python/Perl byte-for-byte output (LF endings, no BOM).
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$out = New-Object System.Text.StringBuilder

function Add-Out([string]$s) { [void]$out.Append($s) }

# ------------------------------------------------------------------ args ---#
$jsonMode = $false
$fileArg = $null
$saw = $false
for ($i = 0; $i -lt $args.Count; $i++) {
    $a = $args[$i]
    if ($a -eq '--json') { $jsonMode = $true }
    elseif ($a -eq '-') { if ($saw) { Write-ScanStderr 'multiple input files'; exit 2 }; $fileArg = '-'; $saw = $true }
    elseif ($a -like '--*') { Write-ScanStderr "unknown option: $a"; exit 2 }
    else { if ($saw) { Write-ScanStderr 'multiple input files'; exit 2 }; $fileArg = $a; $saw = $true }
}

if ($fileArg -eq $null -or $fileArg -eq '-') {
    if ($fileArg -eq $null -and -not [Console]::IsInputRedirected) {
        Write-ScanStderr 'no input file and stdin is a terminal (usage: engine [file|-] [--json])'
        exit 2
    }
    $text = [Console]::In.ReadToEnd()
    if ($null -eq $text) { $text = '' }
} else {
    try {
        $text = [IO.File]::ReadAllText($fileArg, [Text.Encoding]::UTF8)
    } catch {
        Write-ScanStderr "cannot read input: $fileArg"
        exit 2
    }
}

# ------------------------------------------------------------------ parse ---#
$md = [IO.File]::ReadAllText($catalogPath, [Text.Encoding]::UTF8)

$entries = New-Object System.Collections.ArrayList
$sev = $null
$title = $null
$buf = $null
$parseError = $null

function Flush-Section {
    # PS scoping: assignments inside a function are function-local; writes to
    # script-scope vars must use the $script: prefix.
    if ($script:title -eq $null) { return }
    if ($script:buf -ne $null) {
        [void]$script:entries.Add(@{ title = $script:title; sev = $script:sev; kind = 'regex'; source = [string]::Join("`n", $script:buf.ToArray()) })
    } elseif ($script:sev -eq 'LIMIT' -or $script:sev -eq 'SOFT') {
        [void]$script:entries.Add(@{ title = $script:title; sev = $script:sev; kind = 'judgment' })
    } elseif ($script:sev -eq 'HARD') {
        if ($script:title.IndexOf('Em dash') -ge 0) {
            [void]$script:entries.Add(@{ title = $script:title; sev = $script:sev; kind = 'literal' })
        } else {
            $script:parseError = "HARD section without a fence: `"$script:title`""
        }
    } else {
        $script:parseError = "section before any HARD/LIMIT/SOFT header: `"$script:title`""
    }
    $script:title = $null
    $script:buf = $null
}

$lines = $md -split "`n", -1
foreach ($raw in $lines) {
    if ($raw -match '^## (HARD|LIMIT|SOFT) patterns\s*$') {
        Flush-Section
        if ($parseError -ne $null) { Write-ScanStderr "catalog parse error: $parseError"; exit 2 }
        $sev = $Matches[1]
        continue
    }
    if ($raw -match '^### (.+)$') {
        Flush-Section
        if ($parseError -ne $null) { Write-ScanStderr "catalog parse error: $parseError"; exit 2 }
        $title = $Matches[1].Trim()
        continue
    }
    if ($title -ne $null) {
        if ($raw -match '^```') {
            if ($buf -ne $null) {
                [void]$entries.Add(@{ title = $title; sev = $sev; kind = 'regex'; source = [string]::Join("`n", $buf.ToArray()) })
                $title = $null
                $buf = $null
            } else {
                $buf = New-Object System.Collections.ArrayList
            }
            continue
        }
        if ($buf -ne $null) { [void]$buf.Add($raw); continue }
        # prose before an opening fence: ignore
    }
}
Flush-Section
if ($parseError -ne $null) { Write-ScanStderr "catalog parse error: $parseError"; exit 2 }
if ($entries.Count -eq 0) { Write-ScanStderr 'catalog parse error: no pattern sections found'; exit 2 }

$records = New-Object System.Collections.ArrayList
foreach ($e in $entries) {
    $disp = ($e.title -split [regex]::Escape(' — '))[0]
    $max = $null
    if ($e.sev -eq 'LIMIT' -and $e.title -match 'LIMIT (\d+)') { $max = [int]$Matches[1] }
    [void]$records.Add(@{ name = $disp; sev = $e.sev; kind = $e.kind; source = $e.source; max = $max })
}

# ------------------------------------------------------------------ scan ---#
# line/col computation over UTF-16 indexes (BMP-only content: curly quotes),
# same 1-based scheme as the other engines.
$lineStarts = New-Object System.Collections.ArrayList
[void]$lineStarts.Add(0)
for ($i = 0; $i -lt $text.Length; $i++) {
    if ($text[$i] -eq "`n") { [void]$lineStarts.Add($i + 1) }
}

function Get-LC([int]$idx) {
    $lo = 0; $hi = $lineStarts.Count - 1
    while ($lo -lt $hi) {
        $mid = [int](($lo + $hi + 1) / 2)
        if ($lineStarts[$mid] -le $idx) { $lo = $mid } else { $hi = $mid - 1 }
    }
    @([int]($lo + 1), [int]($idx - $lineStarts[$lo] + 1))
}

function Clip([string]$s) {
    $s = $s.Replace("`n", [char]0x23CE)
    if ($s.Length -gt 64) { return $s.Substring(0, 61) + '...' }
    return $s
}

$results = New-Object System.Collections.ArrayList
$violation = $false
foreach ($r in $records) {
    if ($r.kind -eq 'judgment') {
        [void]$results.Add(@{ name = $r.name; severity = $r.sev; count = $null; judged = $true; spans = @() })
        continue
    }
    $hits = New-Object System.Collections.ArrayList
    if ($r.kind -eq 'literal') {
        $rx = New-Object System.Text.RegularExpressions.Regex('—|--')
    } else {
        try {
            $rx = New-Object System.Text.RegularExpressions.Regex($r.source, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
        } catch {
            Write-ScanStderr ('catalog parse error: pattern "' + $r.name + '" does not compile: ' + $_.Exception.Message)
            exit 2
        }
    }
    foreach ($m in $rx.Matches($text)) {
        $sc = Get-LC $m.Index
        $ec = Get-LC ($m.Index + $m.Length)
        [void]$hits.Add(@{ s = $sc; e = $ec; t = (Clip $m.Value) })
    }
    $spans = New-Object System.Collections.ArrayList
    foreach ($h in $hits) {
        [void]$spans.Add(@{ start = @{ line = $h.s[0]; col = $h.s[1] }; end = @{ line = $h.e[0]; col = $h.e[1] }; text = $h.t })
    }
    $n = $hits.Count
    [void]$results.Add(@{ name = $r.name; severity = $r.sev; count = $n; judged = $false; spans = $spans.ToArray() })
    if ($r.sev -eq 'HARD' -and $n -gt 0) { $violation = $true }
    if ($r.sev -eq 'LIMIT' -and $r.max -ne $null -and $n -gt $r.max) { $violation = $true }
}

# --------------------------------------------------------------- output ---#
$width = 0
foreach ($r in $results) { if ($r.name.Length -gt $width) { $width = $r.name.Length } }

if ($jsonMode) {
    $ordered = New-Object System.Collections.ArrayList
    foreach ($r in $results) {
        $spansOut = New-Object System.Collections.ArrayList
        foreach ($s in $r.spans) {
            [void]$spansOut.Add(@{
                start = @{ line = [int]$s.start['line']; col = [int]$s.start['col'] }
                end = @{ line = [int]$s.end['line']; col = [int]$s.end['col'] }
                text = $s.text
            })
        }
        [void]$ordered.Add(@{
            name = $r.name
            severity = $r.severity
            count = $r.count
            judged = $r.judged
            spans = $spansOut.ToArray()
        })
    }
    $json = ConvertTo-Json -InputObject @($ordered) -Compress -Depth 6
    [void]$out.Append($json)
    [void]$out.Append([char]10)
} else {
    $fmtName = '{0,' + $width + '}'
    foreach ($r in $results) {
        if ($r.judged) {
            $label = 'JUDGMENT REQUIRED'
            Add-Out ($r.severity + '  ' + ($fmtName -f $r.name) + '  ' + $label + "`n")
        } else {
            $unit = if ($r.count -eq 1) { 'hit' } else { 'hits' }
            Add-Out ($r.severity + '  ' + ($fmtName -f $r.name) + '  ' + $r.count + ' ' + $unit + "`n")
            foreach ($s in $r.spans) {
                Add-Out ('  L' + $s.start['line'] + ' col' + $s.start['col'] + '-L' + $s.end['line'] + ' col' + $s.end['col'] + '  "' + $s.text + '"' + "`n")
            }
        }
    }
}

[Console]::Out.Write($out.ToString())
[Console]::Out.Flush()
exit $(if ($violation) { 1 } else { 0 })