# Ralph Bash Loop

> A bash-based harness for running Claude Code in autonomous, iterative loops for large-scale repetitive tasks.

---

## Table of Contents

- [1. Introduction](#1-introduction)
  - [1.1 What is Ralph Bash Loop?](#11-what-is-ralph-bash-loop)
  - [1.2 Origin & Naming](#12-origin--naming)
  - [1.3 The Problem We're Solving](#13-the-problem-were-solving)
  - [1.4 This Tool vs Alternatives](#14-this-tool-vs-alternatives)
- [2. Research Deep Dive](#2-research-deep-dive)
  - [2.1 Anthropic's "Effective Harnesses" Article](#21-anthropics-effective-harnesses-article)
  - [2.2 Claude Code Headless Mode](#22-claude-code-headless-mode)
  - [2.3 The Ralph Wiggum Plugin](#23-the-ralph-wiggum-plugin)
  - [2.4 Key Insights from Production](#24-key-insights-from-production)
- [3. Architecture](#3-architecture)
  - [3.1 System Overview](#31-system-overview)
  - [3.2 File Structure](#32-file-structure)
  - [3.3 The Iteration Lifecycle](#33-the-iteration-lifecycle)
  - [3.4 State Management](#34-state-management)
- [4. Core Components](#4-core-components)
  - [4.1 ralph.sh - The Loop Script](#41-ralphsh---the-loop-script)
  - [4.2 tasks.json - Task Definitions](#42-tasksjson---task-definitions)
  - [4.3 PROMPT.md - Context Template](#43-promptmd---context-template)
  - [4.4 progress.txt - Session Log](#44-progresstxt---session-log)
  - [4.5 Completion Promises](#45-completion-promises)
- [5. When to Use / When NOT to Use](#5-when-to-use--when-not-to-use)
  - [5.1 Ideal Use Cases](#51-ideal-use-cases)
  - [5.2 When NOT to Use](#52-when-not-to-use)
  - [5.3 Cost Considerations](#53-cost-considerations)
  - [5.4 Decision Checklist](#54-decision-checklist)
- [6. Best Practices & Bad Practices](#6-best-practices--bad-practices)
  - [6.1 Best Practices](#61-best-practices)
  - [6.2 Bad Practices](#62-bad-practices)
  - [6.3 Common Failure Modes](#63-common-failure-modes)
- [7. Implementation Guide](#7-implementation-guide)
  - [7.1 Setting Up a Use Case](#71-setting-up-a-use-case)
  - [7.2 Writing an Effective PROMPT.md](#72-writing-an-effective-promptmd)
  - [7.3 Running the Loop](#73-running-the-loop)
  - [7.4 Monitoring Progress](#74-monitoring-progress)
  - [7.5 Handling Failures](#75-handling-failures)
- [8. CLI Reference & Troubleshooting](#8-cli-reference--troubleshooting)
  - [8.1 Command Line Arguments](#81-command-line-arguments)
  - [8.2 Environment Variables](#82-environment-variables)
  - [8.3 Exit Codes](#83-exit-codes)
  - [8.4 Common Issues & Solutions](#84-common-issues--solutions)
- [9. Sources & References](#9-sources--references)

---

## 1. Introduction

### 1.1 What is Ralph Bash Loop?

Ralph Bash Loop is an external orchestration system that runs Claude Code in headless mode repeatedly until a large task is complete. Unlike running Claude Code interactively or using the built-in Ralph Wiggum plugin, this approach gives you:

- **Full control** over the iteration logic from outside Claude
- **Perfect context injection** - each iteration gets exactly what it needs for ONE task
- **File-based state** - progress survives crashes, can be inspected, edited manually
- **No token waste** - fresh context each iteration instead of accumulating history
- **Verification gates** - code must compile/pass tests before marking complete

The core loop is simple:

```bash
while tasks_remain; do
    task=$(get_next_incomplete_task)
    context=$(generate_context_for "$task")
    result=$(claude -p "$context" --allowedTools "Read,Write,Edit,Bash")

    if [[ "$result" == *"<promise>DONE</promise>"* ]]; then
        mark_task_complete "$task"
    fi
done
```

### 1.2 Origin & Naming

The name "Ralph" comes from the **Ralph Wiggum technique**, popularized in the Claude Code community. Named after the Simpsons character known for persistent (if not always successful) attempts, it embodies the philosophy:

> "Keep trying until you get it right, learning from each attempt."

The original Ralph Wiggum approach was described by Geoffrey Huntley as simply:

> "Ralph is a Bash loop - a simple `while true` that repeatedly feeds an AI agent a prompt file, allowing it to iteratively improve its work until completion."

This implementation takes that concept and adds:
- Structured task management (not just one prompt file)
- External state tracking (tasks.json, progress.txt)
- Verification requirements before marking done
- Clean separation between orchestration (bash) and execution (Claude)

### 1.3 The Problem We're Solving

**The Context Window Problem**

Claude Code sessions don't persist indefinitely. When working on large tasks:
- Context accumulates and eventually hits limits
- Sessions can crash or timeout
- Resuming requires re-explaining everything
- No clear checkpoint/restart mechanism

**The "One-Shot" Problem**

From Anthropic's research:

> "A common failure mode is attempting to one-shot complex tasks. Agents work better on single features sequentially."

Trying to process 50 components in one session leads to:
- Context exhaustion
- Accumulated errors
- No clear progress tracking
- Difficult recovery from failures

**The Verification Problem**

> "Marking features done without testing is a common failure mode." - Anthropic

Without external verification gates, Claude might:
- Declare victory prematurely
- Leave broken code
- Skip edge cases
- Not actually run the tests

**Ralph Bash Loop solves these by:**
1. Breaking work into discrete, independent tasks
2. Running one task per Claude invocation (fresh context)
3. Requiring verification before marking complete
4. Tracking progress externally in files
5. Enabling restart from any point

### 1.4 This Tool vs Alternatives

| Approach | Pros | Cons |
|----------|------|------|
| **Interactive Claude Code** | Full control, can course-correct | Manual, doesn't scale, context limits |
| **Ralph Wiggum Plugin** | Built-in, simple setup | Burns tokens on history, less control |
| **Claude Code SDK** | Programmatic, powerful | Requires coding, more complex |
| **Ralph Bash Loop** | External control, file state, verification | Requires setup, bash knowledge |
| **GitHub Actions + Claude** | CI integration, triggers | Not interactive, slower feedback |

**Choose Ralph Bash Loop when:**
- You have 20+ similar tasks
- Tasks are independent (order doesn't matter much)
- Each task has clear success criteria
- You want to walk away and let it run
- You need to restart/resume reliably

**Choose Interactive Claude Code when:**
- Tasks require human judgment
- Each task is unique
- You need to see intermediate results
- Task count < 10

**Choose Ralph Wiggum Plugin when:**
- Single complex task (not many similar ones)
- You want session continuity
- Context accumulation is beneficial

---

## 2. Research Deep Dive

### 2.1 Anthropic's "Effective Harnesses" Article

**Source:** [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

This is the foundational research that informs Ralph Bash Loop's design. Key findings:

#### Two-Agent Architecture

Anthropic developed a system with two distinct agent phases:

1. **Initializer Agent**: Runs once at the start
   - Sets up environment
   - Creates initial file structure
   - Establishes baseline state

2. **Coding Agent**: Runs repeatedly for each task
   - Reads current state from files
   - Works on ONE feature/task
   - Updates state files when done

This separation is crucial because:
> "Finding a way for agents to quickly understand the state of work when starting with a fresh context window" is the core challenge.

#### State Persistence Files

Anthropic's system maintains:

| File | Purpose |
|------|---------|
| `claude-progress.txt` | Human-readable log of what's been done |
| `feature_list.json` | Structured task list with `passes: true/false` |
| Git repository | Enables rollback and diff analysis |
| `init.sh` | Reproducible environment setup |

#### Feature-Based Breakdown

> "Agents work on single features sequentially, avoiding attempt to one-shot the app."

Key insights:
- Initial task list had **200+ granular features**
- Each feature is **independently testable**
- Features marked "passing" only **after verification**
- Agents select **highest-priority incomplete** feature each session

#### Verification Before Completion

> "A common failure mode: marking features done without testing."

Anthropic's solution:
- Browser automation testing (Puppeteer MCP)
- End-to-end validation as human users would
- Health checks before starting new features
- Git commits only after verified success

#### Session Startup Checklist

Each agent session follows:
1. Read progress files and git logs
2. Run baseline functionality tests
3. Select highest-priority incomplete feature
4. Execute feature work
5. Document progress via git commit

### 2.2 Claude Code Headless Mode

**Source:** [Run Claude Code Programmatically](https://code.claude.com/docs/en/headless)

Headless mode is the foundation that makes Ralph Bash Loop possible.

#### Basic Invocation

```bash
claude -p "your prompt here" [options]
```

The `-p` (or `--print`) flag:
- Runs non-interactively
- Prints result to stdout
- Exits when done (or times out)

#### Key Flags for Ralph Loop

| Flag | Purpose | Example |
|------|---------|---------|
| `-p "prompt"` | The instruction to execute | `-p "Create tests for ButtonView"` |
| `--allowedTools` | Tools Claude can use without asking | `--allowedTools "Read,Write,Edit,Bash"` |
| `--max-turns N` | Limit agentic iterations | `--max-turns 30` |
| `--output-format` | Response format | `--output-format text` |
| `--append-system-prompt` | Add to system prompt | `--append-system-prompt "You are a test expert"` |

#### Tool Permissions

Without `--allowedTools`, Claude can't do anything useful in headless mode (no one to click "allow").

**Scoped permissions** for safety:
```bash
# Only allow specific git commands
--allowedTools "Bash(git diff:*),Bash(git status:*),Bash(git add:*)"

# Only allow reading and specific writes
--allowedTools "Read,Write(src/tests/**)"
```

**Full permissions** for trusted tasks:
```bash
--allowedTools "Read,Write,Edit,Bash,Glob,Grep"
```

#### Output Formats

| Format | Use Case |
|--------|----------|
| `text` (default) | Human reading, simple scripts |
| `json` | Parsing with jq, programmatic use |
| `stream-json` | Real-time streaming, live monitoring |

For Ralph Loop, `text` is usually sufficient since we just check for promise tags.

#### Session Management (Not Used in Ralph Loop)

Headless mode supports `--continue` and `--resume` for session continuity, but Ralph Loop intentionally **doesn't use these** because:
- Fresh context prevents accumulation
- File-based state is more reliable
- Easier to debug and inspect
- Can edit state between iterations

### 2.3 The Ralph Wiggum Plugin

**Source:** [Ralph Wiggum Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)

Understanding the plugin helps understand what Ralph Bash Loop does differently.

#### How the Plugin Works

1. You start Claude Code with a task
2. Claude works on it
3. When Claude tries to exit, a **Stop hook** intercepts
4. The hook feeds the **same prompt** back in
5. Claude sees its previous changes and continues
6. Repeat until completion promise detected

#### Plugin Invocation

```bash
/ralph-loop "Migrate all tests from Jest to Vitest" --max-iterations 50 --completion-promise "DONE"
```

#### Key Differences from Bash Loop

| Aspect | Ralph Wiggum Plugin | Ralph Bash Loop |
|--------|---------------------|-----------------|
| **Control** | Inside Claude session | Outside, bash script |
| **Context** | Accumulates (can exhaust) | Fresh each iteration |
| **State** | Session memory | External files |
| **Task Selection** | Same prompt repeated | Different task each time |
| **Customization** | Limited parameters | Full bash scripting |
| **Debugging** | Check session logs | Inspect files directly |
| **Recovery** | Restart session | Edit files, continue |

#### When Plugin is Better

- Single complex task needing iteration
- Context accumulation is beneficial (building on previous work)
- Simple setup preferred

#### When Bash Loop is Better

- Many independent tasks
- Need external verification
- Want fine control over each iteration
- Need reliable restart/resume

### 2.4 Key Insights from Production

From various sources and community experience:

#### From Anthropic's Best Practices

**Source:** [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)

**The Fan-Out Pattern:**
> "Have Claude write a script to generate a task list. For example, generate a list of 2k files that need to be migrated. Loop through tasks, calling Claude programmatically for each."

```bash
# Generate task list
claude -p "Generate list of files needing migration" > task-list.txt

# Process each
for file in $(cat task-list.txt); do
    claude -p "Migrate $file" --allowedTools "Edit"
done
```

**Pipeline Integration:**
> "Call `claude -p '<prompt>' --json | your_command` where your_command is the next pipeline step."

#### From Community Usage

**Token Cost Reality:**
- 50-iteration loop on large codebase: $50-100+
- Set `--max-iterations` conservatively
- Monitor usage, especially early on

**The "Deterministically Bad" Principle:**
> "Deterministically bad means failures are predictable and informative. Use them to tune prompts."

If the same task fails the same way repeatedly, the prompt needs improvement, not more retries.

**Context is King:**
> "Success depends on writing good prompts, not just having a good model."

Spending time on PROMPT.md quality pays off more than anything else.

---

## 3. Architecture

### 3.1 System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        RALPH BASH LOOP                              │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                      ralph.sh                                │   │
│  │                                                              │   │
│  │   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐ │   │
│  │   │  Read   │───▶│ Generate│───▶│  Invoke │───▶│  Check  │ │   │
│  │   │ tasks   │    │ context │    │  Claude │    │ result  │ │   │
│  │   └─────────┘    └─────────┘    └─────────┘    └─────────┘ │   │
│  │        │                                            │       │   │
│  │        │              ┌─────────┐                   │       │   │
│  │        └──────────────│  Update │◀──────────────────┘       │   │
│  │                       │  state  │                           │   │
│  │                       └─────────┘                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────────────────┐  ┌──────────────────────┐               │
│  │     tasks.json       │  │    progress.txt      │               │
│  │                      │  │                      │               │
│  │  [{                  │  │  [2026-01-13 00:45]  │               │
│  │    "id": "001",      │  │  Iteration 1:        │               │
│  │    "component": "X", │  │  ButtonView - DONE   │               │
│  │    "passes": false   │  │                      │               │
│  │  }]                  │  │  [2026-01-13 00:48]  │               │
│  │                      │  │  Iteration 2:        │               │
│  └──────────────────────┘  │  CapsuleView - DONE  │               │
│                            └──────────────────────┘               │
│  ┌──────────────────────┐                                         │
│  │     PROMPT.md        │                                         │
│  │                      │  ┌──────────────────────┐               │
│  │  # Task: {COMPONENT} │  │   Claude Code        │               │
│  │                      │  │   (Headless)         │               │
│  │  ## Context          │──▶│                      │               │
│  │  {INJECTED_DATA}     │  │   - Reads files      │               │
│  │                      │  │   - Writes code      │               │
│  │  ## Steps            │  │   - Runs tests       │               │
│  │  1. Create files     │  │   - Outputs promise  │               │
│  │  2. Test             │  │                      │               │
│  │  3. Output promise   │  └──────────────────────┘               │
│  └──────────────────────┘                                         │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 File Structure

```
tools/ralph-bash-loop/
├── README.md                          # This documentation
├── ralph.sh                           # Main loop script (reusable)
│
└── use-cases/
    └── {use-case-name}/               # One folder per use case
        ├── README.md                  # Use case specific docs
        ├── PROMPT.md                  # Claude's instructions template
        ├── tasks.json                 # Task definitions
        ├── progress.txt               # Runtime log (created by script)
        └── generate-tasks.sh          # Optional: script to create tasks.json
```

**Why this structure?**

- `ralph.sh` is **reusable** across use cases
- Each use case is **self-contained** in its folder
- `tasks.json` is the **source of truth** for what's done
- `progress.txt` is **human-readable** debug log
- `PROMPT.md` is the **template** with placeholders

### 3.3 The Iteration Lifecycle

Each iteration follows this exact sequence:

```
┌────────────────────────────────────────────────────────────────┐
│                    ITERATION LIFECYCLE                         │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  1. TASK SELECTION                                             │
│     │                                                          │
│     ├─▶ Read tasks.json                                        │
│     ├─▶ Find first task where passes: false                    │
│     ├─▶ If none found → ALL COMPLETE → exit 0                  │
│     └─▶ Extract task details (id, component, category, etc.)   │
│                                                                │
│  2. CONTEXT GENERATION                                         │
│     │                                                          │
│     ├─▶ Read PROMPT.md template                                │
│     ├─▶ Replace {COMPONENT_NAME} with actual value             │
│     ├─▶ Inject task-specific data:                             │
│     │   ├─▶ Component file paths                               │
│     │   ├─▶ MockViewModel contents                             │
│     │   ├─▶ Reference implementation                           │
│     │   └─▶ Verification commands                              │
│     └─▶ Write rendered prompt to temp file                     │
│                                                                │
│  3. CLAUDE INVOCATION                                          │
│     │                                                          │
│     ├─▶ claude -p "$(cat rendered_prompt.md)" \                │
│     │        --allowedTools "Read,Write,Edit,Bash" \           │
│     │        --max-turns 30                                    │
│     ├─▶ Capture stdout to result variable                      │
│     ├─▶ Log full output to iteration_N.log                     │
│     └─▶ Extract promise tag from output                        │
│                                                                │
│  4. RESULT HANDLING                                            │
│     │                                                          │
│     ├─▶ If "<promise>DONE</promise>" in result:                │
│     │   ├─▶ Update tasks.json: passes = true                   │
│     │   ├─▶ Log success to progress.txt                        │
│     │   └─▶ Continue to next iteration                         │
│     │                                                          │
│     ├─▶ If "<promise>FAILED</promise>" in result:              │
│     │   ├─▶ Increment attempts counter                         │
│     │   ├─▶ Log failure to progress.txt                        │
│     │   ├─▶ If attempts < max_attempts: retry same task        │
│     │   └─▶ If attempts >= max_attempts: skip, continue        │
│     │                                                          │
│     ├─▶ If "<promise>SKIP</promise>" in result:                │
│     │   ├─▶ Mark task as skipped (optional field)              │
│     │   ├─▶ Log skip reason to progress.txt                    │
│     │   └─▶ Continue to next iteration                         │
│     │                                                          │
│     └─▶ If no promise found (timeout/crash):                   │
│         ├─▶ Log issue to progress.txt                          │
│         ├─▶ Increment attempts                                 │
│         └─▶ Retry or skip based on config                      │
│                                                                │
│  5. LOOP CONTINUATION                                          │
│     │                                                          │
│     ├─▶ Increment iteration counter                            │
│     ├─▶ Check if iteration < max_iterations                    │
│     ├─▶ If yes → go to step 1                                  │
│     └─▶ If no → exit with "max iterations reached"             │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### 3.4 State Management

#### Primary State: tasks.json

This is the **source of truth**. The script reads it, Claude doesn't modify it directly, only the script updates it based on Claude's output.

```json
[
  {
    "id": "component-001",
    "component": "ButtonView",
    "category": "UIElements",
    "passes": true,
    "attempts": 1
  },
  {
    "id": "component-002",
    "component": "CapsuleView",
    "category": "UIElements",
    "passes": false,
    "attempts": 0
  }
]
```

**Key fields:**
- `id`: Unique identifier for logging
- `component`: The target of this task
- `category`: Grouping (for context generation)
- `passes`: **THE** completion flag (false → needs work, true → done)
- `attempts`: Retry counter for failure handling

#### Secondary State: progress.txt

Human-readable log for debugging:

```
=== Ralph Bash Loop ===
Use Case: gomaui-snapshot-tests
Started: 2026-01-13 00:45:00
Max Iterations: 100

────────────────────────────────────────
[2026-01-13 00:45:12] Iteration 1
Task: ButtonView (component-001)
Status: DONE
Duration: 3m 42s
────────────────────────────────────────
[2026-01-13 00:49:00] Iteration 2
Task: CapsuleView (component-002)
Status: DONE
Duration: 2m 15s
────────────────────────────────────────
[2026-01-13 00:51:30] Iteration 3
Task: PillItemView (component-003)
Status: FAILED
Error: Build failed - missing import
Attempts: 1/3
────────────────────────────────────────
```

#### Why External State (Not Session Memory)?

| Session Memory | External Files |
|----------------|----------------|
| Lost on crash | Survives crashes |
| Hard to inspect | Easy to read/edit |
| Accumulates tokens | Fresh each time |
| Implicit | Explicit |
| Claude controls | Script controls |

---

## 4. Core Components

### 4.1 ralph.sh - The Loop Script

The main orchestrator. Here's the complete implementation:

```bash
#!/bin/bash

# ============================================================================
# RALPH BASH LOOP
# Autonomous Claude Code task runner with external state management
# ============================================================================

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USE_CASE="${1:-}"
MAX_ITERATIONS="${2:-50}"
MAX_ATTEMPTS_PER_TASK="${3:-3}"

# Validate arguments
if [[ -z "$USE_CASE" ]]; then
    echo "Usage: $0 <use-case-folder> [max-iterations] [max-attempts-per-task]"
    echo ""
    echo "Example: $0 use-cases/gomaui-snapshot-tests 100 3"
    echo ""
    echo "Available use cases:"
    ls -1 "$SCRIPT_DIR/use-cases/" 2>/dev/null || echo "  (none found)"
    exit 1
fi

USE_CASE_DIR="$SCRIPT_DIR/$USE_CASE"
TASKS_FILE="$USE_CASE_DIR/tasks.json"
PROMPT_TEMPLATE="$USE_CASE_DIR/PROMPT.md"
PROGRESS_FILE="$USE_CASE_DIR/progress.txt"
LOGS_DIR="$USE_CASE_DIR/logs"

# Validate use case exists
if [[ ! -d "$USE_CASE_DIR" ]]; then
    echo "Error: Use case directory not found: $USE_CASE_DIR"
    exit 1
fi

if [[ ! -f "$TASKS_FILE" ]]; then
    echo "Error: tasks.json not found: $TASKS_FILE"
    exit 1
fi

if [[ ! -f "$PROMPT_TEMPLATE" ]]; then
    echo "Error: PROMPT.md not found: $PROMPT_TEMPLATE"
    exit 1
fi

# Create logs directory
mkdir -p "$LOGS_DIR"

# ─────────────────────────────────────────────────────────────────────────────
# Helper Functions
# ─────────────────────────────────────────────────────────────────────────────

log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message"
    echo "[$timestamp] $message" >> "$PROGRESS_FILE"
}

log_section() {
    local message="$1"
    echo "────────────────────────────────────────" >> "$PROGRESS_FILE"
    log "$message"
}

get_next_task() {
    # Returns the first task where passes is false
    jq -r 'map(select(.passes == false)) | first // empty' "$TASKS_FILE"
}

get_remaining_count() {
    jq '[.[] | select(.passes == false)] | length' "$TASKS_FILE"
}

get_total_count() {
    jq 'length' "$TASKS_FILE"
}

mark_task_done() {
    local task_id="$1"
    local tmp_file=$(mktemp)
    jq --arg id "$task_id" '
        map(if .id == $id then .passes = true else . end)
    ' "$TASKS_FILE" > "$tmp_file" && mv "$tmp_file" "$TASKS_FILE"
}

increment_attempts() {
    local task_id="$1"
    local tmp_file=$(mktemp)
    jq --arg id "$task_id" '
        map(if .id == $id then .attempts = (.attempts + 1) else . end)
    ' "$TASKS_FILE" > "$tmp_file" && mv "$tmp_file" "$TASKS_FILE"
}

get_task_attempts() {
    local task_id="$1"
    jq -r --arg id "$task_id" '.[] | select(.id == $id) | .attempts' "$TASKS_FILE"
}

skip_task() {
    local task_id="$1"
    local tmp_file=$(mktemp)
    jq --arg id "$task_id" '
        map(if .id == $id then .passes = true | .skipped = true else . end)
    ' "$TASKS_FILE" > "$tmp_file" && mv "$tmp_file" "$TASKS_FILE"
}

generate_context() {
    local task_json="$1"
    local component=$(echo "$task_json" | jq -r '.component')
    local category=$(echo "$task_json" | jq -r '.category // "Unknown"')
    local task_id=$(echo "$task_json" | jq -r '.id')

    # Read the prompt template
    local prompt=$(cat "$PROMPT_TEMPLATE")

    # Replace placeholders
    prompt="${prompt//\{COMPONENT_NAME\}/$component}"
    prompt="${prompt//\{CATEGORY\}/$category}"
    prompt="${prompt//\{TASK_ID\}/$task_id}"
    prompt="${prompt//\{TASK_JSON\}/$task_json}"

    echo "$prompt"
}

# ─────────────────────────────────────────────────────────────────────────────
# Main Loop
# ─────────────────────────────────────────────────────────────────────────────

echo "============================================================================"
echo "RALPH BASH LOOP"
echo "============================================================================"
echo ""
echo "Use Case:        $USE_CASE"
echo "Max Iterations:  $MAX_ITERATIONS"
echo "Max Attempts:    $MAX_ATTEMPTS_PER_TASK"
echo "Tasks File:      $TASKS_FILE"
echo "Progress File:   $PROGRESS_FILE"
echo ""

# Initialize progress file
{
    echo "=== Ralph Bash Loop ==="
    echo "Use Case: $USE_CASE"
    echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Max Iterations: $MAX_ITERATIONS"
    echo ""
} > "$PROGRESS_FILE"

total=$(get_total_count)
echo "Total tasks: $total"
echo "Remaining:   $(get_remaining_count)"
echo ""

for ((iteration=1; iteration<=MAX_ITERATIONS; iteration++)); do

    # Get next incomplete task
    task_json=$(get_next_task)

    if [[ -z "$task_json" ]]; then
        log_section "ALL TASKS COMPLETE!"
        echo ""
        echo "============================================================================"
        echo "SUCCESS: All tasks completed after $((iteration-1)) iterations"
        echo "============================================================================"
        exit 0
    fi

    task_id=$(echo "$task_json" | jq -r '.id')
    component=$(echo "$task_json" | jq -r '.component')
    attempts=$(get_task_attempts "$task_id")
    remaining=$(get_remaining_count)

    log_section "Iteration $iteration / $MAX_ITERATIONS"
    log "Task: $component ($task_id)"
    log "Remaining: $remaining / $total"
    log "Attempts: $attempts / $MAX_ATTEMPTS_PER_TASK"

    # Check if max attempts reached
    if [[ "$attempts" -ge "$MAX_ATTEMPTS_PER_TASK" ]]; then
        log "SKIPPING: Max attempts reached for $component"
        skip_task "$task_id"
        continue
    fi

    # Generate context for this task
    context=$(generate_context "$task_json")

    # Save rendered prompt for debugging
    echo "$context" > "$LOGS_DIR/iteration_${iteration}_prompt.md"

    # Record start time
    start_time=$(date +%s)

    # Invoke Claude Code
    log "Invoking Claude Code..."

    result=$(claude -p "$context" \
        --allowedTools "Read,Write,Edit,Bash,Glob,Grep" \
        --max-turns 30 \
        2>&1) || true

    # Save full output
    echo "$result" > "$LOGS_DIR/iteration_${iteration}_output.txt"

    # Calculate duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    # Check result for promise tags
    if [[ "$result" == *"<promise>DONE</promise>"* ]]; then
        log "Status: DONE"
        log "Duration: ${duration}s"
        mark_task_done "$task_id"

    elif [[ "$result" == *"<promise>FAILED</promise>"* ]]; then
        log "Status: FAILED"
        log "Duration: ${duration}s"
        increment_attempts "$task_id"

    elif [[ "$result" == *"<promise>SKIP</promise>"* ]]; then
        log "Status: SKIPPED (by Claude)"
        skip_task "$task_id"

    else
        log "Status: NO PROMISE (timeout/crash?)"
        log "Duration: ${duration}s"
        increment_attempts "$task_id"
    fi

    echo ""
done

log_section "MAX ITERATIONS REACHED"
remaining=$(get_remaining_count)
echo ""
echo "============================================================================"
echo "INCOMPLETE: Reached max iterations ($MAX_ITERATIONS)"
echo "Remaining tasks: $remaining"
echo "============================================================================"
exit 1
```

### 4.2 tasks.json - Task Definitions

The task file defines what needs to be done. Format:

```json
[
  {
    "id": "unique-identifier",
    "component": "ComponentName",
    "category": "CategoryFolder",
    "description": "Human readable description",
    "passes": false,
    "attempts": 0,
    "extra_context": {}
  }
]
```

**Required fields:**
- `id`: Unique string for logging and updates
- `passes`: Boolean, the completion flag
- `attempts`: Integer, retry counter (start at 0)

**Optional but recommended:**
- `component`: Main target name
- `category`: Grouping for context
- `description`: Human-readable task description
- `extra_context`: Object with task-specific data

**Example for snapshot tests:**

```json
[
  {
    "id": "snapshot-ButtonView",
    "component": "ButtonView",
    "category": "UIElements",
    "description": "Create snapshot tests for ButtonView",
    "passes": false,
    "attempts": 0
  },
  {
    "id": "snapshot-CapsuleView",
    "component": "CapsuleView",
    "category": "UIElements",
    "description": "Create snapshot tests for CapsuleView",
    "passes": true,
    "attempts": 1
  }
]
```

### 4.3 PROMPT.md - Context Template

This is the most important file. It determines success or failure.

**Key principles:**
1. **Everything Claude needs, nothing more**
2. **Explicit verification commands**
3. **Clear success/failure criteria**
4. **Promise output requirements**

**Template structure:**

```markdown
# Task: {TASK_DESCRIPTION}

## Current Task
{TASK_JSON}

## Context
[All information needed to complete THIS task]

## Reference Implementation
[Example of what good looks like]

## Steps
1. [First step]
2. [Second step]
3. [Verification step]

## Verification (MANDATORY)
[Exact commands to verify success]

## Output Requirements
- If successful: Output `<promise>DONE</promise>`
- If failed after trying: Output `<promise>FAILED</promise>`
- If task should be skipped: Output `<promise>SKIP</promise>`

## Important Notes
[Any gotchas or special considerations]
```

### 4.4 progress.txt - Session Log

Created and updated by ralph.sh. Human-readable format:

```
=== Ralph Bash Loop ===
Use Case: gomaui-snapshot-tests
Started: 2026-01-13 00:45:00
Max Iterations: 100

────────────────────────────────────────
[2026-01-13 00:45:12] Iteration 1 / 100
[2026-01-13 00:45:12] Task: ButtonView (snapshot-ButtonView)
[2026-01-13 00:45:12] Remaining: 57 / 57
[2026-01-13 00:45:12] Attempts: 0 / 3
[2026-01-13 00:45:12] Invoking Claude Code...
[2026-01-13 00:48:54] Status: DONE
[2026-01-13 00:48:54] Duration: 222s

────────────────────────────────────────
[2026-01-13 00:48:55] Iteration 2 / 100
...
```

### 4.5 Completion Promises

Promises are how Claude signals task completion to the bash script.

| Promise Tag | Meaning | Script Action |
|-------------|---------|---------------|
| `<promise>DONE</promise>` | Task completed successfully | Mark passes=true, continue |
| `<promise>FAILED</promise>` | Task failed, can't complete | Increment attempts, retry or skip |
| `<promise>SKIP</promise>` | Task invalid/not applicable | Mark skipped, continue |
| (none found) | Timeout, crash, or forgot | Increment attempts, retry |

**In PROMPT.md:**

```markdown
## Output Requirements

CRITICAL: You MUST output exactly ONE of these tags at the END of your response:

- `<promise>DONE</promise>` - Task completed AND verified
- `<promise>FAILED</promise>` - Tried but cannot complete
- `<promise>SKIP</promise>` - Task is not applicable

Do NOT output DONE unless verification passed.
Do NOT output FAILED on first error - try to fix it first.
```

---

## 5. When to Use / When NOT to Use

### 5.1 Ideal Use Cases

#### Perfect Fit Scenarios

**1. Batch Code Generation**
- Generate tests for 50+ components
- Create documentation for all APIs
- Add type annotations to many files

**2. Systematic Migrations**
- React to Vue conversion
- JavaScript to TypeScript
- API v1 to v2 updates
- Framework upgrades

**3. Compliance/Policy Updates**
- Add license headers to all files
- Update deprecated API calls
- Apply security patches

**4. Data Processing**
- Analyze and categorize code files
- Extract metadata from components
- Generate configuration from code

#### Characteristics Checklist

✅ **Good fit if:**
- [ ] 20+ similar tasks
- [ ] Each task is independent
- [ ] Clear success criteria per task
- [ ] Each task takes 2-15 minutes
- [ ] Tasks don't need human judgment
- [ ] Can verify programmatically (compile, test)
- [ ] Order doesn't matter much
- [ ] Can restart from any point

### 5.2 When NOT to Use

#### Anti-Pattern Scenarios

**1. Complex Design Work**
- Architecting new systems
- Making technology choices
- Creative writing/content

**2. Debugging Unknown Issues**
- Root cause analysis
- Exploratory investigation
- Performance optimization

**3. Highly Interdependent Tasks**
- Task B needs Task A's specific output
- Order is critical
- Shared state between tasks

**4. Small Task Counts**
- Less than 10 tasks
- Could be done interactively in <1 hour

#### Warning Signs Checklist

🚫 **Bad fit if:**
- [ ] Tasks are all different from each other
- [ ] Need to see intermediate results
- [ ] Requires human judgment per task
- [ ] Tasks depend on each other
- [ ] Less than 10 tasks total
- [ ] Can't easily verify success
- [ ] Context needs to accumulate

### 5.3 Cost Considerations

#### Token Math

```
Per iteration:
- Prompt: ~2,000-5,000 tokens (depends on context)
- Response: ~3,000-10,000 tokens (depends on task complexity)
- Total: ~5,000-15,000 tokens per iteration

For 50 tasks:
- Low estimate: 50 × 5,000 = 250,000 tokens
- High estimate: 50 × 15,000 = 750,000 tokens

API Cost (approximate, varies by model):
- Claude Sonnet: $3-9 per 1M tokens (input) + $15-45 per 1M (output)
- 50 tasks: $5-50 depending on complexity
```

#### ROI Calculation

```
Manual time per task: 15 minutes
50 tasks manually: 12.5 hours

Ralph Loop:
- Setup time: 1-2 hours
- Run time: 2-4 hours (unattended)
- Review time: 30 minutes
- Total human time: ~2-3 hours

Break-even: ~15-20 tasks
Clear win: 30+ tasks
```

### 5.4 Decision Checklist

```
┌─────────────────────────────────────────────────────────────┐
│               SHOULD I USE RALPH BASH LOOP?                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Task Count:                                                │
│  [ ] < 10 tasks         → NO, do manually                   │
│  [ ] 10-20 tasks        → MAYBE, depends on complexity      │
│  [ ] 20+ tasks          → YES, good candidate               │
│                                                             │
│  Task Independence:                                         │
│  [ ] Tasks depend on each other → NO                        │
│  [ ] Tasks are independent      → YES                       │
│                                                             │
│  Verification:                                              │
│  [ ] Can't verify automatically → NO                        │
│  [ ] Can compile/test/check     → YES                       │
│                                                             │
│  Judgment Required:                                         │
│  [ ] Each task needs decisions  → NO                        │
│  [ ] Tasks are mechanical       → YES                       │
│                                                             │
│  Time per Task:                                             │
│  [ ] > 30 minutes each          → MAYBE (might timeout)     │
│  [ ] 2-15 minutes each          → YES, ideal                │
│  [ ] < 2 minutes each           → NO, too simple            │
│                                                             │
│  SCORE: Count YES answers                                   │
│  4-5 YES → Strong candidate for Ralph Loop                  │
│  2-3 YES → Consider carefully, might work                   │
│  0-1 YES → Not suitable, use other approach                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Best Practices & Bad Practices

### 6.1 Best Practices

#### BP1: Perfect Context, Minimal Scope

**Principle:** Each iteration should have EVERYTHING needed for ONE task, nothing more.

```markdown
# GOOD: All context for one specific task
## Task: Create snapshot tests for ButtonView

### Component Location
Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/UIElements/ButtonView/

### Files in Folder
- ButtonView.swift
- ButtonViewModelProtocol.swift
- MockButtonViewModel.swift

### MockViewModel Presets
[actual contents of MockButtonViewModel.swift]

### Reference Implementation
[actual contents of OutcomeItemViewSnapshotTests.swift]
```

```markdown
# BAD: Vague, missing context
## Task: Create snapshot tests

Create snapshot tests for the next component that needs them.
Look at existing tests for reference.
```

#### BP2: Explicit Verification Commands

**Principle:** Tell Claude EXACTLY how to verify success.

```markdown
# GOOD: Explicit commands
## Verification (MANDATORY - DO NOT SKIP)

1. Build test target:
   ```bash
   xcodebuild build-for-testing \
     -workspace Sportsbook.xcworkspace \
     -scheme GomaUI \
     -destination 'platform=iOS Simulator,id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
   ```
   MUST exit with status 0.

2. Run the specific tests:
   ```bash
   xcodebuild test \
     -workspace Sportsbook.xcworkspace \
     -scheme GomaUI \
     -destination 'platform=iOS Simulator,id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX' \
     -only-testing:GomaUITests/ButtonViewSnapshotTests
   ```

3. Verify snapshots exist:
   ```bash
   ls Frameworks/GomaUI/GomaUI/Tests/GomaUITests/SnapshotTests/ButtonView/__Snapshots__/
   ```
   MUST show .png files (at least 2: light and dark).
```

```markdown
# BAD: Vague verification
## Verification
Make sure it compiles and the tests work.
```

#### BP3: Dynamic Resource Discovery

**Principle:** Never hardcode IDs that can change.

```bash
# GOOD: Dynamic lookup
SIMULATOR_ID=$(xcrun simctl list devices available \
  | grep -E "iPhone.*(18|19)\." \
  | head -1 \
  | grep -oE "[A-F0-9-]{36}")

if [[ -z "$SIMULATOR_ID" ]]; then
    echo "ERROR: No suitable simulator found"
    exit 1
fi
```

```bash
# BAD: Hardcoded
SIMULATOR_ID="ABC12345-1234-1234-1234-123456789ABC"
```

#### BP4: Idempotent Operations

**Principle:** Tasks should be safe to retry.

```markdown
# GOOD: Safe to retry
1. Create file (will overwrite if exists)
2. Run tests with --record (regenerates snapshots)
3. Check results
```

```markdown
# BAD: Not idempotent
1. Append to file (duplicates on retry)
2. Increment counter (wrong values on retry)
```

#### BP5: Structured Logging

**Principle:** Log everything for debugging.

```bash
# GOOD: Full logging
log "Starting iteration $iteration for $component"
echo "$context" > "$LOGS_DIR/iteration_${iteration}_prompt.md"
echo "$result" > "$LOGS_DIR/iteration_${iteration}_output.txt"
log "Completed with status: $status in ${duration}s"
```

```bash
# BAD: No logging
result=$(claude -p "$context")
# What happened? Who knows!
```

### 6.2 Bad Practices

#### BAD1: Batching Multiple Tasks

```markdown
# BAD: Multiple tasks in one iteration
Process these 5 components:
1. ButtonView
2. CapsuleView
3. PillItemView
4. IconView
5. BadgeView

# Problems:
# - Context gets muddled
# - Partial failures hard to track
# - Can't restart from middle
# - Uses more context per iteration
```

#### BAD2: Committing Inside Loop

```bash
# BAD: Commits during loop
for task in tasks; do
    claude -p "do task"
    git add -A
    git commit -m "Task: $task"  # Creates noisy history
done

# Problems:
# - 50 commits for 50 tasks
# - Hard to revert entire batch
# - Bisect becomes nightmare
```

**Better:** User commits manually after verifying all work.

#### BAD3: No Retry Limit

```bash
# BAD: Infinite retry
while ! task_succeeded; do
    claude -p "try again"
done

# Problems:
# - Infinite loop on genuinely impossible tasks
# - Burns tokens forever
# - No progress on other tasks
```

#### BAD4: Vague Success Criteria

```markdown
# BAD: Unclear when done
Make sure it works properly and looks good.
Output DONE when you think it's ready.

# Problems:
# - "Works" is subjective
# - "Looks good" is undefined
# - Claude might declare victory prematurely
```

#### BAD5: Ignoring Errors

```bash
# BAD: Suppressing errors
result=$(claude -p "..." 2>/dev/null || true)
# Just continue regardless

# Problems:
# - Hides failures
# - Tasks marked done when they failed
# - Debugging becomes impossible
```

### 6.3 Common Failure Modes

#### FM1: Premature Victory

**Symptom:** Claude outputs DONE but task isn't complete.
**Cause:** Verification step skipped or inadequate.
**Fix:** More explicit verification, require artifact proof.

#### FM2: Context Exhaustion

**Symptom:** Claude stops mid-task or gives incomplete response.
**Cause:** Too much context, task too complex.
**Fix:** Reduce context, simplify task.

#### FM3: Infinite Retry Loop

**Symptom:** Same task fails repeatedly, never skipped.
**Cause:** No max attempts limit.
**Fix:** Add attempts counter, skip after N failures.

#### FM4: Stale References

**Symptom:** Claude can't find files mentioned in prompt.
**Cause:** Hardcoded paths that changed.
**Fix:** Dynamic path discovery in context generation.

#### FM5: Silent Failures

**Symptom:** Tasks "complete" but nothing actually created.
**Cause:** Errors suppressed, no artifact verification.
**Fix:** Check for expected files, log everything.

---

## 7. Implementation Guide

### 7.1 Setting Up a Use Case

```bash
# 1. Create the directory structure
mkdir -p tools/ralph-bash-loop/use-cases/my-new-task
cd tools/ralph-bash-loop/use-cases/my-new-task

# 2. Create the required files
touch README.md      # Document your use case
touch PROMPT.md      # Claude's instructions
touch tasks.json     # Task definitions (usually generated)

# 3. Optionally create a generator script
touch generate-tasks.sh
chmod +x generate-tasks.sh
```

### 7.2 Writing an Effective PROMPT.md

**Step 1: Define the task clearly**

```markdown
# Task: Create Snapshot Tests for {COMPONENT_NAME}

You are creating snapshot tests for a GomaUI component.
```

**Step 2: Provide ALL necessary context**

```markdown
## Component Information
- Name: {COMPONENT_NAME}
- Category: {CATEGORY}
- Location: Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components/{CATEGORY}/{COMPONENT_NAME}/

## Task Details
{TASK_JSON}
```

**Step 3: Show a reference implementation**

```markdown
## Reference Implementation

Study this existing test as your pattern:

### SnapshotViewController Example
```swift
[Include actual working example code]
```

### Test File Example
```swift
[Include actual working test code]
```
```

**Step 4: List explicit steps**

```markdown
## Steps

1. Find the component folder
2. Read MockViewModel to identify test categories
3. Create SnapshotViewController at [exact path]
4. Create SnapshotTests at [exact path]
5. Run build verification
6. Run test verification
7. Check for snapshot images
```

**Step 5: Specify verification commands**

```markdown
## Verification (MANDATORY)

Execute these EXACT commands:

### Build
```bash
[exact build command]
```
Expected: Exit code 0

### Test
```bash
[exact test command]
```
Expected: Tests run (may show "Record mode")

### Artifact Check
```bash
ls [exact path to snapshots]
```
Expected: .png files exist
```

**Step 6: Define output requirements**

```markdown
## Output Requirements

At the END of your response, output EXACTLY ONE of:

- `<promise>DONE</promise>` - All verification passed
- `<promise>FAILED</promise>` - Cannot complete after trying
- `<promise>SKIP</promise>` - Task not applicable

NEVER output DONE unless verification commands succeeded.
```

### 7.3 Running the Loop

```bash
# Navigate to repo root
cd /path/to/sportsbook-ios

# Run with defaults (50 iterations, 3 attempts per task)
./tools/ralph-bash-loop/ralph.sh use-cases/gomaui-snapshot-tests

# Run with custom limits
./tools/ralph-bash-loop/ralph.sh use-cases/gomaui-snapshot-tests 100 5

# Run in background with logging
nohup ./tools/ralph-bash-loop/ralph.sh use-cases/gomaui-snapshot-tests > ralph.log 2>&1 &
```

### 7.4 Monitoring Progress

```bash
# Watch progress in real-time
tail -f tools/ralph-bash-loop/use-cases/gomaui-snapshot-tests/progress.txt

# Check remaining tasks
cat tools/ralph-bash-loop/use-cases/gomaui-snapshot-tests/tasks.json | \
  jq '[.[] | select(.passes == false)] | length'

# View specific iteration logs
cat tools/ralph-bash-loop/use-cases/gomaui-snapshot-tests/logs/iteration_5_output.txt
```

### 7.5 Handling Failures

**If a task keeps failing:**

1. Check the iteration log:
   ```bash
   cat logs/iteration_N_output.txt
   ```

2. Check the prompt that was sent:
   ```bash
   cat logs/iteration_N_prompt.md
   ```

3. Options:
   - Fix PROMPT.md and restart
   - Manually complete the task, then update tasks.json
   - Skip the task by setting `"passes": true, "skipped": true`

**If the script crashes:**

1. Check progress.txt for last completed task
2. The script will resume from first incomplete task
3. Just run again: `./ralph.sh use-cases/...`

---

## 8. CLI Reference & Troubleshooting

### 8.1 Command Line Arguments

```
Usage: ralph.sh <use-case> [max-iterations] [max-attempts]

Arguments:
  use-case        Path to use case folder (required)
                  Example: use-cases/gomaui-snapshot-tests

  max-iterations  Maximum loop iterations (default: 50)
                  One task attempt per iteration

  max-attempts    Max retries per failing task (default: 3)
                  After this many failures, task is skipped
```

### 8.2 Environment Variables

```bash
# None required, but Claude Code needs:
export ANTHROPIC_API_KEY="sk-..."

# Or be logged in via:
claude login
```

### 8.3 Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All tasks completed successfully |
| 1 | Max iterations reached with tasks remaining |
| 1 | Invalid arguments or missing files |
| 130 | Interrupted by Ctrl+C |

### 8.4 Common Issues & Solutions

**Issue: "No suitable simulator found"**
```bash
# Solution: Create a simulator
xcrun simctl create "iPhone 16 Pro" "com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro"
```

**Issue: Claude times out**
```bash
# Solution: Increase max-turns in ralph.sh
--max-turns 50  # instead of 30
```

**Issue: Tasks marked done but nothing created**
```bash
# Solution: Add artifact verification to PROMPT.md
ls [expected_file] || echo "FILE MISSING - DO NOT OUTPUT DONE"
```

**Issue: Same task fails repeatedly**
```bash
# Solution: Check logs, fix prompt, or manually skip
# To skip manually:
jq '.[0].passes = true | .[0].skipped = true' tasks.json > tmp && mv tmp tasks.json
```

---

## 9. Sources & References

### Primary Sources

1. **[Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)**
   - Anthropic Engineering Blog
   - Two-agent architecture, state persistence, verification patterns

2. **[Run Claude Code Programmatically](https://code.claude.com/docs/en/headless)**
   - Official Documentation
   - Headless mode flags, tool permissions, output formats

3. **[Claude Code: Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)**
   - Anthropic Engineering Blog
   - Fan-out pattern, pipeline integration, prompt refinement

4. **[Ralph Wiggum Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)**
   - Official Claude Code Plugin
   - Stop hook pattern, completion promises

### Additional Resources

- [Claude Code GitHub Action](https://github.com/anthropics/claude-code-action)
- [Claude Code Cheatsheet](https://awesomeclaude.ai/code-cheatsheet)
- [How I Use Every Claude Code Feature](https://blog.sshh.io/p/how-i-use-every-claude-code-feature)
- [CI/CD and Headless Mode](https://angelo-lima.fr/en/claude-code-cicd-headless-en/)

### Key Quotes

> "Finding a way for agents to quickly understand the state of work when starting with a fresh context window" - Anthropic

> "Agents work on single features sequentially, avoiding attempt to one-shot the app" - Anthropic

> "A common failure mode: marking features done without testing" - Anthropic

> "Ralph is a Bash loop - a simple while true that repeatedly feeds an AI agent a prompt file" - Geoffrey Huntley

---

## License

Internal tool - GOMA-EM iOS Team
