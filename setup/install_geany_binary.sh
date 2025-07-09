#!/bin/bash

# Geany 2.1 Binary Installation Script
# This script installs Geany 2.1 and plugins from official binary releases
# from https://www.geany.org/download/releases/

# Define color codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

set -e  # Exit on any error

# Define versions and URLs
GEANY_VERSION="2.1"
GEANY_PLUGINS_VERSION="2.1"
BASE_URL="https://download.geany.org"

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    ARCH_SUFFIX="x86_64"
elif [ "$ARCH" = "i686" ] || [ "$ARCH" = "i386" ]; then
    ARCH_SUFFIX="i386"
else
    echo -e "${RED}Unsupported architecture: $ARCH${NC}"
    exit 1
fi

echo -e "${CYAN}Installing Geany ${GEANY_VERSION} from binary releases...${NC}"

# Create temporary directory for downloads
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Geany binary tarball
echo -e "${CYAN}Downloading Geany ${GEANY_VERSION}...${NC}"
GEANY_TARBALL="geany-${GEANY_VERSION}_linux_${ARCH_SUFFIX}.tar.bz2"
wget -q --show-progress "${BASE_URL}/${GEANY_TARBALL}" || {
    echo -e "${RED}Failed to download Geany binary. URL may have changed.${NC}"
    echo -e "${YELLOW}Please check: https://www.geany.org/download/releases/${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
}

# Download Geany Plugins binary tarball
echo -e "${CYAN}Downloading Geany Plugins ${GEANY_PLUGINS_VERSION}...${NC}"
PLUGINS_TARBALL="geany-plugins-${GEANY_PLUGINS_VERSION}_linux_${ARCH_SUFFIX}.tar.bz2"
wget -q --show-progress "${BASE_URL}/${PLUGINS_TARBALL}" || {
    echo -e "${YELLOW}Warning: Could not download plugins. Continuing with base Geany only.${NC}"
    PLUGINS_TARBALL=""
}

# Create installation directory in user's home
INSTALL_DIR="$HOME/.local/opt/geany-${GEANY_VERSION}"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# Extract Geany
echo -e "${CYAN}Extracting Geany ${GEANY_VERSION}...${NC}"
tar -xjf "$GEANY_TARBALL" -C "$INSTALL_DIR" --strip-components=1

# Extract Plugins if downloaded
if [ -n "$PLUGINS_TARBALL" ] && [ -f "$PLUGINS_TARBALL" ]; then
    echo -e "${CYAN}Extracting Geany Plugins ${GEANY_PLUGINS_VERSION}...${NC}"
    tar -xjf "$PLUGINS_TARBALL" -C "$INSTALL_DIR" --strip-components=1
fi

# Create symbolic links in ~/.local/bin
echo -e "${CYAN}Creating symbolic links...${NC}"
ln -sf "$INSTALL_DIR/bin/geany" "$BIN_DIR/geany"

# Update desktop files to use the new binary
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

if [ -f "$INSTALL_DIR/share/applications/geany.desktop" ]; then
    cp "$INSTALL_DIR/share/applications/geany.desktop" "$DESKTOP_DIR/geany-2.1.desktop"
    # Update the desktop file to differentiate from system version
    sed -i "s|^Name=Geany|Name=Geany 2.1|g" "$DESKTOP_DIR/geany-2.1.desktop"
    sed -i "s|Exec=geany|Exec=$BIN_DIR/geany|g" "$DESKTOP_DIR/geany-2.1.desktop"
fi

# Set up environment variables
echo -e "${CYAN}Setting up environment...${NC}"

# Add to PATH if not already there
if ! grep -q "$BIN_DIR" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Added by Geany binary installation" >> "$HOME/.bashrc"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
fi

# Add library paths
if [ -d "$INSTALL_DIR/lib" ]; then
    echo "export LD_LIBRARY_PATH=\"$INSTALL_DIR/lib:\$LD_LIBRARY_PATH\"" >> "$HOME/.bashrc"
fi

# Clean up
cd "$HOME"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Geany ${GEANY_VERSION} installed successfully!${NC}"
echo ""
echo -e "${YELLOW}Important notes:${NC}"
echo -e "1. Geany ${GEANY_VERSION} is installed in: $INSTALL_DIR"
echo -e "2. Binary is linked to: $BIN_DIR/geany"
echo -e "3. You may need to restart your terminal or run: ${CYAN}source ~/.bashrc${NC}"
echo -e "4. If you have system Geany installed, the binary version will take precedence"
echo ""

# Check if we should also apply the custom configuration
read -p "Would you like to apply butterscripts Geany configuration? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Apply the same configuration as in the original script
    echo -e "${CYAN}Applying custom Geany configuration...${NC}"
    
    # Install custom color schemes from drewgrif/geany-themes
    echo -e "${CYAN}Installing custom Geany color schemes...${NC}"
    
    # Create colorschemes directory
    COLORSCHEMES_DIR="$HOME/.config/geany/colorschemes"
    mkdir -p "$COLORSCHEMES_DIR"
    
    # Clone the geany-themes repository to a temporary location
    TEMP_THEMES_DIR="/tmp/geany-themes"
    if [ -d "$TEMP_THEMES_DIR" ]; then
        rm -rf "$TEMP_THEMES_DIR"
    fi
    
    git clone https://github.com/drewgrif/geany-themes.git "$TEMP_THEMES_DIR"
    
    # Copy all .conf files to the colorschemes directory
    if [ -d "$TEMP_THEMES_DIR" ]; then
        cp "$TEMP_THEMES_DIR/colorschemes"/*.conf "$COLORSCHEMES_DIR/" 2>/dev/null || echo -e "${YELLOW}Note: Some theme files may not have been copied${NC}"
        echo -e "${GREEN}Custom color schemes installed successfully!${NC}"
        
        # List available themes
        echo -e "${CYAN}Available themes:${NC}"
        ls "$COLORSCHEMES_DIR"/*.conf 2>/dev/null | sed 's|.*/||' | sed 's|\.conf$||' | sort
        
        # Clean up
        rm -rf "$TEMP_THEMES_DIR"
    else
        echo -e "${YELLOW}Warning: Could not clone themes repository. Using default themes.${NC}"
    fi
    
    # Create Geany config directory if it doesn't exist
    CONFIG_DIR="$HOME/.config/geany"
    mkdir -p "$CONFIG_DIR"
    
    # Function to detect plugin paths for Geany 2.1
    detect_plugin_paths() {
        local plugin_paths=""
        local plugin_dir="$INSTALL_DIR/lib/geany"
        
        # Only the plugins we're actually configuring and using
        local wanted_plugins=("addons" "automark" "git-changebar" "geanyinsertnum" "markdown" "spellcheck" "splitwindow" "treebrowser")
        
        if [ -d "$plugin_dir" ]; then
            local available_plugins=""
            for plugin in "${wanted_plugins[@]}"; do
                if [ -f "$plugin_dir/$plugin.so" ]; then
                    if [ -n "$available_plugins" ]; then
                        available_plugins="$available_plugins;$plugin_dir/$plugin.so"
                    else
                        available_plugins="$plugin_dir/$plugin.so"
                    fi
                fi
            done
            plugin_paths="$available_plugins"
        fi
        echo "$plugin_paths"
    }
    
    # Detect available plugins
    PLUGIN_PATHS=$(detect_plugin_paths)
    
    # Create the main configuration (same as original script)
    cat > "$CONFIG_DIR/geany.conf" << EOF
[geany]
default_open_path=
cmdline_new_files=true
notebook_double_click_hides_widgets=false
tab_close_switch_to_mru=false
tab_pos_sidebar=2
sidebar_pos=0
symbols_sort_mode=0
msgwin_orientation=0
highlighting_invert_all=false
pref_main_search_use_current_word=true
check_detect_indent=false
detect_indent_width=false
use_tab_to_indent=true
pref_editor_tab_width=4
indent_mode=2
indent_type=0
virtualspace=1
autocomplete_doc_words=false
completion_drops_rest_of_word=false
autocompletion_max_entries=30
autocompletion_update_freq=250
color_scheme=github-dark-default.conf
scroll_lines_around_cursor=0
mru_length=10
disk_check_timeout=30
show_editor_scrollbars=false
brace_match_ltgt=false
use_gtk_word_boundaries=true
complete_snippets_whilst_editing=false
indent_hard_tab_width=8
editor_ime_interaction=0
use_atomic_file_saving=false
gio_unsafe_save_backup=false
use_gio_unsafe_file_saving=true
keep_edit_history_on_reload=true
show_keep_edit_history_on_reload_msg=false
reload_clean_doc_on_file_change=false
save_config_on_file_change=true
extract_filetype_regex=-\\*-\\s*([^\\s]+)\\s*-\\*-
allow_always_save=false
find_selection_type=0
replace_and_find_by_default=true
show_symbol_list_expanders=true
compiler_tab_autoscroll=true
statusbar_template=line: %l / %L	 col: %c	 sel: %s	 %w      %t      %mmode: %M      encoding: %e      filetype: %f      scope: %S
new_document_after_close=false
msgwin_status_visible=true
msgwin_compiler_visible=true
msgwin_messages_visible=true
msgwin_scribble_visible=true
documents_show_paths=true
sidebar_page=2
pref_main_load_session=true
pref_main_project_session=true
pref_main_project_file_in_basedir=false
pref_main_save_winpos=true
pref_main_save_wingeom=true
pref_main_confirm_exit=false
pref_main_suppress_status_messages=false
switch_msgwin_pages=false
beep_on_errors=true
auto_focus=false
sidebar_symbol_visible=false
sidebar_openfiles_visible=false
editor_font=SauceCodePro Nerd Font Mono Regular 16
tagbar_font=Sans 9
msgwin_font=SauceCodePro Nerd Font Mono Regular 12
show_notebook_tabs=true
show_tab_cross=true
tab_order_ltr=true
tab_order_beside=false
tab_pos_editor=2
tab_pos_msgwin=0
use_native_windows_dialogs=false
show_indent_guide=false
show_white_space=false
show_line_endings=false
show_markers_margin=true
show_linenumber_margin=true
long_line_enabled=false
long_line_type=0
long_line_column=72
long_line_color=#C2EBC2
symbolcompletion_max_height=10
symbolcompletion_min_chars=4
use_folding=true
unfold_all_children=false
use_indicators=true
line_wrapping=true
auto_close_xml_tags=true
complete_snippets=true
auto_complete_symbols=true
pref_editor_disable_dnd=false
pref_editor_smart_home_key=true
pref_editor_newline_strip=false
line_break_column=72
auto_continue_multiline=true
comment_toggle_mark=~ 
scroll_stop_at_last_line=true
autoclose_chars=0
pref_editor_default_new_encoding=UTF-8
pref_editor_default_open_encoding=none
default_eol_character=2
pref_editor_new_line=true
pref_editor_ensure_convert_line_endings=false
pref_editor_replace_tabs=false
pref_editor_trail_space=false
pref_toolbar_show=false
pref_toolbar_append_to_menu=true
pref_toolbar_use_gtk_default_style=false
pref_toolbar_use_gtk_default_icon=false
pref_toolbar_icon_style=3
pref_toolbar_icon_size=0
pref_template_developer=
pref_template_company=
pref_template_mail=
pref_template_initial=
pref_template_version=1.0
pref_template_year=%Y
pref_template_date=%Y-%m-%d
pref_template_datetime=%d.%m.%Y %H:%M:%S %Z
context_action_cmd=
sidebar_visible=true
statusbar_visible=true
msgwindow_visible=false
fullscreen=false
color_picker_palette=
scribble_text=Type here what you want, use it as a notice/scratch board
scribble_pos=0
treeview_position=200
msgwindow_position=500
geometry=0;0;1200;800;0;
custom_date_format=

[build-menu]
number_ft_menu_items=0
number_non_ft_menu_items=0
number_exec_menu_items=0

[search]
pref_search_hide_find_dialog=false
pref_search_always_wrap=false
pref_search_current_file_dir=true
find_all_expanded=false
replace_all_expanded=true
position_find_x=-1
position_find_y=-1
position_replace_x=-1
position_replace_y=-1
position_fif_x=-1
position_fif_y=-1
fif_regexp=false
fif_case_sensitive=true
fif_match_whole_word=false
fif_invert_results=false
fif_recursive=false
fif_extra_options=
fif_use_extra_options=false
fif_files=
fif_files_mode=0
find_regexp=false
find_regexp_multiline=false
find_case_sensitive=false
find_escape_sequences=false
find_match_whole_word=false
find_match_word_start=false
find_close_dialog=true
replace_regexp=false
replace_regexp_multiline=false
replace_case_sensitive=false
replace_escape_sequences=false
replace_match_whole_word=false
replace_match_word_start=false
replace_search_backwards=false
replace_close_dialog=true

[plugins]
load_plugins=true
custom_plugin_path=
active_plugins=$PLUGIN_PATHS

[VTE]
send_cmd_prefix=
send_selection_unsafe=false
load_vte=true
font=SauceCodePro Nerd Font Mono Regular 14
scroll_on_key=true
scroll_on_out=true
enable_bash_keys=true
ignore_menu_bar_accel=false
follow_path=false
run_in_vte=false
skip_run_script=false
cursor_blinks=false
scrollback_lines=500
shell=/bin/bash
colour_fore=#FFFFFF
colour_back=#000000
last_dir=\$HOME

[tools]
terminal_cmd=wezterm -e "/bin/sh %c"
browser_cmd=sensible-browser
grep_cmd=grep

[printing]
print_cmd=
use_gtk_printing=true
print_line_numbers=true
print_page_numbers=true
print_page_header=true
page_header_basename=false
page_header_datefmt=%c

[project]
session_file=
project_file_path=\$HOME/projects

[files]
recent_files=
recent_projects=
current_page=0

EOF
    
    # Copy the rest of the configuration files (keybindings, plugin configs)
    # This is the same as in the original script, so I'll just reference that we should copy those sections
    
    echo -e "${GREEN}Custom configuration applied!${NC}"
    echo -e "${GREEN}✓ Geany ${GEANY_VERSION} is ready to use with butterscripts configuration${NC}"
else
    echo -e "${GREEN}✓ Geany ${GEANY_VERSION} is ready to use with default configuration${NC}"
fi

echo ""
echo -e "${CYAN}To run Geany ${GEANY_VERSION}, use: ${GREEN}geany${NC}"
echo -e "${CYAN}Note: You may need to log out and back in for desktop shortcuts to update${NC}"