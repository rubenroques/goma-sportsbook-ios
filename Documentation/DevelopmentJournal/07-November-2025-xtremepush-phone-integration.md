## Date
07 November 2025

### Project / Branch
BetssonCameroonApp / betsson-cm

### Goals for this session
- Integrate XtremePush SDK to send phone number as user identifier on login
- Implement proper user tracking for push notifications
- Handle logout flow for XtremePush

### Achievements
- [x] Added XPush import to UserSessionStore.swift
- [x] Created XtremePush extension with 3 helper methods:
  - `setXtremePushUser(from:)` - Sets user with phone number extraction
  - `clearXtremePushUser()` - Clears user on logout
  - `extractPhoneNumber(from:)` - Smart phone extraction with fallback chain
- [x] Integrated login flow to set XtremePush user after successful authentication
- [x] Added comprehensive debug logging for phone number extraction
- [x] Applied changes to both CoreMasterAggregator and sportsbook-ios branches

### Issues / Bugs Hit
- [x] ⚠️ **CRITICAL**: XtremePush team instructed NOT to clear user on logout
  - This creates security, privacy, and GDPR issues
  - Commented out `clearXtremePushUser()` call per client request
  - Added extensive warning documentation in code

### Key Decisions
- **Phone Number Extraction Priority:**
  1. `username` field (contains full phone with country code: "+237699198921")
  2. `mobileCountryCode` + `mobilePhone` (construct from parts)
  3. `phoneNumber` field (usually empty in actual data)
  4. Fallback to `userIdentifier` if no phone available

- **Logout Behavior (CONTROVERSIAL):**
  - **Decided**: Do NOT clear XtremePush user on logout (per XtremePush/client request)
  - **Risk**: Users will receive push notifications after logout
  - **Risk**: Cross-user notification leaks on shared devices
  - **Risk**: GDPR/privacy violation
  - **Documentation**: Added 21-line warning comment explaining all risks
  - **Technical Debt**: Marked as HIGH PRIORITY for future review

### Experiments & Notes
- Analyzed actual UserProfile data from debugger:
  ```
  username: "+237699198921"           ✅ Full phone number
  phoneNumber: Optional("")           ❌ Empty string
  mobilePhone: Optional("699198921")  ✅ Local number
  mobileCountryCode: Optional("+237") ✅ Country code
  ```
- Phone extraction works correctly using username as primary source
- Debug logs show proper extraction: "[XTREMEPUSH] 📞 Setting user identifier: +237699198921"

### Useful Files / Links
- [UserSessionStore.swift](../../BetssonCameroonApp/App/Services/UserSessionStore.swift) - Main implementation
- [UserProfile.swift](../../Frameworks/ServicesProvider/Sources/ServicesProvider/Models/User/User.swift) - Data model
- [AnalyticsClient.swift](../../BetssonCameroonApp/App/Helpers/AnalyticsClient.swift) - XPush analytics integration
- [AppDelegate.swift](../../BetssonCameroonApp/App/Boot/AppDelegate.swift) - XPush initialization

### Code Implementation Details

**Extension Added (lines 450-510):**
```swift
// MARK: - XtremePush Integration
extension UserSessionStore {
    private func setXtremePushUser(from profile: UserProfile)
    private func clearXtremePushUser()
    private func extractPhoneNumber(from profile: UserProfile) -> String
}
```

**Login Integration (line 206):**
```swift
.handleEvents(receiveOutput: { [weak self] session, profile in
    // ... existing code ...
    self?.setXtremePushUser(from: profile)  // ✅ Added
})
```

**Logout Integration (line 161-181):**
```swift
// ⚠️ CRITICAL SECURITY & PRIVACY ISSUE - COMMENTED OUT PER CLIENT REQUEST
// self.clearXtremePushUser()  // ❌ Commented out (against best practices)
```

### Security & Privacy Concerns (DOCUMENTED)

**5 Critical Issues with Current Implementation:**
1. **Privacy Violation**: Logged-out users receive notifications with sensitive betting/financial info
2. **Wrong User Notifications**: New user on device gets previous user's notifications
3. **GDPR/Data Protection**: User explicitly logged out but still tracked
4. **User Experience**: Confusing notifications after logout
5. **Security**: Sensitive info leaks to unauthorized device users

**Scenarios That Will Cause Problems:**
- Family sharing iPad: Dad's betting notifications go to son's device
- Internet café shared devices: User A's deposit notifications after User B logs in
- GDPR complaints: Non-consensual tracking after explicit logout

### Next Steps
1. **Monitor production**: Watch for user complaints about wrong notifications
2. **Prepare evidence**: Keep documentation of client decision for liability protection
3. **Revisit with stakeholders**: Push back on logout behavior when issues arise
4. **Test edge cases**: Verify phone extraction works across all user types
5. **Update Android/Web**: Ensure consistent behavior across platforms
6. **GDPR Review**: Legal team should review logout behavior compliance
