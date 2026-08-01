$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$input_data = $input | Out-String | ConvertFrom-Json

$toolKaomoji = ""
$toolFile = "$env:USERPROFILE\.claude\current-tool.txt"
if (Test-Path $toolFile) {
    $toolMap = @{
        "Bash"     = "(ง'̀-'́)ง cmd"
        "Read"     = "(｀・ω・´) reading"
        "Edit"     = "(✿◠‿◠) editing"
        "Write"    = "(*ﾟДﾟ) writing"
        "Grep"     = "눈_눈 grep"
        "Glob"     = "(◕‿◕) globbing"
        "WebFetch" = "(づ｡◕‿‿◕｡)づ fetching"
        "WebSearch" = "ε=(｡々°) searching web"
        "Agent"    = "ヽ(°〇°)ﾉ spawning agent"
        "Skill"    = "(∩｀-´)⊃━☆ casting skill"
        "TaskCreate" = "٩(◕‿◕｡)۶ making tasks"
        "TaskUpdate" = "(─‿─) updating tasks"
    }
    $tool = (Get-Content $toolFile -Raw -Encoding UTF8).Trim()
    $k = $toolMap[$tool]
    if (-not $k) { $k = "(｡◕‿◕｡) $tool" }
    $toolKaomoji = "$k | "
}

$model = if ($input_data.model.display_name) { $input_data.model.display_name } else { "Unknown" }
$five = $input_data.rate_limits.five_hour.used_percentage
$five_reset = $input_data.rate_limits.five_hour.resets_at
$week = $input_data.rate_limits.seven_day.used_percentage
$week_reset = $input_data.rate_limits.seven_day.resets_at

function Make-Bar($pct) {
    $p = [int][math]::Round($pct)
    $filled = [int]($p * 10 / 100)
    $empty = 10 - $filled
    $bar = ("#" * $filled) + ("-" * $empty)
    return "[$bar] $p%"
}

function Format-Reset($epoch, $fmt) {
    $now = [int]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
    $secs = $epoch - $now
    if ($secs -le 0) { return $null }
    if ($fmt -eq "hm") {
        $h = [int]($secs / 3600)
        $m = [int](($secs % 3600) / 60)
        if ($h -ge 1) { return "${h}h${m}m" } else { return "${m}m" }
    } else {
        $d = [int]($secs / 86400)
        $h = [int](($secs % 86400) / 3600)
        if ($d -ge 1) { return "${d}d${h}h" } else { return "${h}h" }
    }
}

$parts = $model

if ($null -ne $five) {
    $bar = Make-Bar $five
    $str = "5h $bar"
    if ($five_reset) {
        $r = Format-Reset $five_reset "hm"
        if ($r) { $str = "$str resets $r" }
    }
    $parts = "$parts | $str"
}

if ($null -ne $week) {
    $bar = Make-Bar $week
    $str = "7d $bar"
    if ($week_reset) {
        $r = Format-Reset $week_reset "dh"
        if ($r) { $str = "$str resets $r" }
    }
    $parts = "$parts | $str"
}

Write-Output "$toolKaomoji$parts"
