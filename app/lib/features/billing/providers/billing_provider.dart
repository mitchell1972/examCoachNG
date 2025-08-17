import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/api/dio_client.dart';
import '../../../data/db/database.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

// Billing state
class BillingState {
  final Entitlement? currentPlan;
  final List<Entitlement> entitlements;
  final bool isLoading;
  final String? error;

  const BillingState({
    this.currentPlan,
    this.entitlements = const [],
    this.isLoading = false,
    this.error,
  });

  BillingState copyWith({
    Entitlement? currentPlan,
    List<Entitlement>? entitlements,
    bool? isLoading,
    String? error,
  }) {
    return BillingState(
      currentPlan: currentPlan ?? this.currentPlan,
      entitlements: entitlements ?? this.entitlements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isSubscribed => currentPlan != null && currentPlan!.active;
}

// Billing notifier
class BillingNotifier extends StateNotifier<BillingState> {
  final DioClient _dioClient = DioClient.instance;
  final AppDatabase _database = AppDatabase();

  BillingNotifier() : super(const BillingState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await refreshEntitlements();
  }

  Future<void> refreshEntitlements() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get entitlements from server
      final response = await _dioClient.get(AppConstants.entitlementsEndpoint);
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final isActive = data['active'] as bool? ?? false;
        
        if (isActive) {
          final plan = data['plan'] as String;
          final endAt = DateTime.parse(data['end_at'] as String);
          
          // Create entitlement object
          final entitlement = Entitlement(
            plan: plan,
            startAt: DateTime.now(), // This should come from server
            endAt: endAt,
            source: 'server', // This should come from server
            active: isActive,
          );
          
          // Store in local database
          await _database.insertEntitlement(EntitlementsCompanion.insert(
            plan: plan,
            startAt: entitlement.startAt,
            endAt: endAt,
            source: entitlement.source,
            active: Value(isActive),
          ));
          
          state = state.copyWith(
            currentPlan: entitlement,
            entitlements: [entitlement],
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            currentPlan: null,
            entitlements: [],
            isLoading: false,
          );
        }
      }
      
      Logger.info('Entitlements refreshed successfully');
    } catch (e) {
      Logger.error('Failed to refresh entitlements', error: e);
      
      // Try to load from local database as fallback
      try {
        final localEntitlements = await _database.getActiveEntitlements();
        final currentPlan = localEntitlements.isNotEmpty ? localEntitlements.first : null;
        
        state = state.copyWith(
          currentPlan: currentPlan,
          entitlements: localEntitlements,
          isLoading: false,
          error: _getErrorMessage(e),
        );
      } catch (localError) {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage(e),
        );
      }
    }
  }

  Future<String?> initializePayment(String plan, String method) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final planData = AppConstants.paymentPlans[plan];
      if (planData == null) {
        throw Exception('Invalid plan: $plan');
      }

      Logger.info('Initializing payment for plan: $plan');

      final response = await _dioClient.post(
        '${AppConstants.paymentsEndpoint}/init',
        data: {
          'plan': plan,
          'method': method,
          'amount': planData['price'],
          'currency': 'NGN',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final checkoutUrl = data['checkout_url'] as String?;
        
        state = state.copyWith(isLoading: false);
        Logger.info('Payment initialized successfully');
        
        return checkoutUrl;
      } else {
        throw Exception('Failed to initialize payment: ${response.statusMessage}');
      }
    } catch (e) {
      Logger.error('Failed to initialize payment', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return null;
    }
  }

  Future<void> verifyIOSPurchase(String receipt) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      Logger.info('Verifying iOS purchase');

      final response = await _dioClient.post(
        '${AppConstants.iapEndpoint}/ios/verify',
        data: {
          'app_store_receipt': receipt,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final isActive = data['active'] as bool? ?? false;
        
        if (isActive) {
          final plan = data['plan'] as String;
          final endAt = DateTime.parse(data['end_at'] as String);
          
          final entitlement = Entitlement(
            plan: plan,
            startAt: DateTime.now(),
            endAt: endAt,
            source: 'apple_iap',
            active: isActive,
          );
          
          await _database.insertEntitlement(EntitlementsCompanion.insert(
            plan: plan,
            startAt: entitlement.startAt,
            endAt: endAt,
            source: entitlement.source,
            active: Value(isActive),
          ));
          
          state = state.copyWith(
            currentPlan: entitlement,
            entitlements: [entitlement],
            isLoading: false,
          );
        }
      }
      
      Logger.info('iOS purchase verified successfully');
    } catch (e) {
      Logger.error('Failed to verify iOS purchase', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  Future<void> cancelSubscription() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      Logger.info('Cancelling subscription');

      // This would typically call a server endpoint to cancel the subscription
      // For now, we'll just clear the local data
      
      state = state.copyWith(
        currentPlan: null,
        entitlements: [],
        isLoading: false,
      );
      
      Logger.info('Subscription cancelled');
    } catch (e) {
      Logger.error('Failed to cancel subscription', error: e);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}

// Billing provider
final billingProvider = StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  return BillingNotifier();
});

// Convenience providers
final currentPlanProvider = Provider<Entitlement?>((ref) {
  return ref.watch(billingProvider).currentPlan;
});

final isSubscribedProvider = Provider<bool>((ref) {
  return ref.watch(billingProvider).isSubscribed;
});

final billingIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(billingProvider).isLoading;
});

final billingErrorProvider = Provider<String?>((ref) {
  return ref.watch(billingProvider).error;
});
