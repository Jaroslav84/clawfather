#!/bin/bash
# sync_skills.sh - Universal OpenClaw Skill Sync
# Parses CLAWHUB_SKILLS.md to download and organize skills with a fancy UI and retry logic

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="$SCRIPT_DIR"
README_FILE="$SCRIPT_DIR/../CLAWHUB_SKILLS.md"
TEMP_DIR="/tmp/openclaw_sync"
MAX_ATTEMPTS=3

# Colors
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Regex patterns
header_re='^## ([^<(]*)<!-- folder: (.*) -->'
slug_re='slug=([^&)]*)'

# Stats
total_count=0
downloaded_count=0
skipped_count=0
failed_count=0

mkdir -p "$TEMP_DIR"

echo -e "${BOLD}${MAGENTA}🦞 OpenClaw Skill Sync${NC}"
echo -e "${CYAN}Reading skills from ${BOLD}$(basename "$README_FILE")${NC}\n"

current_folder=""
current_section_name=""

while IFS= read -r line; do
    # Check for category header with folder mapping
    if [[ $line =~ $header_re ]]; then
        current_section_name=$(echo "${BASH_REMATCH[1]}" | xargs)
        current_folder="${BASH_REMATCH[2]}"
        echo -e "\n${BOLD}${BLUE}📂 $current_section_name${NC} ${CYAN}($current_folder)${NC}"
        mkdir -p "$SKILLS_ROOT/$current_folder"
    fi

    # Check for download slug in table rows
    if [[ -n "$current_folder" ]] && [[ $line =~ $slug_re ]]; then
        ((total_count++))
        slug="${BASH_REMATCH[1]}"
        target_dir="$SKILLS_ROOT/$current_folder/$slug"

        if [ -d "$target_dir" ]; then
            ((skipped_count++))
            # One-liner progress for skipped skills
            printf "\r${YELLOW}  ⏭️  Skipping existing: ${NC}%-40s" "$slug"
        else
            # Clear the progress line before showing download
            printf "\r\033[K"
            
            success=false
            for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
                if [ $attempt -gt 1 ]; then
                    echo -e "  ${YELLOW}  🔄 Retry $attempt/$MAX_ATTEMPTS for ${BOLD}$slug${NC}..."
                else
                    echo -e "  ${BOLD}${GREEN}📦 Downloading ${NC}${BOLD}$slug${NC}..."
                fi
                
                zip_file="$TEMP_DIR/$slug.zip"
                rm -f "$zip_file" # Clean up before download
                
                # Download
                curl -sL -o "$zip_file" "https://auth.clawdhub.com/api/v1/download?slug=$slug"
                
                if [ -f "$zip_file" ] && [ -s "$zip_file" ]; then
                    # Extract
                    mkdir -p "$target_dir"
                    if unzip -qo "$zip_file" -d "$target_dir" 2>/dev/null; then
                        # Check for nested directory
                        first_item=$(ls -1 "$target_dir" | head -n 1)
                        item_count=$(ls -1 "$target_dir" | wc -l)
                        
                        if [ "$item_count" -eq 1 ] && [ -d "$target_dir/$first_item" ]; then
                            inner_dir="$target_dir/$first_item"
                            mv "$inner_dir"/* "$target_dir/" 2>/dev/null
                            mv "$inner_dir"/.* "$target_dir/" 2>/dev/null
                            rmdir "$inner_dir"
                        fi
                        
                        echo -e "      ${CYAN}✅ Extracted to ${BOLD}$current_folder/$slug${NC}"
                        ((downloaded_count++))
                        success=true
                        rm "$zip_file"
                        break
                    else
                        echo -e "      ${RED}⚠️ Extraction failed for $slug (invalid ZIP)${NC}"
                        rm -rf "$target_dir" # Clean up failed extraction
                    fi
                else
                    echo -e "      ${RED}⚠️ Download failed for $slug${NC}"
                fi
                rm -f "$zip_file"
                sleep 1 # Brief pause before retry
            done

            if [ "$success" = false ]; then
                echo -e "  ${BOLD}${RED}❌ Failed after $MAX_ATTEMPTS attempts: ${slug}${NC}"
                ((failed_count++))
            fi
        fi
    fi
done < "$README_FILE"

# Final newline to clear progress
echo -e "\n"
echo -e "${BOLD}${MAGENTA}Summary:${NC}"
echo -e "  ${BOLD}${BLUE}Total Skills:${NC}  $total_count"
echo -e "  ${BOLD}${GREEN}Downloaded:${NC}    $downloaded_count"
echo -e "  ${BOLD}${YELLOW}Skipped:${NC}       $skipped_count"
[ $failed_count -gt 0 ] && echo -e "  ${BOLD}${RED}Failed:${NC}        $failed_count"

rmdir "$TEMP_DIR" 2>/dev/null
echo -e "\n${BOLD}${GREEN}✨ Sync complete!${NC}"
