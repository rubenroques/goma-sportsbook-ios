#!/bin/bash

# Ralph Bash Loop - Simple iterative Claude runner
# Usage: ./ralph.sh <iterations> [prompt-file]

if [ -z "$1" ]; then
    echo "Usage: $0 <iterations> [prompt-file]"
    echo "Example: $0 50 PROMPT.md"
    exit 1
fi

PROMPT_FILE="${2:-PROMPT.md}"

if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

echo "════════════════════════════════════════"
echo "RALPH BASH LOOP"
echo "Iterations: $1"
echo "Prompt: $PROMPT_FILE"
echo "════════════════════════════════════════"
echo ""

for ((i=1; i<=$1; i++)); do
    echo "Iteration $i / $1"
    echo "────────────────────────────────────────"

    result=$(claude -p "$(cat "$PROMPT_FILE")" --output-format text)

    echo "$result"

    if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
        echo ""
        echo "════════════════════════════════════════"
        echo "All tasks complete after $i iterations."
        echo "════════════════════════════════════════"
        exit 0
    fi

    echo ""
    echo "──── End of iteration $i ────"
    echo ""
done

echo "════════════════════════════════════════"
echo "Reached max iterations ($1)"
echo "════════════════════════════════════════"
exit 1
