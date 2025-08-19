import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import '../core/utils/logger.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Product IDs - must match what you configure in App Store Connect and Google Play Console
  static const String kBasicMonthly = 'examcoach_basic_monthly';
  static const String kPremiumMonthly = 'examcoach_premium_monthly';
  static const String kPremiumAnnual = 'examcoach_premium_annual';
  
  static const Set<String> _kProductIds = {
    kBasicMonthly,
    kPremiumMonthly,
    kPremiumAnnual,
  };

  // Subscription status
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool _purchasePending = false;
  String? _activeSubscriptionId;
  DateTime? _expiryDate;

  // Getters
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get purchasePending => _purchasePending;
  bool get hasActiveSubscription => _activeSubscriptionId != null && 
      (_expiryDate == null || _expiryDate!.isAfter(DateTime.now()));
  String? get activeSubscriptionId => _activeSubscriptionId;

  // Initialize the service
  Future<void> initialize() async {
    try {
      Logger.info('Initializing subscription service...');
      
      // Check if in-app purchases are available
      _isAvailable = await _inAppPurchase.isAvailable();
      if (!_isAvailable) {
        Logger.warning('In-app purchases not available');
        return;
      }

      // Set up iOS-specific settings
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
      }

      // Load products
      await loadProducts();

      // Restore purchases
      await restorePurchases();

      // Listen for purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: _onPurchaseDone,
        onError: _onPurchaseError,
      );

      Logger.info('Subscription service initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize subscription service', error: e);
    }
  }

  // Load available products
  Future<void> loadProducts() async {
    try {
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(_kProductIds);
      
      if (response.error != null) {
        Logger.error('Error loading products', error: response.error);
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        Logger.warning('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      _products.sort((a, b) => a.price.compareTo(b.price));
      
      Logger.info('Loaded ${_products.length} products');
    } catch (e) {
      Logger.error('Failed to load products', error: e);
    }
  }

  // Purchase a subscription
  Future<bool> purchaseSubscription(String productId) async {
    try {
      // Find the product
      final ProductDetails? productDetails = _products.firstWhere(
        (product) => product.id == productId,
        orElse: () => throw Exception('Product not found'),
      );

      if (productDetails == null) {
        Logger.error('Product not found: $productId');
        return false;
      }

      // Create purchase param
      late final PurchaseParam purchaseParam;
      
      if (Platform.isAndroid) {
        // Android-specific: handle upgrade/downgrade
        final oldSubscription = _findOldSubscription();
        
        purchaseParam = GooglePlayPurchaseParam(
          productDetails: productDetails,
          changeSubscriptionParam: oldSubscription != null
              ? ChangeSubscriptionParam(
                  oldPurchaseDetails: oldSubscription,
                  prorationMode: ProrationMode.immediateWithTimeProration,
                )
              : null,
        );
      } else {
        // iOS
        purchaseParam = PurchaseParam(productDetails: productDetails);
      }

      // Initiate purchase
      _purchasePending = true;
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      Logger.info('Purchase initiated: $success');
      return success;
    } catch (e) {
      Logger.error('Failed to purchase subscription', error: e);
      _purchasePending = false;
      return false;
    }
  }

  // Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      Logger.info('Restoring purchases...');
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      Logger.error('Failed to restore purchases', error: e);
    }
  }

  // Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchaseDetails(purchaseDetails);
    }
  }

  // Process individual purchase
  Future<void> _handlePurchaseDetails(PurchaseDetails purchaseDetails) async {
    Logger.info('Processing purchase: ${purchaseDetails.productID}, status: ${purchaseDetails.status}');

    if (purchaseDetails.status == PurchaseStatus.pending) {
      _purchasePending = true;
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        _purchasePending = false;
        Logger.error('Purchase error', error: purchaseDetails.error);
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Verify purchase with your backend
        final bool valid = await _verifyPurchase(purchaseDetails);
        
        if (valid) {
          _deliverProduct(purchaseDetails);
        } else {
          Logger.error('Purchase verification failed');
          _handleInvalidPurchase(purchaseDetails);
        }
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }

      _purchasePending = false;
    }
  }

  // Verify purchase with backend
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Send receipt to your backend for verification
      // This is crucial for security - never trust client-side verification alone
      
      final Map<String, dynamic> receiptData = {
        'productId': purchaseDetails.productID,
        'purchaseId': purchaseDetails.purchaseID,
        'purchaseToken': purchaseDetails.verificationData.serverVerificationData,
        'verificationData': purchaseDetails.verificationData.serverVerificationData,
        'source': purchaseDetails.verificationData.source,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'userId': 'user_${DateTime.now().millisecondsSinceEpoch}', // TODO: Get actual user ID
      };

      // Get API base URL from environment or use default
      final apiBase = const String.fromEnvironment('API_BASE_URL', 
        defaultValue: 'http://localhost:3000');
      
      final response = await http.post(
        Uri.parse('$apiBase/api/subscriptions/verify-receipt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(receiptData),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['valid'] == true;
      }
      
      Logger.error('Receipt verification failed: ${response.statusCode}');
      return false;
    } catch (e) {
      Logger.error('Receipt verification failed', error: e);
      return false;
    }
  }

  // Deliver the purchased product
  void _deliverProduct(PurchaseDetails purchaseDetails) {
    _purchases.add(purchaseDetails);
    _activeSubscriptionId = purchaseDetails.productID;
    
    // Calculate expiry based on product type
    final now = DateTime.now();
    switch (purchaseDetails.productID) {
      case kBasicMonthly:
      case kPremiumMonthly:
        _expiryDate = now.add(const Duration(days: 30));
        break;
      case kPremiumAnnual:
        _expiryDate = now.add(const Duration(days: 365));
        break;
    }

    // Save to local storage
    _saveSubscriptionStatus();
    
    Logger.info('Product delivered: ${purchaseDetails.productID}');
  }

  // Handle invalid purchase
  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    Logger.error('Invalid purchase detected: ${purchaseDetails.productID}');
    // Could show an error to the user or take other action
  }

  // Find old subscription for upgrade/downgrade (Android)
  GooglePlayPurchaseDetails? _findOldSubscription() {
    if (_purchases.isEmpty) return null;
    
    // Find the most recent active subscription
    for (final purchase in _purchases.reversed) {
      if (purchase is GooglePlayPurchaseDetails &&
          _kProductIds.contains(purchase.productID)) {
        return purchase;
      }
    }
    return null;
  }

  // Save subscription status locally
  void _saveSubscriptionStatus() {
    // TODO: Implement local storage
    // You can use shared_preferences or secure_storage
  }

  // Load subscription status from local storage
  Future<void> _loadSubscriptionStatus() async {
    // TODO: Implement local storage loading
  }

  // Check if user has specific feature access
  bool hasFeatureAccess(String feature) {
    if (!hasActiveSubscription) return false;
    
    switch (_activeSubscriptionId) {
      case kBasicMonthly:
        return _basicFeatures.contains(feature);
      case kPremiumMonthly:
      case kPremiumAnnual:
        return true; // Premium has all features
      default:
        return false;
    }
  }

  static const Set<String> _basicFeatures = {
    'practice_questions',
    'basic_explanations',
    'progress_tracking',
  };

  // Get subscription info
  SubscriptionInfo? getSubscriptionInfo() {
    if (!hasActiveSubscription) return null;
    
    return SubscriptionInfo(
      productId: _activeSubscriptionId!,
      expiryDate: _expiryDate,
      isActive: hasActiveSubscription,
    );
  }

  // Cancel subscription (directs to store)
  Future<void> cancelSubscription() async {
    if (Platform.isIOS) {
      // Open iOS subscription management
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.showPriceConsentIfNeeded();
    } else if (Platform.isAndroid) {
      // Android users manage subscriptions in Play Store
      Logger.info('User should manage subscription in Play Store');
    }
  }

  void _onPurchaseDone() {
    _subscription?.cancel();
  }

  void _onPurchaseError(dynamic error) {
    Logger.error('Purchase stream error', error: error);
  }

  // Dispose
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription?.cancel();
  }
}

// Subscription info model
class SubscriptionInfo {
  final String productId;
  final DateTime? expiryDate;
  final bool isActive;

  SubscriptionInfo({
    required this.productId,
    this.expiryDate,
    required this.isActive,
  });
}

// iOS Payment Queue Delegate
class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
