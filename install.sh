#!/bin/bash
# Dotfiles installer for samuz's setup
# niri + noctalia + fish + starship

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Backup existing configs
backup() {
    local dir="$1"
    if [ -d "$CONFIG_DIR/$dir" ]; then
        local backup_dir="$CONFIG_DIR/.backup-$(date +%Y%m%d%H%M%S)"
        warn "Backing up existing $dir to $backup_dir"
        mv "$CONFIG_DIR/$dir" "$backup_dir"
    fi
}

# Create symlinks
link() {
    local src="$DOTFILES_DIR/$1"
    local dest="$CONFIG_DIR/$2"
    
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        backup "$(basename "$dest")"
    fi
    
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    success "Linked $1 -> $2"
}

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     samuz dotfiles installer         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# Link configs
info "Linking configuration files..."

link "niri" "niri"
link "fish" "fish"
link "starship/starship.toml" "starship.toml"
link "fastfetch" "fastfetch"
link "alacritty" "alacritty"
link "btop" "btop"
link "fuzzel" "fuzzel"
link "lazygit" "lazygit"

echo ""
info "Installing dependencies..."

# Check for required tools
command -v niri >/dev/null 2>&1 || warn "niri not found - install from https://github.com/YaLTeR/niri"
command -v noctalia >/dev/null 2>&1 || warn "noctalia not found - install from https://noctalia.dev"
command -v fish >/dev/null 2>&1 || warn "fish not found - install: sudo pacman -S fish"
command -v starship >/dev/null 2>&1 || warn "starship not found - install: curl -sS https://starship.rs/install.sh | sh"
command -v fastfetch >/dev/null 2>&1 || warn "fastfetch not found - install: sudo pacman -S fastfetch"
command -v alacritty >/dev/null 2>&1 || warn "alacritty not found - install: sudo pacman -S alacritty"
command -v btop >/dev/null 2>&1 || warn "btop not found - install: sudo pacman -S btop"
command -v fuzzel >/dev/null 2>&1 || warn "fuzzel not found - install: sudo pacman -S fuzzel"
command -v lazygit >/dev/null 2>&1 || warn "lazygit not found - install: sudo pacman -S lazygit"
command -v eza >/dev/null 2>&1 || warn "eza not found - install: sudo pacman -S eza"
command -v zoxide >/dev/null 2>&1 || warn "zoxide not found - install: sudo pacman -S zoxide"
command -v direnv >/dev/null 2>&1 || warn "direnv not found - install: sudo pacman -S direnv"

echo ""
info "Setting fish as default shell..."
if command -v fish >/dev/null 2>&1; then
    if ! grep -q "$(which fish)" /etc/shells 2>/dev/null; then
        echo "$(which fish)" | sudo tee -a /etc/shells > /dev/null
    fi
    chsh -s "$(which fish)" 2>/dev/null && success "Fish set as default shell" || warn "Could not set fish as default shell"
fi

echo ""
success "Installation complete!"
echo ""
info "Next steps:"
echo "  1. Restart your terminal"
echo "  2. Start niri: niri-session"
echo "  3. Noctalia will auto-start with niri"
echo ""
info "Keybindings:"
echo "  Mod+Return     -> Terminal"
echo "  Mod+B          -> Browser"
echo "  Mod+F12        -> App Launcher"
echo "  Mod+S          -> Control Center"
echo "  Mod+Shift+Q    -> Session Menu"
echo "  Mod+F1         -> Keybind Cheatsheet"
echo ""
