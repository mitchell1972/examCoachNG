# ExamCoach Subscription Testing Guide

## Overview
This guide walks you through testing the subscription functionality before publishing to Google Play Store.

## Prerequisites
- [ ] Google Play Developer Account ($25 one-time fee)
- [ ] App uploaded to Internal Testing track
- [ ] Test accounts added to license testers
- [ ] Subscription products created in Play Console

## Test Environment Setup

### 1. Configure Test Accounts
1. Go to Google Play Console → **Setup** → **License testing**
2. Add test Gmail accounts (not your developer account)
3. Set response to **"RESPOND_NORMALLY"** for realistic testing

### 2. Build Test APK
```bash
cd app

# Update version for testing
flutter pub get
flutter build apk --release --build-name=1.0.0 --build-number=1
```

### 3. Upload to Internal Testing
1. Go to **Release** → **Testing** → **Internal testing**
2. Create new release
3. Upload APK from `app/build/app/outputs/flutter-apk/app-release.apk`
4. Add release notes
5. Review and roll out

### 4. Install Test App
1. Share opt-in link with testers
2. Accept invitation on test device
3. Install app from Play Store (internal test version)

## Testing Scenarios

### Test Case 1: Fresh Install Purchase Flow
**Objective:** Verify new user can purchase subscription

**Steps:**
1. Install app fresh (clear data if reinstalling)
2. Open app and navigate to subscription screen
3. View all three subscription options
4. Select "Premium Monthly" ($9.99)
5. Complete Google Play purchase flow
6. Verify purchase completes successfully

**Expected Results:**
- ✅ Google Play payment sheet appears
- ✅ Test card is charged (shows $0.00 for testers)
- ✅ Success message displayed
- ✅ Premium features unlocked immediately
- ✅ Subscription badge shown on home screen

### Test Case 2: Subscription Restoration
**Objective:** Verify subscription restores after reinstall

**Steps:**
1. Purchase a subscription (if not already)
2. Note the active subscription type
3. Uninstall the app
4. Reinstall from Play Store
5. Open app and go to subscription screen
6. Tap "Restore Purchases"

**Expected Results:**
- ✅ Previous subscription detected
- ✅ Premium features re-enabled
- ✅ Correct expiry date shown
- ✅ No additional charge

### Test Case 3: Upgrade Subscription
**Objective:** Test upgrading from Basic to Premium

**Steps:**
1. Purchase "Basic Monthly" subscription
2. Verify basic features are active
3. Go to subscription screen
4. Select "Premium Monthly"
5. Complete upgrade flow

**Expected Results:**
- ✅ Proration applied (partial refund for unused Basic time)
- ✅ Premium features activate immediately
- ✅ New subscription replaces old one
- ✅ Billing cycle resets to Premium schedule

### Test Case 4: Downgrade Subscription
**Objective:** Test downgrading from Premium to Basic

**Steps:**
1. Have active "Premium Monthly" subscription
2. Go to subscription screen
3. Select "Basic Monthly"
4. Complete downgrade flow

**Expected Results:**
- ✅ Downgrade scheduled for next billing cycle
- ✅ Premium features remain until current period ends
- ✅ User notified of when downgrade takes effect

### Test Case 5: Annual Subscription
**Objective:** Verify annual subscription and savings

**Steps:**
1. View subscription options
2. Note monthly vs annual pricing
3. Purchase "Premium Annual"
4. Verify features and duration

**Expected Results:**
- ✅ Annual price shows 33% savings
- ✅ Expiry date is 365 days from purchase
- ✅ All premium features active
- ✅ Receipt shows annual billing

### Test Case 6: Subscription Cancellation
**Objective:** Test cancellation flow

**Steps:**
1. Have active subscription
2. Go to app settings
3. Tap "Manage Subscription"
4. Cancel in Google Play Store
5. Return to app

**Expected Results:**
- ✅ Redirected to Play Store subscriptions
- ✅ Can cancel from Play Store
- ✅ App shows "expires on [date]"
- ✅ Features remain until expiry

### Test Case 7: Expired Subscription
**Objective:** Verify behavior when subscription expires

**Steps:**
1. Cancel subscription
2. Wait for expiry (or use test clock)
3. Open app after expiry
4. Try accessing premium features

**Expected Results:**
- ✅ Premium features locked
- ✅ Prompt to resubscribe appears
- ✅ Can purchase new subscription
- ✅ Previous data retained

### Test Case 8: Network Issues
**Objective:** Test offline/network error handling

**Steps:**
1. Enable airplane mode
2. Try to purchase subscription
3. Re-enable network
4. Retry purchase

**Expected Results:**
- ✅ Clear error message when offline
- ✅ Purchase queued or retryable
- ✅ No duplicate charges
- ✅ Graceful recovery

### Test Case 9: Receipt Validation
**Objective:** Verify backend validates receipts

**Steps:**
1. Purchase subscription
2. Check backend logs
3. Verify database entry created
4. Check receipt verification succeeded

**Expected Results:**
- ✅ Receipt sent to backend
- ✅ Google Play API validates receipt
- ✅ Subscription saved to database
- ✅ No security warnings in logs

### Test Case 10: Multiple Devices
**Objective:** Test subscription on multiple devices

**Steps:**
1. Purchase on Device A
2. Install app on Device B
3. Sign in with same Google account
4. Restore purchases on Device B

**Expected Results:**
- ✅ Subscription active on both devices
- ✅ Same features available
- ✅ No additional charges
- ✅ Sync works correctly

## Testing with Google Play Test Cards

### Available Test Cards
Google provides test cards that always work:
- **Always Approves:** 4111 1111 1111 1111
- **Always Declines:** 4000 0000 0000 0002
- **Insufficient Funds:** 4000 0000 0000 0019
- **Expired Card:** 4000 0000 0000 0069

### Using Test Cards
1. Add test account to license testers
2. Sign in on device with test account
3. Use test card numbers above
4. Any CVV and future expiry date

## Backend Verification Testing

### 1. Check Logs
```bash
# View backend logs during purchase
cd server
npm run dev

# In another terminal, tail logs
tail -f logs/app.log | grep subscription
```

### 2. Verify Database Entries
```sql
-- Check active subscriptions
SELECT * FROM subscriptions 
WHERE expiry_date > NOW();

-- View subscription history
SELECT * FROM subscription_history 
ORDER BY created_at DESC;
```

### 3. Test Receipt Validation
```bash
# Test the verification endpoint directly
curl -X POST http://localhost:3000/api/subscriptions/verify-receipt \
  -H "Content-Type: application/json" \
  -d '{
    "productId": "examcoach_premium_monthly",
    "purchaseToken": "test-token",
    "platform": "android",
    "userId": "test-user-123"
  }'
```

## Common Testing Issues

### Issue: "Item already owned"
**Solution:** 
- Consume the purchase in Play Console
- Or wait for test purchase to expire (5 minutes)

### Issue: "This version of the app is not configured for billing"
**Solution:**
- Ensure APK is signed with release key
- Version code must match uploaded version
- Wait 2-3 hours after upload for propagation

### Issue: Test purchase shows real price
**Solution:**
- Confirm test account is in license testers
- Account must be different from developer account
- Sign out and back in on device

### Issue: Subscription doesn't appear in app
**Solution:**
- Product IDs must match exactly
- Products must be activated in Play Console
- Clear Play Store cache

## Production Readiness Checklist

### Before Beta Release
- [ ] All test cases pass
- [ ] Receipt verification working
- [ ] Database storing subscriptions
- [ ] Error handling tested
- [ ] Analytics events firing
- [ ] Subscription restoration works
- [ ] Upgrade/downgrade flows tested

### Before Production Release
- [ ] Real payment method tested (beta testers)
- [ ] Refund process documented
- [ ] Customer support ready
- [ ] Subscription terms in app
- [ ] Privacy policy updated
- [ ] Backend monitoring configured
- [ ] Webhook endpoints secured

## Testing Timeline

### Week 1: Internal Testing
- Set up test environment
- Run all test cases with team
- Fix critical bugs

### Week 2: Closed Beta
- Invite 20-50 beta testers
- Test with real payment methods
- Gather feedback on pricing

### Week 3: Open Beta
- Expand to 100+ testers
- Monitor subscription metrics
- Test customer support flow

### Week 4: Production Launch
- Gradual rollout (10% → 50% → 100%)
- Monitor error rates
- Be ready to pause if issues arise

## Support & Troubleshooting

### Debug Commands
```bash
# Check if billing is available
adb shell pm list packages | grep vending

# Clear Google Play Store cache
adb shell pm clear com.android.vending

# View purchase logs
adb logcat | grep -i billing
```

### Useful Links
- [Play Console Test Tracks](https://play.google.com/console/developers/app/tracks)
- [License Testing Setup](https://developer.android.com/google/play/billing/test)
- [Test Purchase Troubleshooting](https://developer.android.com/google/play/billing/test#troubleshoot)

## Contact for Issues
If you encounter issues during testing:
1. Check Play Console → **Inbox** for messages
2. Review **Quality** → **Crashes & ANRs**
3. Contact Play Console support if needed

---

**Remember:** Always test with real devices, not emulators, as Google Play Billing requires Play Store to be installed.
