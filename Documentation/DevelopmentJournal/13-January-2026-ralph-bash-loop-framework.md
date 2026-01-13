## Date
13 January 2026

### Project / Branch
sportsbook-ios / wip/manual-distribute-refactor

### Goals for this session
- Research Claude Code headless mode and bash loop patterns
- Understand Anthropic's "Effective Harnesses for Long-Running Agents" approach
- Compare Ralph Wiggum plugin vs custom bash loops
- Create a reusable Ralph Bash Loop framework for iterative Claude Code tasks
- Set up first use case: GomaUI snapshot test generation

### Achievements
- [x] Deep research on Claude Code headless mode (`-p` flag, `--allowedTools`, `--output-format`)
- [x] Analyzed Anthropic's two-agent architecture pattern (initializer + worker)
- [x] Compared Ralph Wiggum plugin vs external bash control
- [x] Created `tools/ralph-bash-loop/` framework with comprehensive README (~1000 lines)
- [x] Built simple `ralph.sh` script (~60 lines) - keeps complexity in PROMPT.md, not bash
- [x] Created `gomaui-snapshot-tests` use case with intelligent PROMPT.md
- [x] Identified 57 GomaUI components still missing snapshot tests
- [x] Debugged and fixed silent hanging issue (tee for streaming output)
- [x] Discovered and fixed permission issue (`--dangerously-skip-permissions`)
- [x] Added async rendering workaround guidance to PROMPT.md
- [x] Successfully started ralph loop - generating snapshot tests autonomously

### Issues / Bugs Hit
- [x] Initial ralph.sh was over-engineered (~200 lines) - user correctly pushed back → simplified to ~60 lines
- [x] First PROMPT.md had too much bash micro-management - Claude Code already knows its tools → removed explicit bash commands
- [x] Script hung for 28 minutes with no output - `result=$(claude ...)` captures silently → fixed with `tee` to stream AND capture
- [x] **Critical:** Headless mode needs permissions! No interactive UI to click "allow" → added `--dangerously-skip-permissions`
- [x] Missing async rendering workaround in PROMPT.md → added `SnapshotTestConfig.waitForCombineRendering(vc)` guidance

### Key Decisions
- **Simple bash loop, smart prompt** - Keep ralph.sh minimal (~45 lines), put all intelligence in PROMPT.md
- **No commits during loop** - User commits manually after verifying all work
- **One task per iteration** - Fresh context each time, no batching
- **External state via files** - Use COMPONENT_MAP.json as source of truth, not session memory
- **Completion promises** - `<promise>COMPLETE</promise>` signals all tasks done
- **Trust Claude's tools** - Don't spell out every `cat` and `ls` command

### Experiments & Notes

**Key insight from Anthropic:**
> "Finding a way for agents to quickly understand the state of work when starting with a fresh context window" - this is the core problem Ralph Loop solves

**Ralph Wiggum Plugin vs Bash Loop:**
| Aspect | Plugin | Bash Loop |
|--------|--------|-----------|
| Context | Accumulates (can exhaust) | Fresh each iteration |
| State | Session memory | External files |
| Control | Inside Claude | Outside, bash controls |

**Headless Mode Key Flags:**
- `-p "prompt"` - Run non-interactively
- `--dangerously-skip-permissions` - **REQUIRED** - No UI to grant permissions in headless mode
- `--allowedTools "Read,Write,Edit,Bash"` - Alternative to skip-permissions (more granular)
- `--max-turns 30` - Limit agentic iterations
- `--output-format text` - Simple output for promise checking

**Debugging Discovery:**
Headless mode with `result=$(claude -p "...")` captures output silently - user sees nothing for 30+ minutes. Fixed with:
```bash
claude -p "..." 2>&1 | tee "$TEMP_OUTPUT"  # Stream AND capture
result=$(cat "$TEMP_OUTPUT")               # Then read for promise check
```

**Async Rendering in Snapshot Tests:**
Some GomaUI components use Combine with `.receive(on: DispatchQueue.main)` causing async rendering. Snapshots capture empty views because render happens on next run loop. Solution:
```swift
SnapshotTestConfig.waitForCombineRendering(vc)  // Flushes RunLoop before snapshot
```
See `Frameworks/GomaUI/Documentation/Guides/SNAPSHOT_TESTING.md` for full details.

### Useful Files / Links

**Created this session:**
- [Ralph Bash Loop README](../../tools/ralph-bash-loop/README.md) - Comprehensive guide with research
- [ralph.sh](../../tools/ralph-bash-loop/ralph.sh) - Simple loop script
- [GomaUI Snapshot Tests PROMPT.md](../../tools/ralph-bash-loop/use-cases/gomaui-snapshot-tests/PROMPT.md)

**Reference sources:**
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Code Headless Mode Docs](https://code.claude.com/docs/en/headless)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Ralph Wiggum Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)

**Existing project files:**
- [RALPH_SNAPSHOT_TESTS.md](../../Frameworks/GomaUI/Documentation/Process/RALPH_SNAPSHOT_TESTS.md) - Detailed snapshot test patterns
- [COMPONENT_MAP.json](../../Frameworks/GomaUI/Documentation/Catalog/COMPONENT_MAP.json) - Task tracking for components

### Next Steps
1. ~~Test ralph.sh with the gomaui-snapshot-tests use case~~ ✓ Working after permission fix
2. Monitor current ralph loop run for quality of generated tests
3. Review generated snapshot tests for correctness
4. Complete snapshot tests for remaining ~57 components
5. Consider additional use cases (documentation generation, migrations)

### Session Commands
```bash
# Run the ralph loop (from repo root)
./tools/ralph-bash-loop/ralph.sh 60 tools/ralph-bash-loop/use-cases/gomaui-snapshot-tests/PROMPT.md

# Check progress
cat Frameworks/GomaUI/Documentation/Catalog/COMPONENT_MAP.json | jq '[.[] | select(.has_snapshot_tests == false)] | length'
```
