# App Store Subscription Setup Guide

## Overview
This guide will help you set up in-app subscriptions for ExamCoach on both Google Play Store and Apple App Store.

## 🤖 Google Play Store Setup

### 1. Prerequisites
- Google Play Developer account ($25 one-time fee)
- App signed and uploaded to Play Console
- Merchant account linked

### 2. Create Subscription Products

1. **Go to Play Console** → Your App → **Monetize** → **In-app products** → **Subscriptions**

2. **Create these subscription products:**

   **Basic Monthly** (ID: `examcoach_basic_monthly`)
   - Price: ₦1,000
   - Billing period: Monthly
   - Free trial: Optional (7 days recommended)
   
   **Premium Monthly** (ID: `examcoach_premium_monthly`)
   - Price: ₦2,500
   - Billing period: Monthly
   - Free trial: Optional (7 days recommended)
   
   **Premium Annual** (ID: `examcoach_premium_annual`)
   - Price: ₦20,000
   - Billing period: Yearly
   - Free trial: Optional (14 days recommended)

3. **For each subscription:**
   - Add title and description
   - Set up pricing for Nigeria (and other countries)
   - Configure grace period (recommended: 3 days)
   - Add benefits/features list

### 3. Configure Android App

Add to `android/app/build.gradle`:
```gradle
dependencies {
    implementation 'com.android.billingclient:billing:6.0.0'
}
```

Add permission in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### 4. Testing on Android
1. Upload signed APK to **Internal Testing** track
2. Add test users in Play Console
3. Test users can purchase without being charged
4. Use test cards for payment testing

## 🍎 Apple App Store Setup

### 1. Prerequisites
- Apple Developer account ($99/year)
- App uploaded to App Store Connect
- Agreements, Tax, and Banking set up

### 2. Create Subscription Products

1. **Go to App Store Connect** → Your App → **Monetization** → **In-App Purchases**

2. **Create Subscription Group:** "ExamCoach Premium"

3. **Add these auto-renewable subscriptions:**

   **Basic Monthly** (ID: `examcoach_basic_monthly`)
   - Reference Name: ExamCoach Basic Monthly
   - Product ID: examcoach_basic_monthly
   - Price: Tier 5 (₦1,000 equivalent)
   - Duration: 1 Month
   
   **Premium Monthly** (ID: `examcoach_premium_monthly`)
   - Reference Name: ExamCoach Premium Monthly
   - Product ID: examcoach_premium_monthly
   - Price: Tier 11 (₦2,500 equivalent)
   - Duration: 1 Month
   
   **Premium Annual** (ID: `examcoach_premium_annual`)
   - Reference Name: ExamCoach Premium Annual
   - Product ID: examcoach_premium_annual
   - Price: Tier 50 (₦20,000 equivalent)
   - Duration: 1 Year

4. **For each subscription:**
   - Add localized display name and description
   - Upload screenshots (required)
   - Set up introductory offers (optional)
   - Configure upgrade/downgrade paths

### 3. Configure iOS App

Add to `ios/Runner/Info.plist`:
```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

### 4. App Store Review Guidelines
- Clearly describe what users get with subscription
- Include subscription terms in app
- Provide restore purchases option
- Handle subscription management

### 5. Testing on iOS
1. Create **Sandbox Test Accounts** in App Store Connect
2. Use TestFlight for beta testing
3. Sandbox accounts can purchase without real charges
4. Subscriptions auto-renew faster in sandbox (monthly = 5 minutes)

## 🔐 Backend Receipt Verification

### Server Setup Required

Create these endpoints in your backend:

```typescript
// server/src/routes/subscriptions.ts

// Verify Google Play purchase
router.post('/verify-android', async (req, res) => {
  const { purchaseToken, productId } = req.body;
  
  // Use Google Play Developer API to verify
  // https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptions
});

// Verify App Store purchase
router.post('/verify-ios', async (req, res) => {
  const { receiptData } = req.body;
  
  // Send to Apple's verification server
  // https://developer.apple.com/documentation/appstorereceipts/verifyreceipt
});
```

### Security Best Practices
1. **NEVER trust client-side verification**
2. Always verify receipts on your server
3. Store subscription status in your database
4. Check subscription status on app launch
5. Handle subscription renewals via webhooks

## 💰 Revenue & Analytics

### Track Important Metrics
- Monthly Recurring Revenue (MRR)
- Churn rate
- Conversion rate (free to paid)
- Average Revenue Per User (ARPU)
- Lifetime Value (LTV)

### Recommended Tools
- **RevenueCat**: Simplifies subscription management
- **Amplitude**: User analytics
- **Firebase Analytics**: Free analytics

## 📱 Testing Checklist

### Before Launch
- [ ] Test purchase flow on both platforms
- [ ] Test subscription renewal
- [ ] Test upgrade/downgrade
- [ ] Test cancellation
- [ ] Test restore purchases
- [ ] Test receipt validation
- [ ] Test expired subscription handling
- [ ] Test network error handling
- [ ] Test different currencies/regions

### Common Issues & Solutions

**Issue**: Subscription not showing in app
- Check product IDs match exactly
- Ensure products are active in store
- Wait 24 hours after creating products

**Issue**: Purchase fails
- Check billing permissions
- Verify merchant account setup
- Test with sandbox/test accounts

**Issue**: Receipt validation fails
- Check server endpoints
- Verify API credentials
- Handle both production and sandbox receipts

## 🚀 Go Live Checklist

### Google Play
- [ ] Upload production APK/AAB
- [ ] Set up subscription products
- [ ] Configure pricing for all regions
- [ ] Add store listing details
- [ ] Submit for review

### App Store
- [ ] Upload production build
- [ ] Create subscription products
- [ ] Add required screenshots
- [ ] Fill in subscription descriptions
- [ ] Submit for review

### Your Backend
- [ ] Deploy receipt verification endpoints
- [ ] Set up production database
- [ ] Configure webhook endpoints
- [ ] Enable monitoring/logging
- [ ] Test with production credentials

## 📞 Support

### Handling User Issues
1. Provide clear subscription terms
2. Easy cancellation instructions
3. Contact support option
4. FAQ section

### Refund Policies
- Google Play: Users can request refunds through Play Store
- App Store: Users request through Apple
- Your policy should align with platform policies

## 🎯 Marketing Tips

1. **Free Trial**: Offer 7-14 day free trial
2. **Introductory Pricing**: Discount for first month
3. **Annual Discount**: Encourage annual subscriptions
4. **Feature Comparison**: Clear basic vs premium comparison
5. **Social Proof**: Show number of subscribers or testimonials

## 📊 Estimated Timeline

- Store account setup: 1-2 days
- Product configuration: 1 day
- Backend integration: 2-3 days
- Testing: 2-3 days
- Store review: 2-7 days (Google), 1-7 days (Apple)

**Total: 1-2 weeks from start to live**

## 💡 Pro Tips

1. Start with Google Play (easier, faster review)
2. Use promotional codes for marketing
3. A/B test pricing and trial periods
4. Monitor reviews for subscription feedback
5. Consider regional pricing strategies

---

Remember: Subscriptions are a commitment to ongoing value. Keep improving your app and adding features to reduce churn and increase retention!
