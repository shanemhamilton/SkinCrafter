# App Store Submission Checklist

## Pre-Submission Requirements

### ✅ App Configuration
- [x] Bundle ID: `com.inertu.MySkinCraft`
- [x] SKU: `SkinCrafter`
- [x] Apple ID: `6751650379`
- [x] Version: 1.0.0
- [x] Build: 1
- [x] Minimum iOS: 16.0
- [x] Device Family: iPhone, iPad

### ✅ Certificates & Profiles
- [ ] Development Certificate
- [ ] Distribution Certificate
- [ ] App Store Provisioning Profile
- [ ] Push Notification Certificate (if needed)

### ✅ App Icons
Need to create 1024x1024 App Store icon and all required sizes:
```bash
# iPhone Icons
20pt (2x, 3x) - 40x40, 60x60
29pt (2x, 3x) - 58x58, 87x87
40pt (2x, 3x) - 80x80, 120x120
60pt (2x, 3x) - 120x120, 180x180

# iPad Icons
20pt (1x, 2x) - 20x20, 40x40
29pt (1x, 2x) - 29x29, 58x58
40pt (1x, 2x) - 40x40, 80x80
76pt (1x, 2x) - 76x76, 152x152
83.5pt (2x) - 167x167

# App Store
1024pt (1x) - 1024x1024
```

### ✅ Screenshots
Required for each device size:
- [ ] iPhone 6.7" (1290 × 2796) - 5 screenshots
- [ ] iPhone 6.5" (1242 × 2688) - 5 screenshots  
- [ ] iPhone 5.5" (1242 × 2208) - 5 screenshots
- [ ] iPad Pro 12.9" (2048 × 2732) - 5 screenshots

### ✅ In-App Purchases Configuration
Configure in App Store Connect:
1. Remove Ads - $2.99
2. Pro Tools Pack - $4.99
3. Premium Templates - $1.99
4. Unlimited Palettes - $1.99

### ✅ Testing Checklist
- [ ] Test on real iPhone
- [ ] Test on real iPad
- [ ] Test all export options
- [ ] Test in-app purchases in sandbox
- [ ] Test with no network connection
- [ ] Test memory usage with large edits
- [ ] Test all drawing tools
- [ ] Test undo/redo system
- [ ] Verify COPPA compliance
- [ ] Check for crashes

### ✅ Legal Documents
- [x] Privacy Policy URL needed
- [x] Terms of Service URL needed
- [x] COPPA compliance statement
- [ ] Host documents on website

### ✅ App Store Connect Setup

#### Localizable Information
- [x] App Name: SkinCrafter
- [x] Subtitle: Pro Minecraft Skin Editor
- [x] Keywords (100 chars max)
- [x] Description (4000 chars max)
- [x] Promotional Text (170 chars max)
- [x] What's New

#### Categories
- [x] Primary: Entertainment
- [x] Secondary: Graphics & Design

#### Age Rating
- [x] 4+ (Made for Kids)
- [x] No objectionable content
- [x] COPPA compliant

#### Content Rights
- [x] No third-party content
- [x] Original templates
- [x] User-generated content only

## Build & Upload Process

### 1. Update Version Numbers
```bash
# In Xcode project settings
CFBundleShortVersionString: 1.0.0
CFBundleVersion: 1
```

### 2. Archive Build
```bash
1. Select "Any iOS Device" as destination
2. Product → Archive
3. Wait for archive to complete
```

### 3. Upload to App Store Connect
```bash
1. Window → Organizer
2. Select archive
3. Distribute App
4. App Store Connect
5. Upload
```

### 4. Configure in App Store Connect
1. Add build to version
2. Fill in all metadata
3. Upload screenshots
4. Submit for review

## Review Guidelines Compliance

### ✅ 1.3 Kids Category
- Age-appropriate content
- No inappropriate user-generated content
- Parental gate for purchases
- COPPA compliant

### ✅ 2.1 App Completeness
- No placeholder content
- All features functional
- No crashes or bugs

### ✅ 2.3 Accurate Metadata
- Screenshots show actual app
- Description matches functionality
- Age rating appropriate

### ✅ 3.1 Payments
- In-app purchases properly configured
- Restore purchases functionality
- Clear pricing information

### ✅ 4.0 Design
- Native iOS design
- Intuitive interface
- Appropriate for kids

### ✅ 5.1 Privacy
- Privacy policy required
- COPPA compliance
- No personal data collection

## Common Rejection Reasons to Avoid

1. **Metadata Issues**
   - Keywords stuffing
   - Misleading screenshots
   - Incorrect age rating

2. **Kids Category**
   - Inappropriate ads
   - No parental controls
   - Data collection

3. **Minecraft References**
   - Don't claim official partnership
   - Include disclaimer
   - Respect trademarks

4. **Technical Issues**
   - Crashes on launch
   - Features not working
   - Poor performance

## Post-Submission

### Monitor Review Status
- Expect 24-48 hour initial review
- Respond quickly to reviewer questions
- Be prepared to make changes

### Launch Plan
1. Announce on social media
2. Contact Minecraft YouTubers
3. Submit to app review sites
4. Run launch promotion

### Version 1.1 Planning
- Bug fixes from user feedback
- Additional templates
- Performance improvements
- Localization

## Emergency Contacts

### App Review Support
- Phone: 1-800-633-2152
- Form: https://developer.apple.com/contact/app-store/

### Resolution Center
- Check daily during review
- Respond within 24 hours

## Final Checks Before Submit

- [ ] Test build on TestFlight
- [ ] All metadata complete
- [ ] Screenshots uploaded
- [ ] In-app purchases tested
- [ ] Privacy policy live
- [ ] Support URL working
- [ ] No test data in build
- [ ] Production AdMob IDs
- [ ] Version number correct
- [ ] Build uploaded successfully

## Notes for Reviewer

```
SkinCrafter is a kid-safe creative tool for making character skins compatible with 
popular games including Minecraft and others.

Key Points:
• COPPA compliant - no data collection
• Contextual ads only (Google AdMob with child-directed treatment)
• No social features or accounts
• All content created by users or from templates
• Exports standard PNG files compatible with various games
• In-app purchases use parental gate
• Not affiliated with any game companies
• Generic pixel art editor with game-compatible export formats

The app includes both a simple mode for kids and a professional mode for advanced users.
All features have been tested extensively on iPhone and iPad devices.

Test credentials: Not required (no account system)

Note: While compatible with Minecraft and other games, this is an independent tool.
All trademarks belong to their respective owners.
```

## Ready to Submit?

Once all items are checked:
1. Click "Add for Review"
2. Answer export compliance questions
3. Select automatic or manual release
4. Submit for Review

Good luck! 🚀