#!/bin/bash
# Updates cava colors from noctalia's wallpaper-generated palette
# Reads ~/.config/noctalia/palettes/output-mo.json and updates cava config

PALETTE="$HOME/.config/noctalia/palettes/output-mo.json"
CAVA_CONFIG="$HOME/.config/cava/config"

if [ ! -f "$PALETTE" ]; then
    echo "No noctalia palette found"
    exit 1
fi

# Extract pink/error color from noctalia palette (dark mode)
PINK=$(python3 -c "
import json
with open('$PALETTE') as f:
    data = json.load(f)
print(data['dark']['mError'])
" 2>/dev/null)

# Fallback to hardcoded pink if extraction fails
if [ -z "$PINK" ]; then
    PINK="#ffb4ab"
fi

# Update cava config with the extracted color
if [ -f "$CAVA_CONFIG" ]; then
    sed -i "s/foreground = '.*'/foreground = '$PINK'/" "$CAVA_CONFIG"
    echo "Cava color updated to $PINK"
else
    echo "Cava config not found at $CAVA_CONFIG"
fi
