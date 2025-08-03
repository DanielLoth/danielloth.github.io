#requires -Version 7
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$S4 = "    "
$S8 = $S4 + $S4
$CssLines = Get-Content -Path "style.css"

for ($i = 0; $i -lt $CssLines.Length; $i++) {
    $CssLines[$i] = "$($S8)$($CssLines[$i])"
}

$Css = $CssLines -join "`r`n"

$Fragment = "<!-- CSS -->
$($S4)<style>
$($Css)
$($S4)</style>
$($S4)<!-- End CSS -->"

$HtmlFiles = Get-ChildItem -Path $PSScriptRoot -Recurse `
    | Where-Object -FilterScript { $_.Name -like '*.html' } `
    | Where-Object -FilterScript { $_.FullName -notlike "*_layouts*" }

foreach ($HtmlFile in $HtmlFiles) {
    $Html = Get-Content -Path $HtmlFile.FullName -Raw

    if ($Html -match "<!-- CSS -->" -and $Html -match '<!-- END CSS -->') {
        $Pattern = "(<!-- CSS -->)[\s\S]*?(\s*)(<!-- END CSS -->)"
        $Html = $Html -replace $Pattern, $Fragment
        Set-Content -Path $HtmlFile.FullName -Value $Html -NoNewline
    }
    else {
        # throw "Html file $($HtmlFile.FullName) does not have expected CSS marker comments."
    }
}
