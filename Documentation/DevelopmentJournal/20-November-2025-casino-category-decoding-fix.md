## Date
20 November 2025

### Project / Branch
sportsbook-ios / rr/match_details_score

### Goals for this session
- Debug EveryMatrix Casino API decoding errors appearing in Xcode logs
- Fix FailableDecodable errors for category items

### Achievements
- [x] Identified root cause: API inconsistency between tags and categories structure
- [x] Fixed `CasinoGameCategoryItem` model to match actual API response
- [x] Made `href` field optional and added required `id` and `name` fields
- [x] Eliminated all "keyNotFound" decoding errors for casino games

### Issues / Bugs Hit
- [x] EveryMatrix Casino API returns categories without `href` field (unlike tags)
- [x] Model assumed categories had same structure as tags (incorrect assumption)

### Key Decisions
- Made `href` optional in `CasinoGameCategoryItem` since API doesn't always provide it
- Added `id` and `name` fields to match actual API response structure
- Categories and tags have different structures despite being similar collections

### Experiments & Notes
- Analyzed API response: 33 casino games returned successfully (200 OK)
- FailableDecodable wrapper was catching errors, preventing crashes but losing category data
- API structure comparison:
  - **Tags**: `{ href, id, name }` - includes href
  - **Categories**: `{ id, name }` - no href field
- All 33 games were failing to decode categories before the fix

### Useful Files / Links
- [EveryMatrix+CasinoGame.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Models/REST/Casino/EveryMatrix+CasinoGame.swift)
- [EveryMatrix CLAUDE.md](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/CLAUDE.md)
- [Casino API Documentation](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Providers/Everymatrix/Documentation/everymatrix_docs.md)

### Next Steps
1. Test casino games list to verify categories now decode correctly
2. Verify UI displays category information properly
3. Consider adding similar fixes if other nested objects have optional fields
