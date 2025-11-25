## Date
25 November 2025

### Project / Branch
sportsbook-ios / rr/boot_performance

### Goals for this session
- Review MVVM.md documentation against standard MVVM-C guidelines
- Fix identified violations of MVVM-C architecture patterns

### Achievements
- [x] Reviewed full MVVM.md document (628 lines)
- [x] Fixed Core Principle misstatement - changed "ViewControllers are coordinators" to proper MVVM-C principle
- [x] Rewrote ViewController responsibilities section to emphasize DI and no navigation handling
- [x] Removed misleading "Without Coordinators" section that contradicted MVVM-C
- [x] Added Coordinator Protocol Definition with `childDidFinish()` for proper cleanup
- [x] Rewrote Coordinator examples to show ViewModel Combine publishers pattern
- [x] Added explicit DON'T examples for anti-patterns (VC creating VMs, VC handling navigation)
- [x] Added alternative callback pattern section for simpler cases

### Issues / Bugs Hit
- None - documentation-only changes

### Key Decisions
- Removed "Without Coordinators" section entirely rather than deprecating it - contradicted the MVVM-C pattern the project uses
- Recommended Combine publishers on ViewModel as preferred pattern over VC callbacks for complex flows
- Added Coordinator protocol definition that was previously missing

### Experiments & Notes
- Document was well-structured but had fundamental contradictions with MVVM-C principles
- Main issues were around ViewController responsibilities being conflated with Coordinator responsibilities

### Useful Files / Links
- [MVVM.md](../../Documentation/Core/MVVM.md) - The updated documentation file
- [CLAUDE.md](../../CLAUDE.md) - Project architecture reference

### Next Steps
1. Consider adding ViewModel protocol pattern section (issue #5 not addressed)
2. Consider adding more examples from actual BetssonCameroonApp code
3. Review other documentation files for MVVM-C consistency
