# GomaUI Snapshot Tests - Ralph Loop Use Case

Generate snapshot tests for all GomaUI components that don't have them yet.

## Usage

```bash
cd /Users/rroques/Desktop/GOMA/iOS/sportsbook-ios

# Run with 60 iterations (one component per iteration)
./tools/ralph-bash-loop/ralph.sh 60 tools/ralph-bash-loop/use-cases/gomaui-snapshot-tests/PROMPT.md
```

## How It Works

1. Each iteration, Claude reads `COMPONENT_MAP.json` to find the next component without snapshot tests
2. Claude reads ALL files for that component to understand it fully
3. Creates SnapshotViewController + SnapshotTests following the established pattern
4. Builds and runs tests to verify
5. Updates `COMPONENT_MAP.json` with `has_snapshot_tests: true`
6. Exits - loop calls again for next component

## Completion

When all components have snapshot tests, Claude outputs:
```
<promise>COMPLETE</promise>
```

And the loop exits with success.

## Monitoring

Watch the output in terminal, or for background runs:
```bash
nohup ./tools/ralph-bash-loop/ralph.sh 60 tools/ralph-bash-loop/use-cases/gomaui-snapshot-tests/PROMPT.md > ralph.log 2>&1 &
tail -f ralph.log
```

## Files

- `PROMPT.md` - Instructions for Claude (the "brain")
- `README.md` - This file

## Related

- `Frameworks/GomaUI/Documentation/Process/RALPH_SNAPSHOT_TESTS.md` - Detailed patterns
- `Frameworks/GomaUI/Documentation/Catalog/COMPONENT_MAP.json` - Task tracking
