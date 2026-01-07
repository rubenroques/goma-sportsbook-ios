## Date
07 January 2026

### Project / Branch
sportsbook-ios / main

### Goals for this session
- Investigate Discord notification showing fewer changelog entries than CHANGELOG.yml

### Achievements
- [x] Identified root cause: bash `while read` loop dropping last line without trailing newline
- [x] Fixed `tag-release.yml` Discord notification to include all changelog lines

### Issues / Bugs Hit
- [x] Discord release notification missing 3rd changelog entry for v0.3.9(3901)
  - CHANGELOG.yml had 3 notes, Discord only showed 2
  - Classic bash gotcha: `while IFS= read -r line` exits on EOF without processing final line if no trailing newline

### Key Decisions
- Changed `printf '%s'` to `printf '%s\n'` in the truncation loop
- Minimal fix - only changed one character to solve the issue

### Experiments & Notes
- Traced issue through workflow:
  1. CHANGELOG.yml correctly has 3 entries
  2. `yq` extracts all 3 notes correctly
  3. GitHub Actions multiline output (EOF heredoc) preserves content
  4. Bug occurs in Discord step's truncation while loop at line 466
- The `read` builtin returns false on EOF even with data in buffer, causing loop to exit before processing last line

### Useful Files / Links
- [tag-release.yml](../../.github/workflows/tag-release.yml) - Line 466: the fix location
- [CHANGELOG.yml](../../BetssonCameroonApp/CHANGELOG.yml) - Source of release notes

### Next Steps
1. Commit and push fix
2. Next BCM tag release will verify fix works
