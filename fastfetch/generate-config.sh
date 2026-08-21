#!/bin/bash
# Generate fastfetch config with fixed magenta/pink colors

CONFIG_FILE="$HOME/.config/fastfetch/config.jsonc"

# Generate config
cat > "$CONFIG_FILE" << 'EOF'
{
    "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "~/.config/fastfetch/logo.txt",
        "color": {
            "1": "#f5c2e7",
            "2": "#cba6f7"
        },
        "padding": {
            "top": 1,
            "left": 2,
            "right": 6
        }
    },
    "display": {
        "separator": " ",
        "color": {
            "keys": "#a6adc8",
            "output": "#cdd6f4"
        },
        "key": {
            "width": 10
        }
    },
    "modules": [
        "break",
        {
            "type": "title",
            "key": "  ",
            "format": "{1}"
        },
        {
            "type": "separator",
            "key": "  "
        },
        {
            "type": "os",
            "key": "  os",
            "format": "{2}"
        },
        {
            "type": "kernel",
            "key": "  kernel",
            "format": "{2}"
        },
        {
            "type": "shell",
            "key": "  shell",
            "format": "{2}"
        },
        {
            "type": "wm",
            "key": "  wm",
            "format": "{1}"
        },
        {
            "type": "terminal",
            "key": "  term",
            "format": "{2}"
        },
        "break",
        {
            "type": "cpu",
            "key": "  cpu",
            "format": "{1}"
        },
        {
            "type": "gpu",
            "key": "  gpu",
            "format": "{1}"
        },
        {
            "type": "memory",
            "key": "  mem",
            "format": "{1}"
        },
        {
            "type": "uptime",
            "key": "  uptime",
            "format": "{1}"
        },
        "break",
        {
            "type": "packages",
            "key": "  pkgs",
            "format": "{1}"
        },
        "break"
    ]
}
EOF

echo "Fastfetch config generated with magenta/pink colors"
