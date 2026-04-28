# Rebrand lengkap ke Bandung Bersuara
# Menjaga encoding UTF-8, membuat backup, mengganti branding, warna, dan logo teks.

$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$WorkspaceRoot = $PSScriptRoot
$Timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$LogFile = Join-Path $WorkspaceRoot "rebrand-bandung-bersuara-$Timestamp.log"
$CurrentScript = $MyInvocation.MyCommand.Path

$Changed = @{
    MainPages = New-Object 'System.Collections.Generic.HashSet[string]'
    ArticlePages = New-Object 'System.Collections.Generic.HashSet[string]'
    CSS = New-Object 'System.Collections.Generic.HashSet[string]'
    Package = New-Object 'System.Collections.Generic.HashSet[string]'
    Docs = New-Object 'System.Collections.Generic.HashSet[string]'
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Type = 'INFO'
    )

    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Type] $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding utf8
}

function Normalize-Text {
    param([string]$Text)

    if ($null -eq $Text) { return $Text }

    return $Text.Replace([string][char]0x201C, '"')
                .Replace([string][char]0x201D, '"')
                .Replace([string][char]0x2018, "'")
                .Replace([string][char]0x2019, "'")
                .Replace([string][char]0x2013, '-')
                .Replace([string][char]0x2014, '-')
                .Replace([string][char]0xFFFD, ' ')
                .Replace([string][char]0x00A0, ' ')
}

function Mark-Changed {
    param([string]$Path)

    if ($Path -match '\\article\\') {
        $null = $Changed.ArticlePages.Add($Path)
    }
    elseif ($Path -match '\\.css$') {
        $null = $Changed.CSS.Add($Path)
    }
    elseif ($Path -match '(\\|^)(package-lock\.json|package\.json)$') {
        $null = $Changed.Package.Add($Path)
    }
    elseif ($Path -match '\\tools\\' -or $Path -match '\.(md|toml|txt|ps1)$') {
        $null = $Changed.Docs.Add($Path)
    }
    else {
        $null = $Changed.MainPages.Add($Path)
    }
}

function Save-IfChanged {
    param(
        [string]$Path,
        [string]$Original,
        [string]$Updated
    )

    if ($Updated -ne $Original) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($Path, $Updated, $utf8NoBom)
        Mark-Changed -Path $Path
        $relativePath = $Path.Replace($WorkspaceRoot + [System.IO.Path]::DirectorySeparatorChar, '')
        Write-Log -Message "Updated: $relativePath"
    }
}

function Apply-Replacements {
    param(
        [string]$Content,
        [array]$Pairs
    )

    foreach ($pair in $Pairs) {
        $Content = $Content.Replace($pair.Old, $pair.New)
    }

    return $Content
}

$BrandLogo = '<span style="font-weight: 700; color: #BE123C; font-size: 24px; letter-spacing: -0.5px;">BANDUNG<span style="color: #1F5F1F; font-weight: 400; font-size: 16px; margin-left: 3px;">BERSUARA</span></span>'

$BrandPairs = @(
    @{ Old = 'https://twitter.com/WartaJanten'; New = 'https://twitter.com/bandungbersuara' },
    @{ Old = 'https://twitter.com/wartajanten'; New = 'https://twitter.com/bandungbersuara' },
    @{ Old = 'https://twitter.com/indonesiadaily'; New = 'https://twitter.com/bandungbersuara' },
    @{ Old = 'https://facebook.com/WartaJanten'; New = 'https://facebook.com/bandungbersuara' },
    @{ Old = 'https://facebook.com/wartajanten'; New = 'https://facebook.com/bandungbersuara' },
    @{ Old = 'https://facebook.com/indonesiadaily'; New = 'https://facebook.com/bandungbersuara' },
    @{ Old = 'https://instagram.com/WartaJanten'; New = 'https://instagram.com/bandungbersuara' },
    @{ Old = 'https://instagram.com/wartajanten'; New = 'https://instagram.com/bandungbersuara' },
    @{ Old = 'https://instagram.com/indonesiadaily'; New = 'https://instagram.com/bandungbersuara' },
    @{ Old = 'https://youtube.com/@WartaJanten'; New = 'https://youtube.com/@bandungbersuara' },
    @{ Old = 'https://youtube.com/@wartajanten'; New = 'https://youtube.com/@bandungbersuara' },
    @{ Old = 'https://youtube.com/@indonesiadaily'; New = 'https://youtube.com/@bandungbersuara' },
    @{ Old = 'https://linkedin.com/company/WartaJanten'; New = 'https://linkedin.com/company/bandungbersuara' },
    @{ Old = 'https://linkedin.com/company/wartajanten'; New = 'https://linkedin.com/company/bandungbersuara' },
    @{ Old = 'https://linkedin.com/company/indonesiadaily'; New = 'https://linkedin.com/company/bandungbersuara' },
    @{ Old = 'https://mail.google.com/mail/?view=cm&fs=1&to=WartaJanten33@gmail.com'; New = 'https://mail.google.com/mail/?view=cm&fs=1&to=bandungbersuara@gmail.com' },
    @{ Old = 'https://mail.google.com/mail/?view=cm&fs=1&to=wartajanten33@gmail.com'; New = 'https://mail.google.com/mail/?view=cm&fs=1&to=bandungbersuara@gmail.com' },
    @{ Old = 'https://mail.google.com/mail/?view=cm&fs=1&to=wartajanten@gmail.com'; New = 'https://mail.google.com/mail/?view=cm&fs=1&to=bandungbersuara@gmail.com' },
    @{ Old = 'WartaJanten33@gmail.com'; New = 'bandungbersuara@gmail.com' },
    @{ Old = 'wartajanten33@gmail.com'; New = 'bandungbersuara@gmail.com' },
    @{ Old = 'WartaJanten@gmail.com'; New = 'bandungbersuara@gmail.com' },
    @{ Old = 'wartajanten@gmail.com'; New = 'bandungbersuara@gmail.com' },
    @{ Old = 'indonesiadaily@gmail.com'; New = 'bandungbersuara@gmail.com' },
    @{ Old = 'alt="WartaJanten"'; New = 'alt="BandungBersuara"' },
    @{ Old = 'alt="IndonesiaDaily"'; New = 'alt="BandungBersuara"' },
    @{ Old = 'Warta Janten'; New = 'Bandung Bersuara' },
    @{ Old = 'Indonesia Daily'; New = 'Bandung Bersuara' },
    @{ Old = 'WartaJanten'; New = 'Bandung Bersuara' },
    @{ Old = 'IndonesiaDaily'; New = 'Bandung Bersuara' },
    @{ Old = 'wartajanten'; New = 'bandungbersuara' },
    @{ Old = 'indonesiadaily'; New = 'bandungbersuara' }
)

$ColorPairs = @(
    @{ Old = '#065F46'; New = '#BE123C' },
    @{ Old = '#1E3A5F'; New = '#1F5F1F' },
    @{ Old = '#022C22'; New = '#4C0519' },
    @{ Old = '#FFCC00'; New = '#BE123C' },
    @{ Old = '#ffcc00'; New = '#be123c' },
    @{ Old = '#FC0'; New = '#BE123C' },
    @{ Old = '#fc0'; New = '#be123c' },
    @{ Old = '#1E2024'; New = '#4C0519' },
    @{ Old = '#1e2024'; New = '#4c0519' },
    @{ Old = '#31404B'; New = '#1F5F1F' },
    @{ Old = '#31404b'; New = '#1f5f1f' },
    @{ Old = '#b38f00'; New = '#9F1239' },
    @{ Old = '#cca300'; New = '#9F1239' },
    @{ Old = '#bf9900'; New = '#881337' },
    @{ Old = 'rgba(222, 179, 6, 0.5)'; New = 'rgba(190, 18, 60, 0.35)' },
    @{ Old = 'rgba(222,179,6,0.5)'; New = 'rgba(190,18,60,0.35)' }
)

$PackagePairs = @(
    @{ Old = '"name": "wartajanten-article-generator"'; New = '"name": "bandungbersuara-article-generator"' },
    @{ Old = '"name": "indonesiadaily-article-generator"'; New = '"name": "bandungbersuara-article-generator"' },
    @{ Old = '"name": "wartajanten"'; New = '"name": "bandungbersuara"' },
    @{ Old = '"name": "indonesiadaily"'; New = '"name": "bandungbersuara"' }
)

Write-Log -Message '===== REBRAND BANDUNG BERSUARA DIMULAI ====='
Write-Log -Message "Workspace: $WorkspaceRoot"

if (Test-Path (Join-Path $WorkspaceRoot 'articles.json')) {
    Copy-Item -Path (Join-Path $WorkspaceRoot 'articles.json') -Destination (Join-Path $WorkspaceRoot 'articles.json.bak') -Force
    Copy-Item -Path (Join-Path $WorkspaceRoot 'articles.json') -Destination (Join-Path $WorkspaceRoot "articles.json.bak.$Timestamp") -Force
    Write-Log -Message 'Backup dibuat: articles.json.bak dan backup bertimestamp'
}

# 1) HTML: branding + logo + encoding cleanup
Get-ChildItem -Path $WorkspaceRoot -Recurse -Include *.html -File |
    Where-Object { $_.FullName -notlike '*\node_modules\*' -and $_.FullName -notlike '*.bak*' } |
    ForEach-Object {
        $path = $_.FullName
        $original = Get-Content -Path $path -Raw -Encoding utf8
        $content = Normalize-Text -Text $original

        $content = [regex]::Replace(
            $content,
            '(?is)<a([^>]*class="[^"]*navbar-brand[^"]*"[^>]*)>\s*<img[^>]*src="(?:\.\./)?img/logo\.png"[^>]*>\s*</a>',
            ('<a$1>' + $BrandLogo + '</a>')
        )
        $content = [regex]::Replace(
            $content,
            '(?is)<img[^>]*src="(?:\.\./)?img/logo\.png"[^>]*>',
            ''
        )
        $content = $content.Replace('../img/logo.png', '#')
        $content = $content.Replace('img/logo.png', '#')

        $content = Apply-Replacements -Content $content -Pairs $BrandPairs
        $content = Apply-Replacements -Content $content -Pairs $ColorPairs

        $content = $content.Replace(
            '<span style="font-weight: bold; color: #BE123C; font-size: 24px; letter-spacing: -0.5px;">WARTA<span style="color: #1F5F1F; font-weight: normal; font-size: 18px; margin-left: 2px;">JANTEN</span></span>',
            $BrandLogo
        )
        $content = $content.Replace(
            '<span style="font-weight: bold; color: #065F46; font-size: 24px; letter-spacing: -0.5px;">WARTA<span style="color: #1E3A5F; font-weight: normal; font-size: 18px; margin-left: 2px;">JANTEN</span></span>',
            $BrandLogo
        )
        $content = $content.Replace(
            '<span style="font-weight: 700; color: #BE123C; font-size: 24px; letter-spacing: -0.5px;">Bandung<span style="color: #1F5F1F; font-weight: 400; font-size: 16px; margin-left: 3px;"> Bersuara</span></span>',
            $BrandLogo
        )

        Save-IfChanged -Path $path -Original $original -Updated $content
    }

# 2) CSS: warna global baru
Get-ChildItem -Path $WorkspaceRoot -Recurse -Include *.css -File |
    Where-Object { $_.FullName -notlike '*\node_modules\*' } |
    ForEach-Object {
        $path = $_.FullName
        $original = Get-Content -Path $path -Raw -Encoding utf8
        $content = Apply-Replacements -Content $original -Pairs $ColorPairs
        Save-IfChanged -Path $path -Original $original -Updated $content
    }

# 3) Package metadata
Get-ChildItem -Path $WorkspaceRoot -Recurse -Include package.json,package-lock.json -File |
    Where-Object { $_.FullName -notlike '*\node_modules\*' } |
    ForEach-Object {
        $path = $_.FullName
        $original = Get-Content -Path $path -Raw -Encoding utf8
        $content = Normalize-Text -Text $original
        $content = Apply-Replacements -Content $content -Pairs $PackagePairs
        $content = Apply-Replacements -Content $content -Pairs $BrandPairs
        Save-IfChanged -Path $path -Original $original -Updated $content
    }

# 4) Docs, configs, scripts, templates
Get-ChildItem -Path $WorkspaceRoot -Recurse -Include *.md,*.toml,*.txt,*.ps1,*.json,*.js -File |
    Where-Object {
        $_.FullName -notlike '*\node_modules\*' -and
        $_.FullName -notlike '*.bak*' -and
        $_.FullName -ne $CurrentScript -and
        $_.Name -notin @('package.json', 'package-lock.json', 'articles.json', 'articles_temp.json')
    } |
    ForEach-Object {
        $path = $_.FullName
        $original = Get-Content -Path $path -Raw -Encoding utf8
        $content = Normalize-Text -Text $original
        $content = Apply-Replacements -Content $content -Pairs $BrandPairs
        $content = Apply-Replacements -Content $content -Pairs $ColorPairs
        Save-IfChanged -Path $path -Original $original -Updated $content
    }

# 5) Verification
$verificationFiles = Get-ChildItem -Path $WorkspaceRoot -Recurse -Include *.html,*.css,*.md,*.json,*.toml,*.ps1,*.txt -File |
    Where-Object { $_.FullName -notlike '*\node_modules\*' -and $_.FullName -notlike '*.bak*' }

$legacyPatterns = @('Indonesia Daily', 'indonesiadaily', 'IndonesiaDaily')
$remainingLegacy = foreach ($pattern in $legacyPatterns) {
    $verificationFiles | Select-String -Pattern $pattern -SimpleMatch | ForEach-Object {
        [PSCustomObject]@{
            Pattern = $pattern
            Path = $_.Path
            Line = $_.LineNumber
        }
    }
}

$logoRefs = $verificationFiles | Where-Object { $_.Extension -eq '.html' } | Select-String -Pattern 'logo\.png'
$newColors = @('#BE123C', '#4C0519', '#1F5F1F')
$colorsOk = @{}
foreach ($color in $newColors) {
    $colorsOk[$color] = ($verificationFiles | Select-String -Pattern $color -SimpleMatch | Measure-Object).Count -gt 0
}

Write-Log -Message ''
Write-Log -Message '===== RINGKASAN REBRAND ====='
Write-Log -Message "Main pages diubah : $($Changed.MainPages.Count)"
Write-Log -Message "Article pages diubah: $($Changed.ArticlePages.Count)"
Write-Log -Message "CSS diubah        : $($Changed.CSS.Count)"
Write-Log -Message "Package diubah    : $($Changed.Package.Count)"
Write-Log -Message "Docs/config diubah: $($Changed.Docs.Count)"
Write-Log -Message ''

if (($remainingLegacy | Measure-Object).Count -eq 0) {
    Write-Log -Message 'Tidak ada lagi string Indonesia Daily / indonesiadaily / IndonesiaDaily.'
} else {
    Write-Log -Message "Masih ada $((($remainingLegacy | Measure-Object).Count)) referensi legacy yang perlu dicek." -Type 'WARNING'
}

if (($logoRefs | Measure-Object).Count -eq 0) {
    Write-Log -Message 'Tidak ada lagi referensi logo.png.'
} else {
    Write-Log -Message "Masih ada $((($logoRefs | Measure-Object).Count)) referensi logo.png." -Type 'WARNING'
}

foreach ($color in $newColors) {
    Write-Log -Message "$color terpakai: $($colorsOk[$color])"
}

Write-Log -Message 'Rebrand Bandung Bersuara selesai ✅'

[PSCustomObject]@{
    MainPages = $Changed.MainPages.Count
    ArticlePages = $Changed.ArticlePages.Count
    CSS = $Changed.CSS.Count
    Package = $Changed.Package.Count
    Docs = $Changed.Docs.Count
    LegacyIssues = ($remainingLegacy | Measure-Object).Count
    LogoReferences = ($logoRefs | Measure-Object).Count
    LogFile = $LogFile
} | Format-List
