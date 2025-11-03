# EveryMatrix Connector Refactor - LLM Implementation Guide

## For AI/LLM Implementers

This folder contains **complete, self-contained documentation** for refactoring the EveryMatrix HTTP connector architecture from 4 separate subclasses to a single unified connector with pluggable authentication strategies.

---

## 📂 Documentation Structure

```
EveryMatrixConnectorRefactor/
├── README.md                       ← You are here (start here!)
├── 00_OVERVIEW.md                  ← Architecture context and migration overview
├── PHASE_1_Auth_Strategy.md        ← Extract authentication strategy pattern
├── PHASE_2_Unified_Connector.md    ← Create unified connector
├── PHASE_3_Provider_Migration.md   ← Migrate providers to unified connector
├── PHASE_4_Legacy_Cleanup.md       ← Remove legacy code
└── TESTING_STRATEGY.md             ← Comprehensive testing guide
```

---

## 🤖 Instructions for LLM Instances

### If You're Implementing Phase 1:
1. Read `00_OVERVIEW.md` for architectural context
2. Read `PHASE_1_Auth_Strategy.md` for detailed instructions
3. All file paths, line numbers, and context are provided
4. All required reading materials are referenced
5. Testing requirements are clearly defined
6. **Do NOT read other phase documents** (stay focused)

### If You're Implementing Phase 2:
1. **Verify Phase 1 is complete** (auth strategies exist)
2. Read `00_OVERVIEW.md` for context
3. Read `PHASE_2_Unified_Connector.md` for detailed instructions
4. All dependencies from Phase 1 are documented
5. **Do NOT modify existing connectors** (additive only)

### If You're Implementing Phase 3:
1. **Verify Phases 1 & 2 are complete**
2. Read `00_OVERVIEW.md` for context
3. Read `PHASE_3_Provider_Migration.md` for migration order
4. **HIGH RISK PHASE** - follow rollout strategy carefully
5. Use feature flags for safe deployment

### If You're Implementing Phase 4:
1. **Verify Phase 3 is stable** (1 week of monitoring)
2. Read `00_OVERVIEW.md` for context
3. Read `PHASE_4_Legacy_Cleanup.md` for cleanup instructions
4. Low risk - just deleting unused code

---

## 🎯 Each Phase Document Contains

### Complete Context
- Current state of the codebase
- What problem we're solving
- Why this approach was chosen

### File References
- **Exact file paths** (absolute paths from project root)
- **Line numbers** for all code locations
- **Before/after comparisons**

### Implementation Steps
- Numbered, sequential steps
- What to create, modify, or delete
- No ambiguity or guesswork

### Testing Requirements
- Unit tests to write
- Integration tests to run
- Manual testing checklist
- Success criteria

### Rollback Strategy
- How to undo changes if issues arise
- Feature flag management
- Risk assessment

---

## 📚 Key Architectural Context

### Current Problem
- 4 nearly-identical connector subclasses
- Hardcoded Casino auth logic in base class
- Difficult to add new APIs

### Target Architecture
- 1 unified connector class
- API type enum for configuration
- Pluggable authentication strategies

### Migration Approach
- **Phases 1-2:** Additive only (no breaking changes)
- **Phase 3:** Gradual rollout with feature flags
- **Phase 4:** Cleanup after successful migration

---

## 🔑 Critical Files to Understand

### Core Connector (DO NOT BREAK)
`EveryMatrixBaseConnector.swift`
- Handles token refresh, SSE streaming, retry logic
- We wrap it, we don't replace it
- All other connectors depend on this

### Session Management (READ ONLY)
`EveryMatrixSessionCoordinator.swift`
- Stores session tokens and credentials
- Provides `publisherWithValidToken()` for auto-refresh
- Thread-safe via serial dispatch queue

### Provider Dependencies
These classes use the connectors we're refactoring:
- `EveryMatrixBettingProvider` → OddsMatrix connector
- `EveryMatrixPrivilegedAccessManager` → PlayerAPI connector
- `EveryMatrixCasinoProvider` → Casino connector
- `EveryMatrixEventsProvider` → Recsys connector

### Initialization Point
`Client.swift:73-143`
- All connectors are created here
- Feature flags will be added here in Phase 3

---

## ⚠️ Critical Warnings

### DO NOT:
- ❌ Modify `EveryMatrixBaseConnector` internal logic
- ❌ Change method signatures of public API methods
- ❌ Break the retry/token refresh mechanism
- ❌ Add code templates (LLM will generate code)
- ❌ Skip phases (must be sequential)
- ❌ Deploy without testing

### DO:
- ✅ Read all referenced files before implementing
- ✅ Follow testing requirements exactly
- ✅ Use feature flags in Phase 3
- ✅ Monitor production metrics
- ✅ Ask questions if context is unclear

---

## 🧪 Testing is Critical

### Why This Matters
- **Betting operations** = revenue-critical
- **Authentication** = blocks all user access
- **Payments** = financial transactions

### Testing Strategy
1. **Unit tests:** 100% coverage on new code
2. **Integration tests:** Real API calls in staging
3. **Manual tests:** Critical user flows
4. **Monitoring:** Production metrics during rollout

See `TESTING_STRATEGY.md` for complete details.

---

## 📊 Progress Tracking

### Phase Checklist

- [ ] **Phase 1 Complete**
  - [ ] Auth strategy protocol created
  - [ ] SessionTokenAuth implemented
  - [ ] CookieAuth implemented
  - [ ] APIKeyAuth implemented
  - [ ] Base connector updated
  - [ ] All tests pass
  - [ ] No hardcoded Casino logic remains

- [ ] **Phase 2 Complete**
  - [ ] EveryMatrixAPIType enum created
  - [ ] EveryMatrixUnifiedConnector created
  - [ ] All unit tests pass
  - [ ] Integration tests pass
  - [ ] No existing code modified

- [ ] **Phase 3 Complete**
  - [ ] Recsys migrated and stable
  - [ ] OddsMatrix migrated and stable
  - [ ] PlayerAPI migrated and stable
  - [ ] Casino migrated and stable
  - [ ] All feature flags enabled
  - [ ] 1 week of stable production

- [ ] **Phase 4 Complete**
  - [ ] Feature flags removed
  - [ ] Legacy connectors deleted
  - [ ] Type annotations updated
  - [ ] All tests still pass
  - [ ] Documentation updated

---

## 🚀 Getting Started

### Step 1: Identify Your Phase
Determine which phase you're implementing.

### Step 2: Read Overview
Read `00_OVERVIEW.md` completely for architectural context.

### Step 3: Read Phase Document
Read your specific phase document (`PHASE_X_*.md`).

### Step 4: Verify Prerequisites
Ensure previous phases are complete (if applicable).

### Step 5: Implement
Follow the numbered steps in your phase document.

### Step 6: Test
Follow the testing checklist in your phase document.

### Step 7: Verify
Check success criteria before declaring phase complete.

---

## 💡 Tips for Success

### Context is Everything
- Each document has complete context
- File paths are absolute and accurate
- Line numbers reference current codebase
- All dependencies are documented

### Stay Focused
- Only read docs for your phase
- Don't get distracted by other phases
- Trust that previous phases are correct

### Test Thoroughly
- Follow testing checklist exactly
- Don't skip manual tests
- Monitor production metrics
- Use feature flags in Phase 3

### Ask for Clarification
If something is unclear:
1. Re-read the relevant section
2. Check referenced files
3. Look for similar patterns in codebase
4. If still unclear, ask the human developer

---

## 📞 Support

### If You Encounter Issues

**During Implementation:**
- Check file references are correct
- Verify line numbers match current code
- Review "Common Pitfalls" in phase document
- Check "Common Issues & Solutions" section

**During Testing:**
- Follow rollback procedure
- Check logs for specific errors
- Compare with old connector behavior
- Verify environment configuration

**If Stuck:**
- Provide specific error message
- Include file path and line number
- Describe what you expected vs. what happened
- Human developer will assist

---

## 🎓 Learning Resources

### Understanding the Architecture

**Base Connector:**
Read `EveryMatrixBaseConnector.swift` to understand:
- Request/response handling
- Token refresh mechanism
- SSE streaming support
- Error handling

**Session Management:**
Read `EveryMatrixSessionCoordinator.swift` to understand:
- Token storage
- Credential management
- Auto-refresh logic

**Providers:**
Read provider files to understand:
- How connectors are used
- Dependency injection
- API endpoint calls

---

## 🏁 Final Notes

### This is Production Code
- Handles real money transactions
- Affects user authentication
- Impacts betting operations
- Test thoroughly before deploying

### Migration is Low-Risk
- Additive changes in Phases 1-2
- Feature flags in Phase 3 enable instant rollback
- No data migration required
- All existing functionality preserved

### You've Got This! 🚀
The documentation is comprehensive, detailed, and designed for independent LLM implementation. Follow the steps, test thoroughly, and you'll successfully refactor the connector architecture.

---

**Ready to start?** → Read `00_OVERVIEW.md` first!
