#!/bin/bash
# Toggle between cava configs: yours vs 43PR's

CAVA_CONFIG="$HOME/.config/cava/config"
YOUR_CONFIG="$HOME/dotfiles/cava/config"
THEIR_CONFIG="$HOME/.config/cava/config.43pr"

# Check current config and toggle
if diff -q "$CAVA_CONFIG" "$YOUR_CONFIG" >/dev/null 2>&1; then
    cp "$THEIR_CONFIG" "$CAVA_CONFIG"
    echo "→ 43PR config (gradiente gris/blanco, barras con espacio)"
else
    cp "$YOUR_CONFIG" "$CAVA_CONFIG"
    echo "→ Tu config (plano rosa, barras juntas)"
fi

# Si cava está corriendo, recarga con 'r' (cava hotkey)
if pgrep -x cava >/dev/null; then
    echo "  cava detectado → presiona 'r' en cava para recargar"
fi