#!/bin/bash
# Toggle between cava configs (3 modes)

CAVA_CONFIG="$HOME/.config/cava/config"
MODE_FILE="$HOME/.config/cava/.mode"

MODES=(
    "$HOME/dotfiles/cava/config"             # 0: ncurses, rosa, gap mínimo
    "$HOME/dotfiles/cava/config.inverted"    # 1: ncurses, blanco→negro, gap mínimo
    "$HOME/.config/cava/config.43pr"         # 2: 43PR gris/blanco, con espacio
)

NAMES=(
    "NCURSES rosa (barras juntas)"
    "NCURSES invertido blanco→negro (barras juntas)"
    "43PR noncurses gris/blanco (con espacio)"
)

CURRENT=0
[ -f "$MODE_FILE" ] && CURRENT=$(cat "$MODE_FILE")

NEXT=$(( (CURRENT + 1) % ${#MODES[@]} ))
cp "${MODES[$NEXT]}" "$CAVA_CONFIG"
echo "$NEXT" > "$MODE_FILE"
echo "→ ${NAMES[$NEXT]}"
pgrep -x cava >/dev/null && echo "  cava corriendo → presiona 'r' para recargar"