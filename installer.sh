#!/bin/bash
# DESC: ButterScripts installer - Category-based script menu

set -euo pipefail

# Colors (minimal set)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Extract description from script header
get_description() {
    local script="$1"
    local desc=""
    
    if [[ -f "$script" ]]; then
        # Look for DESC: comment in first 10 lines
        desc=$(head -10 "$script" | grep "^# DESC:" | sed 's/^# DESC: *//' || true)
    fi
    
    [[ -z "$desc" ]] && desc="No description"
    echo "$desc"
}

# Discover scripts by category
discover_scripts() {
    local category="$1"
    local scripts=()
    
    while IFS= read -r -d '' script; do
        # Skip installer.sh and hidden files
        [[ "$(basename "$script")" == "installer.sh" ]] && continue
        [[ "$(basename "$script")" == .* ]] && continue
        
        scripts+=("$script")
    done < <(find "$SCRIPT_DIR/$category" -maxdepth 1 -type f \( -name "*.sh" -o -executable \) -print0 2>/dev/null | sort -z)
    
    printf '%s\n' "${scripts[@]}"
}

# Get all categories (directories with scripts)
get_categories() {
    local categories=()
    
    for dir in "$SCRIPT_DIR"/*; do
        [[ ! -d "$dir" ]] && continue
        [[ "$(basename "$dir")" == .* ]] && continue
        
        # Check if directory contains any scripts
        if find "$dir" -maxdepth 1 -type f \( -name "*.sh" -o -executable \) -print -quit 2>/dev/null | grep -q .; then
            categories+=("$(basename "$dir")")
        fi
    done
    
    printf '%s\n' "${categories[@]}" | sort
}

# Display category menu
show_categories() {
    echo -e "\n${CYAN}ButterScripts - Select Category${NC}\n"
    
    local categories=()
    readarray -t categories < <(get_categories)
    
    if [[ ${#categories[@]} -eq 0 ]]; then
        echo -e "${RED}No script categories found!${NC}"
        exit 1
    fi
    
    for i in "${!categories[@]}"; do
        local cat="${categories[$i]}"
        local count=$(find "$SCRIPT_DIR/$cat" -maxdepth 1 -type f \( -name "*.sh" -o -executable \) 2>/dev/null | wc -l)
        printf "${GREEN}%2d)${NC} %-20s ${YELLOW}(%d scripts)${NC}\n" $((i+1)) "$cat" "$count"
    done
    
    echo -e "\n${GREEN}q)${NC} Quit"
}

# Display scripts in category
show_scripts() {
    local category="$1"
    echo -e "\n${CYAN}$category Scripts${NC}\n"
    
    local scripts=()
    readarray -t scripts < <(discover_scripts "$category")
    
    if [[ ${#scripts[@]} -eq 0 ]]; then
        echo -e "${RED}No scripts found in $category${NC}"
        return 1
    fi
    
    for i in "${!scripts[@]}"; do
        local script="${scripts[$i]}"
        local name="$(basename "$script" .sh)"
        local desc="$(get_description "$script")"
        printf "${GREEN}%2d)${NC} %-25s ${YELLOW}%s${NC}\n" $((i+1)) "$name" "$desc"
    done
    
    echo -e "\n${GREEN}b)${NC} Back to categories"
    echo -e "${GREEN}q)${NC} Quit"
}

# Run selected script
run_script() {
    local script="$1"
    local name="$(basename "$script")"
    
    echo -e "\n${YELLOW}Running: $name${NC}\n"
    
    # Make executable if needed
    [[ -x "$script" ]] || chmod +x "$script"
    
    # Run the script
    if bash "$script"; then
        echo -e "\n${GREEN}✓ $name completed successfully${NC}"
    else
        echo -e "\n${RED}✗ $name failed with exit code $?${NC}"
    fi
    
    echo -e "\nPress Enter to continue..."
    read -r
}

# Main menu loop
main() {
    local categories=()
    readarray -t categories < <(get_categories)
    
    while true; do
        clear
        show_categories
        
        echo -n -e "\nSelect category: "
        read -r choice
        
        case "$choice" in
            q|Q)
                echo -e "\n${CYAN}Thanks for using ButterScripts! 🧈${NC}"
                exit 0
                ;;
            ''|*[!0-9]*)
                continue
                ;;
            *)
                if [[ $choice -ge 1 && $choice -le ${#categories[@]} ]]; then
                    local selected_category="${categories[$((choice-1))]}"
                    
                    # Script selection loop
                    while true; do
                        clear
                        show_scripts "$selected_category" || break
                        
                        local scripts=()
                        readarray -t scripts < <(discover_scripts "$selected_category")
                        
                        echo -n -e "\nSelect script: "
                        read -r script_choice
                        
                        case "$script_choice" in
                            b|B) break ;;
                            q|Q) exit 0 ;;
                            ''|*[!0-9]*) continue ;;
                            *)
                                if [[ $script_choice -ge 1 && $script_choice -le ${#scripts[@]} ]]; then
                                    run_script "${scripts[$((script_choice-1))]}"
                                fi
                                ;;
                        esac
                    done
                fi
                ;;
        esac
    done
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi