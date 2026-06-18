#!/usr/bin/env bash
# Statusline for Claude Code.
# Palette: "classic" | "minimal" | "nord"
PALETTE="${CLAUDE_STATUSLINE_PALETTE:-atom}"

input=$(cat)

cwd=$(jq -r '.cwd // "."' <<<"$input")
model=$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")
ctx=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
fivehr=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
fivehr_reset=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
wk=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
wk_reset=$(jq -r '.rate_limits.seven_day.resets_at // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")

# trim trailing parenthetical from model name, e.g. "Opus 4.7 (1M context)" -> "Opus 4.7"
model=$(printf '%s' "$model" | sed -E 's/ *\([^)]*\) *$//')

effort=$(jq -r '.effortLevel // empty' ~/.claude/settings.json 2>/dev/null)

# raw_mode=""
# if [ -n "$transcript" ] && [ -f "$transcript" ]; then
#   raw_mode=$(grep '"type":"permission-mode"' "$transcript" 2>/dev/null \
#     | tail -1 | jq -r '.permissionMode // empty' 2>/dev/null)
# fi
# if [ -z "$raw_mode" ]; then
#   raw_mode=$(jq -r '.permissions.defaultMode // "default"' \
#     ~/.claude/settings.json 2>/dev/null)
# fi

# ---------- palette ----------
reset=$'\033[0m'
bold=$'\033[1m'
dim=$'\033[2m'

sep_glyph=' · '

case "$PALETTE" in
  minimal)
    # single blue accent, everything else grayscale; red only when critical
    label=$'\033[38;5;244m'
    sep_col=$'\033[38;5;240m'
    model_col=$'\033[1;38;5;252m'
    branch_col=$'\033[38;5;110m'
    dirty_col=$'\033[38;5;209m'
    low_col=$'\033[38;5;252m'
    mid_col=$'\033[38;5;252m'
    high_col=$'\033[38;5;203m'
    bar_empty_col=$'\033[38;5;238m'
    mode_plan=$'\033[1;38;5;232;48;5;110m'
    mode_edit=$'\033[1;38;5;232;48;5;180m'
    mode_yolo=$'\033[1;38;5;232;48;5;203m'
    mode_auto=$'\033[1;38;5;232;48;5;139m'
    mode_def=$'\033[1;38;5;232;48;5;108m'
    ;;
  atom)
    # Atom One Dark: blue #61afef, green #98c379, red #e06c75, yellow #e5c07b, purple #c678dd
    # Overriding warnings with a classic-style vivid red so "limit reached" really pops.
    label=$'\033[38;5;244m'
    sep_col=$'\033[38;5;239m'
    model_col=$'\033[1;38;5;75m'    # one-dark blue
    branch_col=$'\033[38;5;114m'    # one-dark green
    dirty_col=$'\033[1;38;5;196m'   # vivid red
    low_col=$'\033[38;5;114m'
    mid_col=$'\033[1;38;5;220m'     # clear gold yellow (> 20%)
    high_col=$'\033[1;38;5;196m'    # vivid red (> 70%)
    bar_empty_col=$'\033[38;5;237m'
    mode_plan=$'\033[1;38;5;232;48;5;75m'
    mode_edit=$'\033[1;38;5;232;48;5;220m'
    mode_yolo=$'\033[1;97;48;5;196m' # bright white on vivid red
    mode_auto=$'\033[1;38;5;232;48;5;176m'
    mode_def=$'\033[1;38;5;232;48;5;114m'
    ;;
  nord)
    # Nord: frost teal/blue, aurora muted pink/yellow
    label=$'\033[38;5;243m'
    sep_col=$'\033[38;5;239m'
    model_col=$'\033[1;38;5;152m'
    branch_col=$'\033[38;5;180m'
    dirty_col=$'\033[38;5;174m'
    low_col=$'\033[38;5;108m'
    mid_col=$'\033[38;5;179m'
    high_col=$'\033[38;5;174m'
    bar_empty_col=$'\033[38;5;237m'
    mode_plan=$'\033[1;38;5;232;48;5;109m'
    mode_edit=$'\033[1;38;5;232;48;5;179m'
    mode_yolo=$'\033[1;38;5;232;48;5;174m'
    mode_auto=$'\033[1;38;5;232;48;5;139m'
    mode_def=$'\033[1;38;5;232;48;5;108m'
    ;;
  tokyonight)
    # Tokyo Night: #7aa2f7 blue, #bb9af7 purple, #9ece6a green, #f7768e red, #e0af68 amber
    label=$'\033[38;5;243m'
    sep_col=$'\033[38;5;238m'
    model_col=$'\033[1;38;5;111m'
    branch_col=$'\033[38;5;141m'
    dirty_col=$'\033[38;5;210m'
    low_col=$'\033[38;5;150m'
    mid_col=$'\033[38;5;179m'
    high_col=$'\033[38;5;210m'
    bar_empty_col=$'\033[38;5;236m'
    mode_plan=$'\033[1;38;5;232;48;5;111m'
    mode_edit=$'\033[1;38;5;232;48;5;179m'
    mode_yolo=$'\033[1;38;5;232;48;5;210m'
    mode_auto=$'\033[1;38;5;232;48;5;141m'
    mode_def=$'\033[1;38;5;232;48;5;150m'
    ;;
  vscode)
    # VSCode Dark+: #569cd6 blue, #4ec9b0 teal, #ce9178 orange, #dcdcaa yellow, #c586c0 purple
    label=$'\033[38;5;245m'
    sep_col=$'\033[38;5;240m'
    model_col=$'\033[1;38;5;74m'   # vscode blue
    branch_col=$'\033[38;5;180m'   # tan
    dirty_col=$'\033[38;5;203m'
    low_col=$'\033[38;5;72m'       # teal
    mid_col=$'\033[38;5;222m'      # vscode yellow
    high_col=$'\033[38;5;203m'
    bar_empty_col=$'\033[38;5;238m'
    mode_plan=$'\033[1;38;5;232;48;5;74m'
    mode_edit=$'\033[1;38;5;232;48;5;222m'
    mode_yolo=$'\033[1;38;5;232;48;5;203m'
    mode_auto=$'\033[1;38;5;232;48;5;176m'
    mode_def=$'\033[1;38;5;232;48;5;72m'
    ;;
  tmux)
    # Tmux default green/black with yellow branch
    label=$'\033[38;5;250m'
    sep_col=$'\033[38;5;244m'
    model_col=$'\033[1;38;5;231m'
    branch_col=$'\033[1;38;5;226m'
    dirty_col=$'\033[38;5;196m'
    low_col=$'\033[38;5;148m'
    mid_col=$'\033[38;5;214m'
    high_col=$'\033[38;5;196m'
    bar_empty_col=$'\033[38;5;238m'
    mode_plan=$'\033[1;38;5;16;48;5;148m'
    mode_edit=$'\033[1;38;5;16;48;5;214m'
    mode_yolo=$'\033[1;38;5;16;48;5;196m'
    mode_auto=$'\033[1;38;5;16;48;5;141m'
    mode_def=$'\033[1;38;5;16;48;5;148m'
    ;;
  powerline)
    # Powerline: arrow separators, bolder bg chips. Requires a Nerd/Powerline font.
    sep_glyph=$'  '   # thin powerline separator U+E0B1
    label=$'\033[38;5;250m'
    sep_col=$'\033[38;5;240m'
    model_col=$'\033[1;38;5;117m'
    branch_col=$'\033[1;38;5;220m'
    dirty_col=$'\033[38;5;203m'
    low_col=$'\033[38;5;120m'
    mid_col=$'\033[38;5;222m'
    high_col=$'\033[38;5;203m'
    bar_empty_col=$'\033[38;5;238m'
    mode_plan=$'\033[1;38;5;232;48;5;117m'
    mode_edit=$'\033[1;38;5;232;48;5;222m'
    mode_yolo=$'\033[1;38;5;232;48;5;203m'
    mode_auto=$'\033[1;38;5;232;48;5;183m'
    mode_def=$'\033[1;38;5;232;48;5;120m'
    ;;
  classic|*)
    label=$'\033[2m'
    sep_col=$'\033[90m'
    model_col=$'\033[1;36m'
    branch_col=$'\033[33m'
    dirty_col=$'\033[31m'
    low_col=$'\033[32m'
    mid_col=$'\033[33m'
    high_col=$'\033[31m'
    bar_empty_col=$'\033[2m'
    mode_plan=$'\033[1;97;44m'
    mode_edit=$'\033[1;30;43m'
    mode_yolo=$'\033[1;97;41m'
    mode_auto=$'\033[1;97;45m'
    mode_def=$'\033[1;97;42m'
    ;;
esac

# case "$raw_mode" in
#   plan)              mode_label="PLAN"; chip=$mode_plan ;;
#   acceptEdits)       mode_label="EDIT"; chip=$mode_edit ;;
#   bypassPermissions) mode_label="YOLO"; chip=$mode_yolo ;;
#   auto)              mode_label="AUTO"; chip=$mode_auto ;;
#   default|"")        mode_label="DFLT"; chip=$mode_def  ;;
#   *)                 mode_label=$(printf '%s' "$raw_mode" | tr '[:lower:]' '[:upper:]' | cut -c1-4); chip=$mode_def ;;
# esac

# color by threshold
level_color() {
  local p=${1%.*}; p=${p:-0}
  if   (( p > 70 )); then printf '%s' "$high_col"
  elif (( p > 20 )); then printf '%s' "$mid_col"
  else                    printf '%s' "$low_col"; fi
}

bar() {
  local pct=${1%.*}; pct=${pct:-0}
  (( pct < 0 )) && pct=0
  (( pct > 100 )) && pct=100
  local width=10
  local filled=$(( (pct * width + 50) / 100 ))
  local empty=$(( width - filled ))
  local filled_str="" empty_str=""
  (( filled > 0 )) && printf -v filled_str '▰%.0s' $(seq 1 "$filled")
  (( empty  > 0 )) && printf -v empty_str  '▱%.0s' $(seq 1 "$empty")
  local c; c=$(level_color "$pct")
  printf '%s%s%s%s%s' "$c" "$filled_str" "$bar_empty_col" "$empty_str" "$reset"
}

fmt_bar_pct() {
  local name=$1 pct=$2
  if [ -z "$pct" ]; then
    printf '%s%s%s %s---%s' "$label" "$name" "$reset" "$dim" "$reset"
    return
  fi
  local c; c=$(level_color "$pct")
  printf '%s%s%s %s %s%.0f%%%s' \
    "$label" "$name" "$reset" "$(bar "$pct")" "$c" "$pct" "$reset"
}

fmt_pct_only() {
  local name=$1 pct=$2
  if [ -z "$pct" ]; then
    printf '%s%s ---%s' "$label" "$name" "$reset"
    return
  fi
  local c; c=$(level_color "$pct")
  printf '%s%s%s %s%.0f%%%s' "$label" "$name" "$reset" "$c" "$pct" "$reset"
}

# reset-countdown helper: takes a unix epoch, returns "reset 1h 23m" or ""
fmt_reset() {
  local epoch=${1%.*}
  [ -z "$epoch" ] && return
  local now; now=$(date +%s)
  local delta=$(( epoch - now ))
  (( delta < 0 )) && return
  local h=$(( delta / 3600 ))
  local m=$(( (delta % 3600) / 60 ))
  if (( h > 0 )); then
    printf 'reset %dh %dm' "$h" "$m"
  else
    printf 'reset %dm' "$m"
  fi
}

# p10k-style git status segment: ⎇ branch ↑N ↓N *N +N !N ?N ~N
# Zero-count indicators are omitted. Branch color reflects overall state:
#   green=clean, yellow=dirty, red=conflict.
git_status_segment() {
  local dir=$1
  git --no-optional-locks -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local br detached=0
  br=$(git --no-optional-locks -C "$dir" symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$br" ]; then
    br=$(git --no-optional-locks -C "$dir" rev-parse --short HEAD 2>/dev/null)
    detached=1
  fi
  [ -z "$br" ] && return

  local raw ahead=0 behind=0 stash=0
  local staged=0 modified=0 untracked=0 conflicts=0
  raw=$(git --no-optional-locks -C "$dir" status --porcelain=v2 --branch --show-stash 2>/dev/null)
  while IFS= read -r line; do
    case "$line" in
      '# branch.ab '*)
        ab=${line#'# branch.ab '}
        ahead=${ab%% *};  ahead=${ahead#+}
        behind=${ab##* }; behind=${behind#-}
        ;;
      '# stash '*)
        stash=${line#'# stash '}
        ;;
      '1 '*|'2 '*)
        xy=${line#* }; xy=${xy%% *}
        [ "${xy:0:1}" != '.' ] && staged=$((staged+1))
        [ "${xy:1:1}" != '.' ] && modified=$((modified+1))
        ;;
      'u '*) conflicts=$((conflicts+1)) ;;
      '? '*) untracked=$((untracked+1)) ;;
    esac
  done <<< "$raw"

  # branch color by overall state (uses palette's low/mid/high)
  local branch_color=$low_col
  if (( conflicts > 0 )); then
    branch_color=$high_col
  elif (( staged + modified + untracked > 0 )); then
    branch_color=$mid_col
  fi
  (( detached )) && branch_color=$label

  local glyph='⎇'
  (( detached )) && glyph='➦'

  printf '%s%s %s%s' "$branch_color" "$glyph" "$br" "$reset"
  (( ahead    > 0 )) && printf ' %s↑%d%s' "$model_col"  "$ahead"    "$reset"
  (( behind   > 0 )) && printf ' %s↓%d%s' "$high_col"   "$behind"   "$reset"
  (( stash    > 0 )) && printf ' %s*%d%s' "$label"      "$stash"    "$reset"
  (( staged   > 0 )) && printf ' %s+%d%s' "$low_col"    "$staged"   "$reset"
  (( modified > 0 )) && printf ' %s!%d%s' "$mid_col"    "$modified" "$reset"
  (( untracked> 0 )) && printf ' %s?%d%s' "$branch_col" "$untracked" "$reset"
  (( conflicts> 0 )) && printf ' %s~%d%s' "$high_col"   "$conflicts" "$reset"
}
branch_seg=$(git_status_segment "$cwd")

# mode_chip=$(printf '%s %s %s' "$chip" "$mode_label" "$reset")
model_seg=$(printf '%s%s%s' "$model_col" "$model" "$reset")
if [ -n "$effort" ]; then
  model_seg=$(printf '%s %s%s%s' "$model_seg" "$dim" "$effort" "$reset")
fi
ctx_seg=$(fmt_bar_pct "ctx" "$ctx")
fivehr_seg=$(fmt_bar_pct "5h" "$fivehr")
wk_seg=$(fmt_pct_only "wk" "$wk")

# append reset-countdown only when a limit hit 100%
fivehr_int=${fivehr%.*}; fivehr_int=${fivehr_int:-0}
wk_int=${wk%.*}; wk_int=${wk_int:-0}
if (( fivehr_int >= 100 )); then
  r=$(fmt_reset "$fivehr_reset")
  [ -n "$r" ] && fivehr_seg=$(printf '%s %s(%s)%s' "$fivehr_seg" "$high_col" "$r" "$reset")
fi
if (( wk_int >= 100 )); then
  r=$(fmt_reset "$wk_reset")
  [ -n "$r" ] && wk_seg=$(printf '%s %s(%s)%s' "$wk_seg" "$high_col" "$r" "$reset")
fi

sep=$(printf '%s%s%s' "$sep_col" "$sep_glyph" "$reset")

printf '%s%s%s%s%s%s%s' \
  "$model_seg" "$sep" \
  "$ctx_seg" "$sep" "$fivehr_seg" "$sep" "$wk_seg"
[ -n "$branch_seg" ] && printf '%s%s' "$sep" "$branch_seg"
exit 0
