# Bulk replace package:nexatrace_system/ -> package:trace_odd/ across all Dart files
$ErrorActionPreference = 'Stop'
$root = 'c:\Ecosystem\NexaTrace_System'
$paths = @("$root\lib", "$root\test")
$old = 'package:nexatrace_system/'
$new = 'package:trace_odd/'

$files = Get-ChildItem -Path $paths -Recurse -Include *.dart -File -ErrorAction SilentlyContinue |
    Where-Object { Select-String -Path $_.FullName -Pattern $old -SimpleMatch -Quiet }

$count = 0
foreach ($f in $files) {
    $content = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
    $newContent = $content.Replace($old, $new)
    if ($content -ne $newContent) {
        [System.IO.File]::WriteAllText($f.FullName, $newContent, (New-Object System.Text.UTF8Encoding $false))
        $count++
    }
}
Write-Host "REPLACED_FILES=$count"
