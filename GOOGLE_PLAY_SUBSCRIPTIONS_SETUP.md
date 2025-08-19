# Google Play Store Subscription Setup Guide for ExamCoach

## Overview
This guide ensures your ExamCoach app's subscription functionality will work correctly when published to Google Play Store.

## Current Implementation Status ✅

### 1. **Flutter App Configuration**
- ✅ `in_app_purchase` package is installed (v3.2.0)
- ✅ Android-specific package configured (`in_app_purchase_android`)
- ✅ SubscriptionService implemented with Google Play support
- ✅ Three subscription tiers defined:
  - `examcoach_basic_monthly` - Basic Monthly Plan
  - `examcoach_premium_monthly` - Premium Monthly Plan
  - `examcoach_premium_annual` - Premium Annual Plan

### 2. **Key Features Implemented**
- ✅ Product loading from Google Play Store
- ✅ Purchase flow with Google Play Billing
- ✅ Subscription upgrade/downgrade handling
- ✅ Purchase restoration
- ✅ Receipt handling structure

## Required Setup Steps Before Publishing

### 1. **Update Application ID** 🔴
Your app currently uses the default package name. You MUST change this:

**File:** `/app/android/app/build.gradle.kts`
```kotlin
defaultConfig {
    applicationId = "com.yourcompany.examcoach"  // Change from com.example.examcoach_app
    minSdk = 21  // Minimum for Google Play Billing
    targetSdk = 34
    versionCode = 1
    versionName = "1.0.0"
}
```

### 2. **Google Play Console Setup** 🔴

#### A. Create App in Google Play Console
1. Go to [Google Play Console](https://play.google.com/console)
2. Create a new app
3. Fill in app details (name, description, category)
4. Set up content rating
5. Upload app icon and screenshots

#### B. Configure In-App Products
1. Navigate to **Monetization > In-app products**
2. Create exactly these subscription products:

**Basic Monthly Subscription:**
- Product ID: `examcoach_basic_monthly`
- Name: "ExamCoach Basic - Monthly"
- Price: Set your price (e.g., $4.99/month)
- Billing period: Monthly
- Features:
  - Access to practice questions
  - Basic explanations
  - Progress tracking

**Premium Monthly Subscription:**
- Product ID: `examcoach_premium_monthly`
- Name: "ExamCoach Premium - Monthly"
- Price: Set your price (e.g., $9.99/month)
- Billing period: Monthly
- Features:
  - All Basic features
  - Detailed explanations
  - Mock exams
  - Performance analytics
  - Priority support

**Premium Annual Subscription:**
- Product ID: `examcoach_premium_annual`
- Name: "ExamCoach Premium - Annual"
- Price: Set your price (e.g., $79.99/year)
- Billing period: Yearly
- Features:
  - All Premium features
  - Save 33% compared to monthly
  - Early access to new features

### 3. **Add App Signing** 🔴

Create a keystore for production releases:

```bash
keytool -genkey -v -keystore ~/examcoach-release.keystore \
  -alias examcoach -keyalg RSA -keysize 2048 -validity 10000
```

Update `/app/android/app/build.gradle.kts`:
```kotlin
android {
    signingConfigs {
        create("release") {
            keyAlias = "examcoach"
            keyPassword = System.getenv("KEY_PASSWORD")
            storeFile = file(System.getenv("KEY_STORE_FILE"))
            storePassword = System.getenv("KEY_STORE_PASSWORD")
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            minifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}
```

### 4. **Backend Receipt Verification** 🔴 CRITICAL

**Security Warning:** The app currently accepts all purchases without verification. You MUST implement server-side verification before production.

Create this endpoint in your backend (`server/src/routes/subscriptions.ts`):

```typescript
import { Router } from 'express';
import { google } from 'googleapis';

const router = Router();

// Google Play API setup
const auth = new google.auth.GoogleAuth({
  keyFile: 'path/to/service-account-key.json',
  scopes: ['https://www.googleapis.com/auth/androidpublisher'],
});

const androidPublisher = google.androidpublisher({
  version: 'v3',
  auth,
});

router.post('/api/subscriptions/verify-receipt', async (req, res) => {
  const { productId, purchaseToken, packageName } = req.body;
  
  try {
    // Verify with Google Play API
    const response = await androidPublisher.purchases.subscriptions.get({
      packageName: packageName || 'com.yourcompany.examcoach',
      subscriptionId: productId,
      token: purchaseToken,
    });
    
    const subscription = response.data;
    
    // Check if subscription is valid
    if (subscription.paymentState === 1) { // Payment received
      // Save to database
      await saveSubscription({
        userId: req.user.id,
        productId,
        expiryTimeMillis: subscription.expiryTimeMillis,
        orderId: subscription.orderId,
      });
      
      return res.json({
        valid: true,
        expiryDate: new Date(parseInt(subscription.expiryTimeMillis)),
      });
    }
    
    return res.json({ valid: false });
  } catch (error) {
    console.error('Receipt verification failed:', error);
    return res.status(400).json({ valid: false, error: 'Verification failed' });
  }
});
```

Then update `app/lib/services/subscription_service.dart` line 222-227:
```dart
final response = await http.post(
  Uri.parse('http://your-backend.com/api/subscriptions/verify-receipt'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(receiptData),
);
return response.statusCode == 200 && jsonDecode(response.body)['valid'] == true;
```

### 5. **Testing Subscriptions** 🧪

#### A. Set Up Test Accounts
1. In Google Play Console, go to **Setup > License testing**
2. Add tester email addresses
3. Set license test response to "RESPOND_NORMALLY"

#### B. Create Internal Testing Release
1. Build release APK:
   ```bash
   cd app
   flutter build apk --release
   ```
2. Upload to **Release > Testing > Internal testing**
3. Add testers to internal test track
4. Share opt-in link with testers

#### C. Test Purchase Flow
1. Install app from internal testing track
2. Sign in with test account
3. Try purchasing each subscription
4. Verify features unlock correctly
5. Test subscription cancellation
6. Test subscription restoration

### 6. **Add Required Permissions** ✅
Already configured in `AndroidManifest.xml`:
```xml
<uses-permission android:name="com.android.vending.BILLING" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Testing Checklist

### Before Publishing
- [ ] Changed application ID from `com.example.examcoach_app`
- [ ] Created all three subscription products in Play Console
- [ ] Set up production signing configuration
- [ ] Implemented backend receipt verification
- [ ] Added service account for Google Play API
- [ ] Tested with internal testers
- [ ] Verified subscription upgrade/downgrade works
- [ ] Tested subscription restoration after app reinstall
- [ ] Confirmed subscriptions auto-renew in sandbox

### Subscription Flow Testing
- [ ] User can view subscription options
- [ ] Purchase completes successfully
- [ ] Receipt verification works
- [ ] Premium features unlock immediately
- [ ] Subscription status persists across app restarts
- [ ] Expired subscriptions lock premium features
- [ ] User can manage subscription (leads to Play Store)

## Revenue Configuration

### 1. **Set Up Merchant Account**
1. Go to **Setup > Payments profile**
2. Link your merchant account
3. Set up tax settings for each country
4. Configure payout settings

### 2. **Pricing Strategy**
Recommended pricing tiers:
- Basic Monthly: $4.99 USD
- Premium Monthly: $9.99 USD  
- Premium Annual: $79.99 USD (33% discount)

Adjust for local markets using Play Console's pricing templates.

## Monitoring & Analytics

### 1. **Track Key Metrics**
- Subscription conversion rate
- Churn rate
- Average revenue per user (ARPU)
- Trial-to-paid conversion (if using free trials)

### 2. **Set Up Firebase Analytics**
The app already has Firebase configured. Track these events:
```dart
// In subscription_service.dart
FirebaseAnalytics.instance.logEvent(
  name: 'subscription_purchased',
  parameters: {
    'product_id': productId,
    'price': price,
  },
);
```

## Common Issues & Solutions

### Issue: "Product not found"
**Solution:** Ensure product IDs match exactly between app and Play Console

### Issue: Purchases fail silently
**Solution:** Check that:
1. App is signed with release key
2. User is in license testers list
3. App version code matches uploaded version

### Issue: Subscription doesn't unlock features
**Solution:** Verify backend receipt validation is working

## Production Readiness Checklist

### Must Have (Before Launch)
- ✅ In-app purchase packages installed
- ✅ Subscription UI implemented
- ✅ Purchase flow implemented
- 🔴 Production package name set
- 🔴 Subscription products created in Play Console
- 🔴 Backend receipt verification
- 🔴 Production signing configured
- 🔴 Internal testing completed

### Nice to Have (Can Add Later)
- [ ] Introductory pricing
- [ ] Free trial periods
- [ ] Promo codes
- [ ] Win-back offers
- [ ] Regional pricing optimization

## Support & Resources

- [Google Play Billing Documentation](https://developer.android.com/google/play/billing)
- [Flutter In-App Purchase Plugin](https://pub.dev/packages/in_app_purchase)
- [Play Console Help](https://support.google.com/googleplay/android-developer)

## Next Steps

1. **Immediate Actions:**
   - Change the application ID in build.gradle.kts
   - Create a Google Play Developer account ($25 one-time fee)
   - Set up the three subscription products in Play Console

2. **Before Testing:**
   - Implement backend receipt verification
   - Create and configure signing keys
   - Upload first internal test build

3. **Before Launch:**
   - Complete all testing with real devices
   - Set up merchant account for payments
   - Plan your launch marketing strategy

---

**Note:** This subscription system is designed to be compliant with Google Play policies. Always review the latest [Google Play Developer Policy](https://play.google.com/console/policy) before publishing.
