#!/usr/bin/env bash
# Linux/macOS counterpart to statusline-command.ps1.
# Requires: jq, and a CJK-capable font (the kaomoji are CJK/Hangul, not emoji).
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Kaomoji for the tool Claude is currently running.
# The PreToolUse hook writes current-tool.txt; PostToolUse and
# PostToolUseFailure delete it. No file means no tool is running.
tool_kaomoji=""
tool_file="$HOME/.claude/current-tool.txt"
if [ -f "$tool_file" ]; then
  declare -A tool_map=(
    [Bash]="(ง'̀-'́)ง cmd"
    [Read]="(｀・ω・´) reading"
    [Edit]="(✿◠‿◠) editing"
    [Write]="(*ﾟДﾟ) writing"
    [Grep]="눈_눈 grep"
    [Glob]="(◕‿◕) globbing"
    [WebFetch]="(づ｡◕‿‿◕｡)づ fetching"
    [WebSearch]="ε=(｡々°) searching web"
    [Agent]="ヽ(°〇°)ﾉ spawning agent"
    [Skill]="(∩｀-´)⊃━☆ casting skill"
    [TaskCreate]="٩(◕‿◕｡)۶ making tasks"
    [TaskUpdate]="(─‿─) updating tasks"
  )
  tool=$(tr -d '\r\n' < "$tool_file")
  if [ -n "$tool" ]; then
    tool_kaomoji="${tool_map[$tool]:-(｡◕‿◕｡) $tool} | "
  fi
fi

# Returns a human-readable countdown string given a Unix epoch reset time.
# $1 = resets_at epoch, $2 = "hm" for Xh Ym format, "dh" for Xd Yh format
format_reset() {
  local secs_remaining=$(( $1 - $(date +%s) ))
  [ "$secs_remaining" -le 0 ] && return
  if [ "$2" = "hm" ]; then
    local h=$(( secs_remaining / 3600 ))
    local m=$(( (secs_remaining % 3600) / 60 ))
    if [ "$h" -ge 1 ]; then echo "${h}h${m}m"; else echo "${m}m"; fi
  else
    local d=$(( secs_remaining / 86400 ))
    local h=$(( (secs_remaining % 86400) / 3600 ))
    if [ "$d" -ge 1 ]; then echo "${d}d${h}h"; else echo "${h}h"; fi
  fi
}

make_bar() {
  local pct=$(printf '%.0f' "$1")
  local filled=$(( pct * 10 / 100 ))
  local empty=$(( 10 - filled ))
  local bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty);  do bar="${bar}░"; done
  echo "[${bar}] ${pct}%"
}

parts="$model"

if [ -n "$five" ]; then
  five_str="5h $(make_bar "$five")"
  [ -n "$five_reset" ] && { r=$(format_reset "$five_reset" "hm"); [ -n "$r" ] && five_str="$five_str resets $r"; }
  parts="$parts | $five_str"
fi
if [ -n "$week" ]; then
  week_str="7d $(make_bar "$week")"
  [ -n "$week_reset" ] && { r=$(format_reset "$week_reset" "dh"); [ -n "$r" ] && week_str="$week_str resets $r"; }
  parts="$parts | $week_str"
fi

echo "${tool_kaomoji}${parts}"
