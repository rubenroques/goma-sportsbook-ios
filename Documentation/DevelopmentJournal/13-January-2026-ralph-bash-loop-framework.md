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
- [x] Built simple `ralph.sh` script (~45 lines) - keeps complexity in PROMPT.md, not bash
- [x] Created `gomaui-snapshot-tests` use case with intelligent PROMPT.md
- [x] Identified 57 GomaUI components still missing snapshot tests

### Issues / Bugs Hit
- [ ] Initial ralph.sh was over-engineered (~200 lines) - user correctly pushed back
- [ ] First PROMPT.md had too much bash micro-management - Claude Code already knows its tools

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
- `--allowedTools "Read,Write,Edit,Bash"` - Grant permissions
- `--max-turns 30` - Limit agentic iterations
- `--output-format text` - Simple output for promise checking

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
1. Test ralph.sh with the gomaui-snapshot-tests use case
2. Run a few iterations to validate PROMPT.md quality
3. Refine PROMPT.md based on Claude's actual behavior
4. Complete snapshot tests for remaining 57 components
5. Consider additional use cases (documentation generation, migrations)
