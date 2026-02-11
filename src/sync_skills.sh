#!/bin/bash
# sync_skills.sh - Universal OpenClaw Skill Sync
# Parses CLAWHUB_SKILLS.md to download and organize skills
# Output style matches install_clawfather.sh (theme, │ wall, [ OK ], ◆/◇ headers)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
# Allow caller to set skills target (e.g. OPENCLAW_CONFIG_DIR/skills when OpenClaw dir is custom)
SKILLS_ROOT="${SKILLS_ROOT:-$PROJECT_ROOT/skills}"
# Default source of truth is the curated list in skills/
# (root-level CLAWHUB_SKILLS.md was a legacy duplicate)
README_FILE="${README_FILE:-$PROJECT_ROOT/skills/CLAWHUB_SKILLS.md}"
# CRITICAL: Keep all changes local to project directory
TEMP_DIR="$SCRIPT_DIR/.tmp_sync"
MAX_ATTEMPTS=3

# Slugs removed from CLAWHUB_SKILLS.md (Banned skills) — never install
BANNED_SKILLS="youtube-data youtube-search perplexity reddit-readonly gitlab-manager openclaw-backup-optimized openclaw-nextcloud skillzmarket task-monitor trigger-chain-analysis trigger-obfuscation"

if [ ! -f "$README_FILE" ]; then
    # Backward-compat: older checkouts may still have the file at repo root.
    _legacy_readme="$PROJECT_ROOT/CLAWHUB_SKILLS.md"
    if [ -f "$_legacy_readme" ]; then
        README_FILE="$_legacy_readme"
    else
        echo "Error: CLAWHUB_SKILLS.md not found at $README_FILE"
        exit 1
    fi
fi

# Source install_clawfather.sh theme (same palette)
LIB_DIR="$SCRIPT_DIR/lib"
[ -f "$LIB_DIR/ywizz/theme.sh" ] && source "$LIB_DIR/ywizz/theme.sh"
[ -f "$LIB_DIR/ywizz/core.sh" ] && source "$LIB_DIR/ywizz/core.sh"
[ -f "$LIB_DIR/ywizz/progress_bar.sh" ] && source "$LIB_DIR/ywizz/progress_bar.sh"
accent_color="${accent_color:-$C7}"
dim_color="${C7}${DIM}"
DARK_PINK=$'\033[38;5;163m'   # Dark pink for skill descriptions
TUI_PREFIX="$(printf "%b" "${accent_color}${TREE_MID}${RESET}")"

# Extract a zip file WITHOUT creating symlinks.
# Rationale: upstream skill zips may contain symlinks; extracting them would place symlinks into this repo.
extract_zip_no_symlinks() {
    local zip_file="$1"
    local dest_dir="$2"
    local py=""
    if command -v python3 >/dev/null 2>&1; then
        py="python3"
    elif command -v python >/dev/null 2>&1; then
        py="python"
    else
        echo "Error: python3/python is required to extract skills safely (no symlinks)." >&2
        return 2
    fi

    # NOTE: We intentionally do not use `unzip` because it can materialize symlink entries.
    "$py" - "$zip_file" "$dest_dir" <<'PY'
import os
import stat
import sys
import zipfile
from pathlib import Path, PurePosixPath

zip_path = sys.argv[1]
dest = Path(sys.argv[2])
dest.mkdir(parents=True, exist_ok=True)
dest_resolved = dest.resolve()

def safe_join(base: Path, rel_posix: PurePosixPath) -> Path:
    # Prevent absolute paths and path traversal.
    if rel_posix.is_absolute():
        raise ValueError("absolute path in zip")
    if any(part in ("..", "") for part in rel_posix.parts):
        raise ValueError("path traversal in zip")
    out = (base / Path(*rel_posix.parts)).resolve()
    if out != base and base not in out.parents:
        raise ValueError("path escapes destination")
    return out

with zipfile.ZipFile(zip_path) as zf:
    for info in zf.infolist():
        name = info.filename.replace("\\", "/")
        if not name or name == "/":
            continue

        p = PurePosixPath(name)
        # Skip any suspicious entries.
        try:
            out_path = safe_join(dest_resolved, p)
        except Exception:
            continue

        # Determine file type from unix mode bits, if present.
        mode = (info.external_attr >> 16) & 0xFFFF
        is_dir = name.endswith("/")
        is_symlink = stat.S_ISLNK(mode)

        if is_symlink:
            # Never create symlinks during install/sync.
            continue

        if is_dir:
            out_path.mkdir(parents=True, exist_ok=True)
            continue

        out_path.parent.mkdir(parents=True, exist_ok=True)
        with zf.open(info, "r") as src, open(out_path, "wb") as dst:
            dst.write(src.read())

        # Apply permissions when available; keep it conservative.
        perm = mode & 0o777
        if perm:
            try:
                os.chmod(out_path, perm)
            except Exception:
                pass
PY
}

# Helpers
trim() {
    echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

normalize_folder_path() {
    # Normalize a "folder:" path from CLAWHUB_SKILLS.md.
    # Example: "Crawlers / Searchers" -> "Crawlers"
    # This prevents creating dirs like "Crawlers " and " Searchers", while keeping
    # the on-disk layout consistent with existing category roots.
    local raw
    raw="$(trim "$1")"

    local IFS='/'
    local -a parts out_parts
    read -ra parts <<< "$raw"

    local p
    for p in "${parts[@]}"; do
        p="$(trim "$p")"
        [ -z "$p" ] && continue
        out_parts+=("$p")
    done

    # If a header uses "A / B", treat "A" as the real folder name.
    echo "${out_parts[0]}"
}

# Regex patterns
# Header: ## Name <!-- folder: Folder -->
header_re='^## ([^<(]*)<!-- folder: (.*) -->'
# Table Row: | **Name** ... | Description | ...slug=...
skill_re='^\| \*\*([^*]*)\*\*.*\| (.*) \|.*slug=([^&)]*)'

# Stats
total_count=0
downloaded_count=0
skipped_count=0
failed_count=0

# Pre-count total skills for progress bar
total_skills=$(grep -cE '\| \*\*[^*]*\*\*.*\| .* \|.*slug=' "$README_FILE" 2>/dev/null || echo 0)
[ "$total_skills" -eq 0 ] && total_skills=1

# Knight Rider progress bar width (same as progress_bar.sh default)
KR_WIDTH="${PROGRESS_BAR_WIDTH_DEFAULT:-21}"

# Progress state file for background animation (delim: \x1f)
PROGRESS_FILE="$TEMP_DIR/progress.$$"

mkdir -p "$TEMP_DIR"

# Format speed for display (bytes, seconds) -> "128 KB/s" or "1.2 MB/s"
format_speed() {
    local bytes="$1" sec="$2"
    [ -z "$sec" ] || [ "$sec" -lt 1 ] && sec=1
    local kbs=$(( bytes / 1024 / sec ))
    if [ "$kbs" -ge 1024 ]; then
        local mbs=$(( kbs * 10 / 1024 ))
        printf "%s.%s MB/s" "$(( mbs / 10 ))" "$(( mbs % 10 ))"
    else
        printf "%s KB/s" "$kbs"
    fi
}

# Background: animate Knight Rider bar endlessly (reads progress state from file)
run_progress_anim() {
    local kr_pos=0 kr_dir=1 kr_frame=0
    local _tc=0 _ts=1 _folder="" _skill="" _speed=""
    while [ -f "$PROGRESS_FILE" ]; do
        if [ -r "$PROGRESS_FILE" ]; then
            IFS=$'\x1f' read -r _tc _ts _folder _skill _speed < "$PROGRESS_FILE" 2>/dev/null
            [ -z "$_ts" ] && _ts=1
        fi
        printf "\r\033[K%b %b[" "$TUI_PREFIX" "$RESET"
        print_progress_bar_tui "$KR_WIDTH" "$kr_pos" "$kr_frame" "$kr_dir"
        printf "%b] %s/%s " "$RESET" "$_tc" "$_ts"
        printf "%b%s%b / %b%s%b" "$accent_color" "$_folder" "$RESET" "$CYAN" "$_skill" "$RESET"
        [ -n "$_speed" ] && printf " %b(%s)%b" "$RESET" "$_speed" "$RESET" || true
        progress_bar_bounce "$kr_pos" "$kr_dir" "$KR_WIDTH"
        kr_pos=$progress_bar_next_pos
        kr_dir=$progress_bar_next_dir
        kr_frame=$(( (kr_frame + 1) % SPINNER_COUNT ))
        sleep 0.06
    done
}

# Header: ◆ Syncing skills (active section = full diamond; no blank line before, matches install tree)
printf "%b%s%b%b%b\n" "$accent_color" "$DIAMOND_FILLED" "$accent_color" "Syncing skills" "$RESET"
printf "%b %b %s\n" "$TUI_PREFIX" "${GREEN}[ OK ]${RESET}" "Reading $(basename "$README_FILE")"

# Start background Knight Rider animation (writes progress state to file)
printf "0\x1f%s\x1f\x1fReading..." "$total_skills" > "$PROGRESS_FILE"
run_progress_anim &
PROGRESS_PID=$!
trap "kill $PROGRESS_PID 2>/dev/null; rm -f '$PROGRESS_FILE'; exit" EXIT INT TERM

# Inventory: array of "folder|status|name|desc" for final report
declare -a INV_FOLDER INV_STATUS INV_NAME INV_DESC
inv_idx=0

current_folder=""
current_folder_raw=""
while IFS= read -r line || [ -n "$line" ]; do
    # Remove carriage returns (Windows compat)
    line=$(echo "$line" | tr -d '\r')

    # Category Headers
    if [[ $line =~ $header_re ]]; then
        h_name=$(trim "${BASH_REMATCH[1]}")
        h_folder=$(trim "${BASH_REMATCH[2]}")
        current_folder_raw="$h_folder"
        current_folder="$(normalize_folder_path "$h_folder")"
        mkdir -p "$SKILLS_ROOT/$current_folder"
        continue
    fi

    # Skill Rows
    if [[ -n "$current_folder" ]] && [[ $line =~ $skill_re ]]; then
        skill_name=$(trim "${BASH_REMATCH[1]}")
        skill_desc=$(trim "${BASH_REMATCH[2]}")
        slug=$(trim "${BASH_REMATCH[3]}")

        if [[ " $BANNED_SKILLS " == *" $slug "* ]]; then
            continue
        fi

        ((total_count++))
        # Truncate description for display
        display_desc="$skill_desc"
        max_desc=70
        [ ${#display_desc} -gt $max_desc ] && display_desc="${display_desc:0:$max_desc}..."

        target_dir="$SKILLS_ROOT/$current_folder/$slug"
        legacy_target_dir=""
        if [ -n "${current_folder_raw:-}" ] && [ "$current_folder_raw" != "$current_folder" ]; then
            legacy_target_dir="$SKILLS_ROOT/$current_folder_raw/$slug"
        fi

        if [ -d "$target_dir" ]; then
            # Update progress: skipped (cached)
            printf "%s\x1f%s\x1f%s\x1f%s\x1fcached" "$total_count" "$total_skills" "$current_folder" "$skill_name" > "$PROGRESS_FILE"
            ((skipped_count++))
            INV_FOLDER[$inv_idx]="$current_folder"
            INV_STATUS[$inv_idx]="ok"
            INV_NAME[$inv_idx]="$skill_name"
            INV_DESC[$inv_idx]="$display_desc"
            ((inv_idx++))
        elif [ -n "$legacy_target_dir" ] && [ -d "$legacy_target_dir" ]; then
            # Legacy folder path exists (e.g. "Crawlers / Searchers" produced "Crawlers " + " Searchers").
            # Migrate to normalized folder path so we don't re-download.
            if mv "$legacy_target_dir" "$target_dir" 2>/dev/null; then
                # Best-effort cleanup of now-empty legacy parent dirs
                _p="$(dirname "$legacy_target_dir")"
                while [ "$_p" != "$SKILLS_ROOT" ] && [ "$_p" != "/" ]; do
                    rmdir "$_p" 2>/dev/null || break
                    _p="$(dirname "$_p")"
                done
                printf "%s\x1f%s\x1f%s\x1f%s\x1fmigrated" "$total_count" "$total_skills" "$current_folder" "$skill_name" > "$PROGRESS_FILE"
                ((skipped_count++))
                INV_FOLDER[$inv_idx]="$current_folder"
                INV_STATUS[$inv_idx]="ok"
                INV_NAME[$inv_idx]="$skill_name"
                INV_DESC[$inv_idx]="$display_desc"
                ((inv_idx++))
            fi
        else
            # Update progress: downloading (5th field empty until curl completes; speed written after)
            printf "%s\x1f%s\x1f%s\x1f%s\x1f" "$total_count" "$total_skills" "$current_folder" "$skill_name" > "$PROGRESS_FILE"
            success_dl=false
            for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
                zip_file="$TEMP_DIR/$slug.zip"
                rm -f "$zip_file"
                _t0=$(date +%s)
                if curl -sL -o "$zip_file" "https://auth.clawdhub.com/api/v1/download?slug=$slug"; then
                    if [ -f "$zip_file" ] && [ -s "$zip_file" ]; then
                        _t1=$(date +%s)
                        _sz=$(wc -c < "$zip_file" 2>/dev/null || echo 0)
                        _elapsed=$(( _t1 - _t0 ))
                        [ "$_elapsed" -lt 1 ] && _elapsed=1
                        _speed_str=$(format_speed "$_sz" "$_elapsed")
                        printf "%s\x1f%s\x1f%s\x1f%s\x1f%s" "$total_count" "$total_skills" "$current_folder" "$skill_name" "$_speed_str" > "$PROGRESS_FILE"
                        sleep 0.25
                        mkdir -p "$target_dir"
                        if extract_zip_no_symlinks "$zip_file" "$target_dir" 2>/dev/null; then
                            first_item=$(ls -1 "$target_dir" 2>/dev/null | head -n 1)
                            [ -n "$first_item" ] && [ -d "$target_dir/$first_item" ] && [ $(ls -1 "$target_dir" 2>/dev/null | wc -l) -eq 1 ] && (mv "$target_dir/$first_item"/* "$target_dir/" 2>/dev/null; mv "$target_dir/$first_item"/.* "$target_dir/" 2>/dev/null; rmdir "$target_dir/$first_item" 2>/dev/null)
                            ((downloaded_count++))
                            success_dl=true
                            INV_FOLDER[$inv_idx]="$current_folder"
                            INV_STATUS[$inv_idx]="ok"
                            INV_NAME[$inv_idx]="$skill_name"
                            INV_DESC[$inv_idx]="$display_desc"
                            ((inv_idx++))
                            rm -f "$zip_file"
                            break
                        fi
                    fi
                fi
                rm -f "$zip_file"
                [ $attempt -lt $MAX_ATTEMPTS ] && sleep 0.2
            done

            if [ "$success_dl" = false ]; then
                ((failed_count++))
                printf "%s\x1f%s\x1f%s\x1f%s\x1ffailed" "$total_count" "$total_skills" "$current_folder" "$skill_name" > "$PROGRESS_FILE"
                INV_FOLDER[$inv_idx]="$current_folder"
                INV_STATUS[$inv_idx]="fail"
                INV_NAME[$inv_idx]="$skill_name"
                INV_DESC[$inv_idx]="$display_desc"
                ((inv_idx++))
            fi
        fi
    fi
done < "$README_FILE"

# Stop background animation (wait must not leak background job exit code)
rm -f "$PROGRESS_FILE"
wait $PROGRESS_PID 2>/dev/null || true
trap - EXIT INT TERM
printf "\r\033[K"

# Final Inventory by category (install_clawfather.sh style)
prev_folder=""
for ((i=0; i<inv_idx; i++)); do
    f="${INV_FOLDER[$i]}"
    s="${INV_STATUS[$i]}"
    n="${INV_NAME[$i]}"
    d="${INV_DESC[$i]}"

    # Category header when folder changes (accent color for category name)
    if [ "$f" != "$prev_folder" ]; then
        printf "%b %b%b%s%b\n" "$TUI_PREFIX" "$BOLD" "$accent_color" "📂 $f" "$RESET"
        prev_folder="$f"
    fi

    if [ "$s" = "ok" ]; then
        printf "%b %b %b%s%b: %b%s%b\n" "$TUI_PREFIX" "${CYAN}[INFO]${RESET}" "$RESET" "$n" "$RESET" "$dim_color" "$d" "$RESET"
    else
        printf "%b %b %b%s%b: %b%s%b\n" "$TUI_PREFIX" "${RED}[FAIL]${RESET}" "$CYAN" "$n" "$RESET" "$dim_color" "$d" "$RESET"
    fi
done

# Summary (single line, usual colors: DIM labels)
_summary_line=""
_summary_line+="${GREEN}[ OK ]${RESET} Skills sync complete! "
_summary_line+="${DIM}Total:${RESET} $total_count  "
_summary_line+="${DIM}Downloaded:${RESET} $downloaded_count  "
[ $skipped_count -gt 0 ] && _summary_line+="${DIM}Skipped:${RESET} $skipped_count  "
[ $failed_count -gt 0 ] && _summary_line+="${DIM}Failed:${RESET} $failed_count  "
printf "%b %b\n" "$TUI_PREFIX" "$_summary_line"

rm -rf "$TEMP_DIR" 2>/dev/null
exit 0
