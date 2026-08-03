<#
.SYNOPSIS
    Splits the combined Meeting Notes and Stage 1 Research Findings docx files
    into per-meeting pairs (one notes excerpt + one matched research excerpt
    per meeting), ready to be fed into the meeting-research-memo skill.

.NOTES
    This script only handles the mechanical splitting/pairing step. Drafting
    the actual memos (applying the two fixed rules in
    .claude\skills\meeting-research-memo\SKILL.md) is judgment-based work and
    should be done by Claude Code directly in a session, using the paired
    files this script produces as input.
#>

param(
    [string]$MeetingNotesPath = "C:\Users\lauren.pendar\Desktop\AI Assignment 4B\Meeting Notes.docx",
    [string]$ResearchPath     = "C:\Users\lauren.pendar\Desktop\AI Assignment 4B\Stage 1 Research Findings.docx",
    [string]$ProjectDir       = "C:\Users\lauren.pendar\Desktop\Jail Provider Claude Code",
    [string]$PairsDir         = "C:\Users\lauren.pendar\Desktop\Jail Provider Claude Code\pairs"
)

$ErrorActionPreference = "Stop"

function Get-DocxText {
    param([string]$DocxPath)
    $tempDir = [System.IO.Path]::GetTempPath()
    $tempExtract = Join-Path $tempDir ("docx_extract_" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempExtract -Force | Out-Null
    $tempZip = Join-Path $tempDir ([guid]::NewGuid().ToString("N") + ".zip")
    Copy-Item -LiteralPath $DocxPath -Destination $tempZip
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
    Remove-Item -LiteralPath $tempZip -Force
    $xmlPath = Join-Path $tempExtract "word\document.xml"
    [xml]$xml = Get-Content -Raw $xmlPath
    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
    $paras = $xml.SelectNodes("//w:body//w:p", $ns)
    $lines = foreach ($p in $paras) {
        $texts = $p.SelectNodes(".//w:t", $ns)
        ($texts | ForEach-Object { $_.InnerText }) -join ""
    }
    return ,$lines
}

function Split-ByMeeting {
    param([string[]]$Lines)
    $sections = @{}
    $currentNum = $null
    $currentTitle = $null
    $buffer = New-Object System.Collections.Generic.List[string]
    foreach ($line in $Lines) {
        if ($line -match '^\s*Meeting\s+([0-9]+)\s*:\s*(.*)$') {
            if ($currentNum) {
                $sections[$currentNum] = [pscustomobject]@{ Title = $currentTitle; Text = ($buffer -join "`n") }
            }
            $currentNum = [int]$Matches[1]
            $currentTitle = $Matches[2].Trim()
            $buffer.Clear()
            $buffer.Add($line)
        } else {
            $buffer.Add($line)
        }
    }
    if ($currentNum) {
        $sections[$currentNum] = [pscustomobject]@{ Title = $currentTitle; Text = ($buffer -join "`n") }
    }
    return $sections
}

Write-Host "Extracting text from source documents..."
$notesLines    = Get-DocxText -DocxPath $MeetingNotesPath
$researchLines = Get-DocxText -DocxPath $ResearchPath
$notesSections    = Split-ByMeeting -Lines $notesLines
$researchSections = Split-ByMeeting -Lines $researchLines

New-Item -ItemType Directory -Path $PairsDir -Force | Out-Null

$meetingNumbers = $notesSections.Keys | Sort-Object
$manifest = @()

foreach ($num in $meetingNumbers) {
    $notesSection    = $notesSections[$num]
    $researchSection = $researchSections[$num]
    if (-not $researchSection) {
        Write-Warning "No matched research section found for Meeting $num - writing notes only, research file will note this."
    }

    $safeTitle = ($notesSection.Title -replace '[^\w\- ]', '') -replace '\s+', '_'
    $safeTitle = $safeTitle.Substring(0, [Math]::Min(40, $safeTitle.Length)).Trim('_')
    $baseName = "Meeting${num}_${safeTitle}"

    $notesFile    = Join-Path $PairsDir "${baseName}_notes.txt"
    $researchFile = Join-Path $PairsDir "${baseName}_research.txt"

    Set-Content -LiteralPath $notesFile -Value $notesSection.Text -Encoding utf8
    if ($researchSection) {
        Set-Content -LiteralPath $researchFile -Value $researchSection.Text -Encoding utf8
    } else {
        Set-Content -LiteralPath $researchFile -Value "(no matched research section found for this meeting)" -Encoding utf8
    }

    Write-Host "Meeting ${num}: $($notesSection.Title)"
    Write-Host "  notes    -> $notesFile"
    Write-Host "  research -> $researchFile"

    $manifest += [pscustomobject]@{
        Meeting      = $num
        Title        = $notesSection.Title
        NotesFile    = $notesFile
        ResearchFile = $researchFile
    }
}

$manifest | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PairsDir "manifest.json") -Encoding utf8
Write-Host "`nDone. $($meetingNumbers.Count) meeting/research pairs written to: $PairsDir"
Write-Host "Manifest written to: $(Join-Path $PairsDir 'manifest.json')"
