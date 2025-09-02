# SkinCrafter API Integration Guide

## Overview
This document outlines all external APIs and services that need to be integrated for the SkinCrafter app to be fully functional in production.

## Required Integrations

### 1. Google AdMob (COPPA-Compliant)
**Status:** Partially Implemented  
**Priority:** High  
**Files:** `SkinCrafter/Services/AdManager.swift`

#### Setup Required:
1. Create AdMob account
2. Register app and get production App ID
3. Replace test IDs with production IDs:
   ```swift
   // Current (Test)
   let appId = "ca-app-pub-3940256099942544~1458002511"
   
   // Production (needs replacement)
   let appId = "YOUR_PRODUCTION_APP_ID"
   ```

#### COPPA Configuration:
- Child-directed ads: **ENABLED**
- Personalized ads: **DISABLED**
- Age gate: **REQUIRED**

### 2. CocoaPods Dependencies
**Status:** Not Installed  
**Priority:** Critical  

#### Required Pods:
```ruby
# Podfile
platform :ios, '16.0'

target 'SkinCrafter' do
  use_frameworks!
  
  # Google Mobile Ads (COPPA-compliant version)
  pod 'Google-Mobile-Ads-SDK', '~> 11.0'
  
  # Analytics (optional, COPPA-compliant)
  # pod 'Firebase/Analytics'
  
  # In-App Purchases
  # pod 'SwiftyStoreKit'
end
```

#### Installation:
```bash
# Install CocoaPods
sudo gem install cocoapods

# Install dependencies
pod install

# Always open .xcworkspace after pod install
open SkinCrafter.xcworkspace
```

### 3. Minecraft Integration
**Status:** Placeholder  
**Priority:** Medium  
**Files:** `SkinCrafter/Services/ExportManager.swift`

#### URL Schemes Required:
```xml
<!-- Info.plist -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>minecraft</string>
    <string>minecraftedu</string>
</array>
```

#### Deep Link Format:
```swift
// Minecraft skin import
let minecraftURL = "minecraft://import/skin?url=\(encodedSkinURL)"

// Minecraft Education Edition
let eduURL = "minecraftedu://import/skin?url=\(encodedSkinURL)"
```

### 4. iCloud Storage (Optional)
**Status:** Not Implemented  
**Priority:** Low  
**Purpose:** Sync skins across devices

#### Capabilities Required:
- iCloud Documents
- CloudKit

#### Implementation:
```swift
// Enable in Signing & Capabilities
// Add iCloud container
// Use NSUbiquitousKeyValueStore for preferences
// Use Document-based storage for skins
```

### 5. Analytics Service
**Status:** Implemented (Local Only)  
**Priority:** Medium  
**Files:** `SkinCrafter/Services/AnalyticsManager.swift`

#### Current Implementation:
- Session-only analytics
- No personal data collection
- COPPA-compliant

#### Production Options:
1. **Firebase Analytics (COPPA Mode)**
   - Disable advertising features
   - No demographic collection
   - Events only

2. **Custom Backend**
   - Anonymous event tracking
   - Age-appropriate metrics
   - No PII collection

### 6. In-App Purchases
**Status:** Placeholder  
**Priority:** Medium  
**Files:** `SkinCrafter/Services/PurchaseManager.swift`

#### Products to Configure:
```swift
enum Product: String {
    case removeAds = "com.skincrafter.removeads"
    case proMode = "com.skincrafter.promode"
    case templatePack1 = "com.skincrafter.templates.pack1"
    case templatePack2 = "com.skincrafter.templates.pack2"
}
```

#### App Store Connect Setup:
1. Create IAP products
2. Set up pricing tiers
3. Add product descriptions
4. Submit for review

### 7. Push Notifications (Optional)
**Status:** Not Implemented  
**Priority:** Low  
**Purpose:** Feature updates, new templates

#### Requirements:
- APNS certificate
- Notification permission request
- Parent consent for users under 13

## Environment Configuration

### Development
```swift
struct Environment {
    static let isDevelopment = true
    static let adMobAppId = "ca-app-pub-3940256099942544~1458002511"
    static let analyticsEnabled = false
    static let iapEnabled = false
}
```

### Production
```swift
struct Environment {
    static let isDevelopment = false
    static let adMobAppId = "YOUR_PRODUCTION_APP_ID"
    static let analyticsEnabled = true
    static let iapEnabled = true
}
```

## Privacy & Compliance

### Required Privacy Labels (App Store)
- **Data Not Collected** (if no analytics)
- **Data Not Linked to You** (if anonymous analytics)

### COPPA Compliance Checklist
- [x] No personal data collection under 13
- [x] Parent gate for external links
- [x] Age-appropriate content only
- [x] No social features without consent
- [x] Child-directed ad settings
- [ ] Privacy policy URL (required)
- [ ] Terms of service URL (optional)

### Privacy Policy Requirements
Must include:
- What data is collected (none for under 13)
- How data is used (app functionality only)
- COPPA compliance statement
- Contact information
- Data retention policy

## Testing Checklist

### Before Release
- [ ] Replace all test API keys with production
- [ ] Verify COPPA settings in AdMob console
- [ ] Test IAP in sandbox environment
- [ ] Verify Minecraft URL scheme works
- [ ] Test on iOS 16.0+ devices
- [ ] Submit privacy policy to App Store

### API Response Testing
```swift
// Test ad loading
AdManager.shared.loadBannerAd { success in
    print("Ad loaded: \(success)")
}

// Test IAP
PurchaseManager.shared.purchase(.removeAds) { success in
    print("Purchase successful: \(success)")
}

// Test export
ExportManager.shared.exportToMinecraft(skin) { success in
    print("Export successful: \(success)")
}
```

## Support Contacts

### Google AdMob
- Support: https://support.google.com/admob
- COPPA Guide: https://support.google.com/admob/answer/9528171

### Apple Developer
- App Store Connect: https://appstoreconnect.apple.com
- IAP Guide: https://developer.apple.com/in-app-purchase/

### Minecraft
- Developer Portal: https://developer.minecraft.net
- URL Schemes: Community-maintained

## Next Steps

1. **Immediate (Before Testing)**
   - Install CocoaPods
   - Run `pod install`
   - Add Google-Mobile-Ads-SDK

2. **Before Beta**
   - Create AdMob account
   - Get production ad unit IDs
   - Write privacy policy
   - Configure IAP products

3. **Before Release**
   - Replace all test IDs
   - Submit for App Store review
   - Verify COPPA compliance
   - Test all integrations

## Error Handling

All API integrations should handle failures gracefully:

```swift
// Example error handling pattern
func callAPI() {
    apiService.request { result in
        switch result {
        case .success(let data):
            // Handle success
            break
        case .failure(let error):
            // Log error (no PII)
            AnalyticsManager.shared.logError(error.code)
            // Show user-friendly message
            showAlert("Something went wrong. Please try again!")
        }
    }
}
```

## Notes

- All external services must be COPPA-compliant
- No third-party SDKs that collect personal data
- Prefer Apple's native frameworks where possible
- Test thoroughly with parental controls enabled
- Document all data flows for privacy review