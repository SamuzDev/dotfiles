#!/bin/bash
# Toggle between 3 cava modes

CAVA_CONFIG="$HOME/.config/cava/config"
MODE_FILE="$HOME/.config/cava/.mode"

MODES=(
    "$HOME/dotfiles/cava/config"           # 0: plano blanco, barras JUNTAS y GRUESAS
    "$HOME/dotfiles/cava/config.spaced"    # 1: plano blanco, barras CON ESPACIO
    "$HOME/.config/cava/config.43pr"       # 2: 43PR (gris/blanco, con espacio)
)

NAMES=(
    "Plano blanco - barras JUNTAS y GRUESAS"
    "Plano blanco - barras CON ESPACIO"
    "43PR (gradiente gris/blanco, con espacio)"
)

CURRENT=0
[ -f "$MODE_FILE" ] && CURRENT=$(cat "$MODE_FILE")

NEXT=$(( (CURRENT + 1) % ${#MODES[@]} ))
cp "${MODES[$NEXT]}" "$CAVA_CONFIG"
echo "$NEXT" > "$MODE_FILE"
echo "→ ${NAMES[$NEXT]}"
pgrep -x cava >/dev/null && echo "  cava corriendo → presiona 'r' para recargar"