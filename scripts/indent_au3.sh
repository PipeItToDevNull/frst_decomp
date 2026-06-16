#!/usr/bin/env bash

# Usage:
#   ./autoit_indent.sh input.au3 > output.au3
#   or
#   ./autoit_indent.sh input.au3 output.au3

INPUT="$1"
OUTPUT="$2"

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 input.au3 [output.au3]"
  exit 1
fi

INDENT_WIDTH=4

awk -v indent_width="$INDENT_WIDTH" '

BEGIN {
    indent = 0
}

function spaces(n) {
    return sprintf("%" n "s", "")
}

{
    line = $0
    trimmed = line

    # Trim leading whitespace
    sub(/^[ \t]+/, "", trimmed)

    lower = tolower(trimmed)

    # Decrease indent BEFORE printing for block endings
    if (lower ~ /^(endif|next|wend|endfunc|endswitch|endselect|endwith|until)/) {
        indent--
    }

    # Handle Else / ElseIf (reduce then re-add)
    if (lower ~ /^(else|elseif)/) {
        indent--
        if (indent < 0) indent = 0
        print spaces(indent * indent_width) trimmed
        indent++
        next
    }

    # Prevent negative indent
    if (indent < 0) indent = 0

    # Print line
    print spaces(indent * indent_width) trimmed

    # Increase indent AFTER printing for block starts
    if (lower ~ /^(if .*then$|for |while |func |switch |select |with |do$)/) {
        indent++
    }

}
' "$INPUT" > "${OUTPUT:-/dev/stdout}"
