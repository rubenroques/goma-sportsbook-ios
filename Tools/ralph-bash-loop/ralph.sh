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

    # Stream output AND capture it (tee writes to both stdout and file)
    TEMP_OUTPUT="/tmp/ralph_iteration_${i}.txt"

    claude -p "$(cat "$PROMPT_FILE")" \
        --dangerously-skip-permissions \
        --output-format text \
        2>&1 | tee "$TEMP_OUTPUT"

    # Read the captured output to check for promise
    result=$(cat "$TEMP_OUTPUT")

    if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
        echo ""
        echo "════════════════════════════════════════"
        echo "All tasks complete after $i iterations."
        echo "════════════════════════════════════════"
        exit 0
    fi

    if [[ "$result" == *"<promise>FAILED</promise>"* ]]; then
        echo ""
        echo "════════════════════════════════════════"
        echo "Task FAILED at iteration $i"
        echo "════════════════════════════════════════"
        exit 1
    fi

    echo ""
    echo "──── End of iteration $i ────"
    echo ""
done

echo "════════════════════════════════════════"
echo "Reached max iterations ($1)"
echo "════════════════════════════════════════"
exit 1
