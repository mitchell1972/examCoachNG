import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../data/repositories/entitlement_repository.dart';
import '../../../domain/entities/entitlement.dart';

final billingProvider = AsyncNotifierProvider<BillingNotifier, BillingState>(() {
  return BillingNotifier();
});

final entitlementProvider = FutureProvider<EntitlementEntity?>((ref) async {
  final entitlementRepo = ref.read(entitlementRepositoryProvider);
  return await entitlementRepo.getActiveEntitlement();
});

class BillingNotifier extends AsyncNotifier<BillingState> {
  @override
  Future<BillingState> build() async {
    final entitlementRepo = ref.read(entitlementRepositoryProvider);
    final hasActiveSubscription = await entitlementRepo.hasActiveSubscription();
    
    return BillingState(
      hasActiveSubscription: hasActiveSubscription,
      plans: _getAvailablePlans(),
    );
  }

  Future<void> initializePayment({
    required String planId,
    required String platform,
  }) async {
    state = AsyncValue.data(state.valueOrNull?.copyWith(
      isProcessingPayment: true,
      selectedPlan: planId,
    ) ?? BillingState(
      isProcessingPayment: true,
      selectedPlan: planId,
      plans: _getAvailablePlans(),
    ));

    try {
      final entitlementRepo = ref.read(entitlementRepositoryProvider);
      
      if (platform == 'ios') {
        await _handleIOSPurchase(planId);
      } else {
        final checkoutUrl = await entitlementRepo.initializePayment(
          plan: planId,
          platform: platform,
        );
        
        final currentState = state.valueOrNull;
        if (currentState != null) {
          state = AsyncValue.data(currentState.copyWith(
            checkoutUrl: checkoutUrl,
          ));
        }
      }
    } catch (error, stackTrace) {
      final currentState = state.valueOrNull;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(
          isProcessingPayment: false,
          error: error.toString(),
        ));
      } else {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> _handleIOSPurchase(String planId) async {
    try {
      final iapConnection = InAppPurchase.instance;
      final bool available = await iapConnection.isAvailable();
      
      if (!available) {
        throw Exception('In-app purchases are not available on this device');
      }

      // Define product IDs based on plan
      final productId = _getIOSProductId(planId);
      
      final ProductDetailsResponse response = await iapConnection.queryProductDetails({productId});
      
      if (response.error != null) {
        throw Exception('Failed to load product details: ${response.error!.message}');
      }

      if (response.productDetails.isEmpty) {
        throw Exception('Product not found: $productId');
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
      
      await iapConnection.buyNonConsumable(purchaseParam: purchaseParam);
      
      // Listen for purchase updates
      _listenToPurchaseUpdates();
      
    } catch (error) {
      rethrow;
    }
  }

  void _listenToPurchaseUpdates() {
    final iapConnection = InAppPurchase.instance;
    iapConnection.purchaseStream.listen((purchaseDetailsList) async {
      for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          await _completePurchase(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          final currentState = state.valueOrNull;
          if (currentState != null) {
            state = AsyncValue.data(currentState.copyWith(
              isProcessingPayment: false,
              error: purchaseDetails.error?.message ?? 'Purchase failed',
            ));
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await iapConnection.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<void> _completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      final entitlementRepo = ref.read(entitlementRepositoryProvider);
      await entitlementRepo.verifyIOSPurchase(purchaseDetails.verificationData.serverVerificationData);
      
      // Refresh entitlement status
      ref.invalidate(entitlementProvider);
      
      final currentState = state.valueOrNull;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(
          isProcessingPayment: false,
          hasActiveSubscription: true,
          purchaseCompleted: true,
        ));
      }
    } catch (error) {
      final currentState = state.valueOrNull;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(
          isProcessingPayment: false,
          error: 'Failed to verify purchase: $error',
        ));
      }
    }
  }

  String _getIOSProductId(String planId) {
    switch (planId) {
      case 'monthly':
        return 'com.examcoach.monthly';
      case 'term':
        return 'com.examcoach.term';
      case 'annual':
        return 'com.examcoach.annual';
      default:
        return 'com.examcoach.monthly';
    }
  }

  List<BillingPlan> _getAvailablePlans() {
    return [
      BillingPlan(
        id: 'monthly',
        name: 'Monthly Plan',
        description: 'Full access to all features',
        price: '₦2,000',
        duration: 'per month',
        features: [
          'Unlimited practice questions',
          'Mock exams with detailed results',
          'Offline access to question packs',
          'Progress tracking and analytics',
          'Detailed explanations',
        ],
        isPopular: false,
      ),
      BillingPlan(
        id: 'term',
        name: 'Term Plan',
        description: 'Best value for exam preparation',
        price: '₦5,000',
        duration: 'per term (6 months)',
        features: [
          'Everything in Monthly Plan',
          'Priority customer support',
          'Early access to new features',
          'Advanced performance analytics',
          'Study reminders and notifications',
        ],
        isPopular: true,
      ),
      BillingPlan(
        id: 'annual',
        name: 'Annual Plan',
        description: 'Maximum savings for dedicated students',
        price: '₦8,000',
        duration: 'per year',
        features: [
          'Everything in Term Plan',
          'Exclusive study materials',
          'One-on-one tutoring sessions',
          'Custom study plans',
          'Lifetime access to purchased content',
        ],
        isPopular: false,
      ),
    ];
  }

  Future<void> refreshEntitlement() async {
    try {
      final entitlementRepo = ref.read(entitlementRepositoryProvider);
      await entitlementRepo.refreshEntitlements();
      
      ref.invalidate(entitlementProvider);
      
      final hasActiveSubscription = await entitlementRepo.hasActiveSubscription();
      final currentState = state.valueOrNull;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(
          hasActiveSubscription: hasActiveSubscription,
        ));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearError() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(error: null));
    }
  }

  void clearPurchaseCompleted() {
    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(purchaseCompleted: false));
    }
  }
}

class BillingState {
  final bool hasActiveSubscription;
  final bool isProcessingPayment;
  final String? selectedPlan;
  final String? checkoutUrl;
  final String? error;
  final bool purchaseCompleted;
  final List<BillingPlan> plans;

  const BillingState({
    this.hasActiveSubscription = false,
    this.isProcessingPayment = false,
    this.selectedPlan,
    this.checkoutUrl,
    this.error,
    this.purchaseCompleted = false,
    this.plans = const [],
  });

  BillingState copyWith({
    bool? hasActiveSubscription,
    bool? isProcessingPayment,
    String? selectedPlan,
    String? checkoutUrl,
    String? error,
    bool? purchaseCompleted,
    List<BillingPlan>? plans,
  }) {
    return BillingState(
      hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      error: error,
      purchaseCompleted: purchaseCompleted ?? this.purchaseCompleted,
      plans: plans ?? this.plans,
    );
  }
}

class BillingPlan {
  final String id;
  final String name;
  final String description;
  final String price;
  final String duration;
  final List<String> features;
  final bool isPopular;

  const BillingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
  });
}
