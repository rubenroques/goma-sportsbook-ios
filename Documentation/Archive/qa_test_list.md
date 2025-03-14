# QA Testing List - Generated on 2025-03-06

## Recent Changes (Last 3 Weeks)

### MixMatch as a Feature

- 8570d63c - Ruben Roques, 27 minutes ago :
   - Added case mixMatch to the SportsbookTargetFeatures enum;
   - Added .mixMatch to the features array in both UAT and PROD target variables files;
   - Updated UI components to check for the MixMatch feature:;
   - HomeViewController.swift;
   - Home screen templates (ClientManagedHomeViewTemplateDataSource, CMSManagedHomeViewTemplateDataSource, DummyWidgetShowcaseHomeViewTemplateDataSource);
   - MatchDetailsViewController.swift;
   - MarketWidgetContainerTableViewCell.swift;
   - BetBuilderBettingTicketDataSource.swift;
   - PreSubmissionBetslipViewController.swift;
   - Updated BetslipType enum to support dynamic feature toggling;
   - Updated ServicesProvider module to support MixMatch feature flag;
   - Created comprehensive documentation
- dcc2ac04 - Ruben Roques, 2 weeks ago : Added missing func from multibet

### Font Changes

- 28d0331c - Ruben Roques, 2 days ago : New font ubuntu
- 41ccef6e - Ruben Roques, 2 days ago : Merge branch 'v2_single_code' into rr/new-font

### Home Screen

- 8570d63c - Ruben Roques, 27 minutes ago : Added case mixMatch to the SportsbookTargetFeatures enum; Added .mixMatch to the features array in both UAT and PROD target variables files; Updated UI components to check for the MixMatch feature:; HomeViewController.swift; Home screen templates (ClientManagedHomeViewTemplateDataSource, CMSManagedHomeViewTemplateDataSource, DummyWidgetShowcaseHomeViewTemplateDataSource); MatchDetailsViewController.swift; MarketWidgetContainerTableViewCell.swift; BetBuilderBettingTicketDataSource.swift; PreSubmissionBetslipViewController.swift; Updated BetslipType enum to support dynamic feature toggling; Updated ServicesProvider module to support MixMatch feature flag; Created comprehensive documentation
- 9532aa8b - Ruben Roques, 22 hours ago : Top competition fixes.
- 2a18b416 - Ruben Roques, 6 days ago : feat(tests): Implement Home Template tests for GOMA Managed Content
- 378f7292 - Ruben Roques, 7 days ago : Fixed home templates. Added Unit Tests

### CMS Integration

- 0ed82ea2 - Ruben Roques, 3 days ago : Hero, ProChoices, Boosted, TopImage mapping fixes
- fbffa78f - Ruben Roques, 3 days ago : Hero pointers
- 1a79ac9f - Ruben Roques, 4 days ago : CMS prefetch
- 643791bd - Ruben Roques, 6 days ago : Merge branch 'cms_integration' into rr/prelive-vc-ui-migration
- 97f43ce1 - Ruben Roques, 6 days ago : Merge branch 'v2_single_code' into cms_integration
- c0d9003c - Ruben Roques, 6 days ago : feat(tests): Implement Pro Choices tests for GOMA Managed Content
- cd5a0c8a - Ruben Roques, 6 days ago : feat(tests): Implement News tests for GOMA Managed Content
- 9d8691b1 - Ruben Roques, 6 days ago : feat(tests): Implement Stories tests for GOMA Managed Content
- 155055a9 - Ruben Roques, 6 days ago : feat(tests): Implement Hero Cards tests for GOMA Managed Content
- d5c221ac - Ruben Roques, 6 days ago : feat(tests): Implement Boosted Odds Banners tests for GOMA Managed Content
- 3add66c1 - Ruben Roques, 6 days ago : feat(tests): Implement Sport Banners tests for GOMA Managed Content
- a09825d4 - Ruben Roques, 6 days ago : feat(tests): Implement Banners tests for GOMA Managed Content
- 99879b3f - Ruben Roques, 6 days ago : feat(tests): Implement Alert Banner tests for GOMA Managed Content
- 2a18b416 - Ruben Roques, 6 days ago : feat(tests): Implement Home Template tests for GOMA Managed Content
- 378f7292 - Ruben Roques, 7 days ago : Fixed home templates. Added Unit Tests
- dc4dbc1e - Ruben Roques, 8 days ago : CMS models and protocol WIP

### Links Management

- 7b234a4c - Ruben Roques, 10 days ago : Responsible gambling links
- 7376e021 - Ruben Roques, 12 days ago : Client oriented urls
- 9f188de3 - Ruben Roques, 13 days ago : Migrated Footer links
- 83880851 - Ruben Roques, 13 days ago : New struct logic for links
- bac5fe6c - Ruben Roques, 13 days ago : Client dynamic links

### Live Events

- 64fea0f1 - Ruben Roques, 2 days ago : LiveEvents and MatchDetails screens XML to Swift in code
- b404441a - Ruben Roques, 3 days ago : Match cells previews

### Other Changes

- a16ccc3e - Ruben Roques, 2 days ago : Fixed linting errors
- c6b1da61 - Ruben Roques, 3 days ago : generic image highlighted model
- d81e5d9e - Ruben Roques, 4 days ago : Mock goma connector
- 639ebf3e - Ruben Roques, 4 days ago : Converted ids to strings
- 29f388bd - Ruben Roques, 4 days ago : Fixed model erros and non optional values
- 2c0094c2 - Ruben Roques, 6 days ago : Removed duplicated colors
- 48b62ac6 - Ruben Roques, 6 days ago : Fixed register package merge problems
- 39bf3215 - Ruben Roques, 6 days ago : Fixed mock url protocol
- 6c3ce8cd - Ruben Roques, 6 days ago : Fixed model mapper naming
- e7313943 - Ruben Roques, 6 days ago : fixed JSONLoader.loadJSON calls
- b49fb10a - Ruben Roques, 8 days ago : Merged duplicated models
- 5d3d9b54 - Ruben Roques, 13 days ago : Merge branch 'develop' into v2_single_code
- f0436649 - Ruben Roques, 2 weeks ago : Merged SportTypes
- 8ef2302b - Ruben Roques, 2 weeks ago : Merged model mappers

### Register Flow

- a736c96e - André Lascas, 13 days ago : added register flow avatar management helper, tweaked avatar assets in different folders for different clients
- 2028ddc5 - André Lascas, 2 weeks ago : added some register flow functions tests
- 343d166e - André Lascas, 2 weeks ago : merged goma and betsson register flows
- a2c0f814 - André Lascas, 2 weeks ago : added register flow type to target variables, separated register forms for betsson and goma types, unified betsson and goma register logic (WIP)

### ServiceProvider Architecture

- e9f1e4ae - Ruben Roques, 89 minutes ago : ServiceProvider V2 config builder. Dev menu from the profile screen
- f6093570 - Ruben Roques, 20 hours ago : New ServiceProvider architecture model. Added Subsets and schemas to APIs.  See /architecture/SP_Architecture_V2.md
- cd8c1660 - Ruben Roques, 4 days ago : api client fixes

### Testing Infrastructure

- b3e705ff - Ruben Roques, 3 days ago : Mock model helper
- a428a2ba - Ruben Roques, 6 days ago : feat(tests): Add Initial Dump response for integration tests
- c2fccdfc - Ruben Roques, 6 days ago : feat(tests): Add Initial Dump endpoint to integration tests setup
- c0d9003c - Ruben Roques, 6 days ago : feat(tests): Implement Pro Choices tests for GOMA Managed Content
- cd5a0c8a - Ruben Roques, 6 days ago : feat(tests): Implement News tests for GOMA Managed Content
- 9d8691b1 - Ruben Roques, 6 days ago : feat(tests): Implement Stories tests for GOMA Managed Content
- 155055a9 - Ruben Roques, 6 days ago : feat(tests): Implement Hero Cards tests for GOMA Managed Content
- d5c221ac - Ruben Roques, 6 days ago : feat(tests): Implement Boosted Odds Banners tests for GOMA Managed Content
- 3add66c1 - Ruben Roques, 6 days ago : feat(tests): Implement Sport Banners tests for GOMA Managed Content
- a09825d4 - Ruben Roques, 6 days ago : feat(tests): Implement Banners tests for GOMA Managed Content
- 99879b3f - Ruben Roques, 6 days ago : feat(tests): Implement Alert Banner tests for GOMA Managed Content
- 2a18b416 - Ruben Roques, 6 days ago : feat(tests): Implement Home Template tests for GOMA Managed Content
- b5b41f82 - Ruben Roques, 7 days ago : feat(tests): Implement initial setup for GOMA Managed Content integration tests
- 4db8b9c0 - Ruben Roques, 7 days ago : Test Instructions
- 378f7292 - Ruben Roques, 7 days ago : Fixed home templates. Added Unit Tests
- f7886549 - Ruben Roques, 2 weeks ago : Added unit test logic for rest api subscriptions
- 2028ddc5 - André Lascas, 2 weeks ago : added some register flow functions tests
- da05882e - Ruben Roques, 2 weeks ago : added  tests helpers

### UI Migration

- 77b9b397 - Ruben Roques, 2 days ago : Merge branch 'rr/prelive-vc-ui-migration' into v2_single_code
- 01b764e3 - Ruben Roques, 3 days ago : LoadingMoreTableViewCell ui to code. SeeMoreMarketsCell ui to code
- 643791bd - Ruben Roques, 6 days ago : Merge branch 'cms_integration' into rr/prelive-vc-ui-migration

## What to Test

### Betslip

1. Test bet builder functionality
2. Verify pre-submission betslip view controller
3. Test market widget container functionality
4. Verify betslip type selection with feature flags
5. Test that betslip correctly calculates potential winnings
6. Verify that betslip correctly handles stake changes
7. Test that betslip correctly handles adding and removing selections
8. Verify that betslip correctly handles market suspensions
9. Test that betslip correctly handles odds changes
10. Verify that betslip correctly handles bet placement
11. Test that betslip correctly handles bet placement errors
12. Verify that betslip correctly handles bet placement success

### CMS Integration

1. Test CMS prefetch functionality
2. Verify Hero, ProChoices, Boosted, and TopImage mapping
3. Test Hero pointers functionality
4. Verify CMS models and protocols work correctly
5. Test home templates with CMS integration
6. Verify mock GOMA connector works for testing
7. Test Alert Banner integration with CMS
8. Verify Banners integration with CMS
9. Test Sport Banners integration with CMS
10. Verify Boosted Odds Banners integration with CMS
11. Test Hero Cards integration with CMS
12. Verify Stories integration with CMS
13. Test News integration with CMS
14. Verify Pro Choices integration with CMS
15. Test that CMS content is correctly displayed in the UI
16. Verify that CMS content is correctly updated when it changes
17. Test that CMS content is correctly cached
18. Verify that CMS content is correctly refreshed when needed

### Font Changes

1. Verify Ubuntu font is correctly applied throughout the app
2. Test font appearance on different screen sizes
3. Verify font consistency across all UI components
4. Test font appearance with different accessibility settings
5. Verify font appearance in different languages
6. Test font appearance in different themes
7. Verify font appearance with different text sizes
8. Test font appearance with different font weights

### Home Screen

1. Verify home screen templates display correctly
2. Test top competition fixes
3. Verify CMS-managed home view template data source
4. Test client-managed home view template data source
5. Verify dummy widget showcase home view template data source
6. Test that home screen correctly displays different widget types
7. Verify that home screen correctly handles widget interactions
8. Test that home screen correctly updates when content changes
9. Verify that home screen correctly handles different screen sizes
10. Test that home screen correctly handles different orientations
11. Verify that home screen correctly handles different themes
12. Test that home screen correctly handles different languages

### Links Management

1. Test responsible gambling links functionality
2. Verify client-oriented URLs work correctly
3. Test footer links
4. Verify new struct logic for links works as expected
5. Test client dynamic links with different configurations
6. Verify that links open in the correct browser or app
7. Test that links correctly handle deep linking
8. Verify that links correctly handle external URLs
9. Test that links correctly handle internal navigation
10. Verify that links correctly handle authentication requirements
11. Test that links correctly handle error cases
12. Verify that links correctly handle localization

### Live Events

1. Test live events screen functionality
2. Verify match details screen displays correctly
3. Test match cells with different states (live, upcoming, finished)
4. Verify loading more functionality in live events
5. Test that live events correctly update in real-time
6. Verify that match details correctly display statistics
7. Test that match details correctly display markets
8. Verify that match details correctly handle market updates
9. Test that match cells correctly display match information
10. Verify that match cells correctly handle state changes
11. Test that loading more correctly loads additional events
12. Verify that live events correctly handle network errors

### MixMatch Feature

1. Verify MixMatch UI elements appear when feature flag is enabled
2. Verify MixMatch UI elements are hidden when feature flag is disabled
3. Test toggling MixMatch feature flag at runtime via developer settings
4. Verify MixMatch functionality in HomeViewController
5. Verify MixMatch functionality in MatchDetailsViewController
6. Test MixMatch integration with BetslipType selection
7. Verify MixMatch mode in BetBuilderBettingTicketDataSource
8. Test MixMatch UI in PreSubmissionBetslipViewController
9. Test that BetslipType enum's availableCases property correctly filters out betBuilder when MixMatch is disabled
10. Verify that segment control initialization uses the filtered list of cases
11. Test that dynamic indices based on available cases work correctly
12. Verify that isMixMatchEnabled property is correctly set in SportRadarEventsProvider
13. Test that isMixMatchEnabled property is correctly set in BettingConnector
14. Verify that setMixMatchFeatureEnabled method works in SportRadarBettingProvider
15. Test that setMixMatchFeatureEnabled method works in Client class
16. Verify that Environment.swift correctly sets the MixMatch feature flag on the Client instance

### Other Changes

1. Verify any linting error fixes don't introduce regressions
2. Test model mapper naming fixes
3. Verify JSONLoader.loadJSON calls work correctly
4. Test any other miscellaneous changes
5. Verify that model errors and non-optional values are fixed
6. Test that duplicated colors are removed
7. Verify that register package merge problems are fixed
8. Test that mock URL protocol is fixed
9. Verify that model mapper naming is fixed
10. Test that JSONLoader.loadJSON calls are fixed
11. Verify that duplicated models are merged
12. Test that SportTypes are merged
13. Verify that missing functions from multibet are added
14. Test that model mappers are merged

### Register Flow

1. Test avatar management in register flow
2. Verify register flow works correctly for GOMA clients
3. Verify register flow works correctly for Betsson clients
4. Test register form validation for all required fields
5. Verify client-specific register form fields appear correctly
6. Test register flow with different client configurations
7. Verify that avatar assets are correctly displayed for different clients
8. Test that register flow type is correctly set in target variables
9. Verify that register forms are correctly separated for Betsson and GOMA types
10. Test that unified register logic works correctly for both Betsson and GOMA
11. Verify that register flow validation errors are displayed correctly
12. Test that register flow successfully creates a new user account
13. Verify that register flow correctly handles network errors
14. Test that register flow correctly handles validation errors
15. Verify that register flow correctly handles successful registration

### ServiceProvider Architecture

1. Verify all API endpoints work with the new ServiceProvider V2 architecture
2. Test ServiceProvider configuration builder functionality
3. Verify API subsets and schemas are correctly implemented
4. Test dev menu functionality from the profile screen
5. Verify connection state management in the new architecture
6. Test error handling in the new ServiceProvider architecture
7. Verify backward compatibility with existing code
8. Test that API client fixes resolve previous issues
9. Verify that the new architecture correctly handles authentication
10. Test that the new architecture correctly handles API responses
11. Verify that the new architecture correctly transforms API models to domain models
12. Test that the new architecture correctly handles API errors
13. Verify that the new architecture correctly handles API timeouts
14. Test that the new architecture correctly handles API retries
15. Verify that the new architecture correctly handles API cancellation

### Testing Infrastructure

1. Verify all integration tests for GOMA Managed Content
2. Test Alert Banner integration
3. Test Banners integration
4. Test Sport Banners integration
5. Test Boosted Odds Banners integration
6. Test Hero Cards integration
7. Test Stories integration
8. Test News integration
9. Test Pro Choices integration
10. Verify mock model helper functionality
11. Test Initial Dump response for integration tests
12. Verify that unit test logic for REST API subscriptions works correctly
13. Test that test helpers work correctly
14. Verify that integration tests correctly simulate API responses
15. Test that integration tests correctly validate model transformations
16. Verify that integration tests correctly validate UI updates

### UI Migration

1. Verify LiveEvents screen UI matches design specifications
2. Verify MatchDetails screen UI matches design specifications
3. Test LoadingMoreTableViewCell UI functionality
4. Test SeeMoreMarketsCell UI functionality
5. Verify match cells display correctly
6. Test generic image highlighted model functionality
7. Verify that UI components are correctly sized on different screen sizes
8. Test that UI components respond correctly to user interactions
9. Verify that UI components display correctly in different themes
10. Test that UI components display correctly in different languages
11. Verify that UI components display correctly in different orientations
12. Test that UI components display correctly with different accessibility settings

## Testing Priorities

1. **High Priority**
   - MixMatch Feature (new feature)
   - ServiceProvider Architecture (core infrastructure)

2. **Medium Priority**
   - Register Flow
   - UI Migration
   - CMS Integration

3. **Standard Priority**
   - Home Screen
   - Live Events
   - Betslip
   - Font Changes
   - Links Management

## Test Environments

### UAT Environment
- Test all features with the UAT environment configuration
- Verify that feature flags work correctly in the UAT environment
- Test with different client configurations in the UAT environment

### PROD Environment
- Verify that all features work correctly in the PROD environment
- Test with different client configurations in the PROD environment

## Device Compatibility

Test the following features on different iOS devices and versions:

1. **iPhone Models**
   - Latest iPhone models (iPhone 15 series)
   - Older iPhone models (iPhone 12/13/14 series)
   - Small screen iPhones (iPhone SE)

2. **iOS Versions**
   - Latest iOS version (iOS 17)
   - Previous iOS version (iOS 16)

## Regression Testing

In addition to testing the specific features and changes listed above, please perform regression testing on the following core functionalities:

1. **User Authentication**
   - Login with valid credentials
   - Login with invalid credentials
   - Password reset flow
   - Session management

2. **Betting Flow**
   - Adding selections to betslip
   - Modifying stake amounts
   - Placing single bets
   - Placing multiple bets
   - Cashout functionality

3. **Live Events**
   - Live event updates
   - Live statistics
   - Live market updates
   - Live event navigation

4. **Navigation**
   - Navigation between main sections
   - Deep linking
   - Back navigation
   - Tab bar navigation

5. **Promotions**
   - Promotions display
   - Promotions interaction
   - Promotions redemption
   - Promotions tracking

## Known Issues

Please be aware of the following known issues when testing:

1. None identified at this time. Please update this section if issues are discovered during testing.

## Reporting Issues

When reporting issues, please include the following information:

1. Feature area (e.g., MixMatch, ServiceProvider, etc.)
2. Test case that failed
3. Steps to reproduce
4. Expected behavior
5. Actual behavior
6. Device and iOS version
7. Screenshots or videos (if applicable)
8. Logs (if available)

