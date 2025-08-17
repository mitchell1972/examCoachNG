import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/dto/session_dto.dart';
import '../db/database.dart';
import '../../domain/entities/entitlement.dart';
import '../../core/utils/constants.dart';

class EntitlementRepository {
  final ApiClient _apiClient;
  final AppDatabase _database;
  final SharedPreferences _prefs;

  EntitlementRepository(this._apiClient, this._database, this._prefs);

  Future<EntitlementEntity?> getActiveEntitlement() async {
    try {
      // Try to get from server first
      final response = await _apiClient.get(ApiEndpoints.entitlements);
      final data = response.data as Map<String, dynamic>;
      
      if (data['active'] == true) {
        final entitlement = EntitlementEntity(
          plan: data['plan'] as String,
          startAt: DateTime.parse(data['start_at'] as String),
          endAt: DateTime.parse(data['end_at'] as String),
          source: data['source'] as String? ?? 'unknown',
          isActive: true,
        );

        // Cache locally
        await _database.insertEntitlement(EntitlementsCompanion(
          plan: drift.Value(entitlement.plan),
          startAt: drift.Value(entitlement.startAt),
          endAt: drift.Value(entitlement.endAt),
          source: drift.Value(entitlement.source),
        ));

        return entitlement;
      }
      return null;
    } catch (e) {
      // Fall back to local cache
      final localEntitlement = await _database.getActiveEntitlement();
      if (localEntitlement != null) {
        return EntitlementEntity(
          plan: localEntitlement.plan,
          startAt: localEntitlement.startAt,
          endAt: localEntitlement.endAt,
          source: localEntitlement.source,
          isActive: localEntitlement.endAt.isAfter(DateTime.now()),
        );
      }
      return null;
    }
  }

  Future<String> initializePayment({
    required String plan,
    required String platform,
  }) async {
    if (platform == 'ios') {
      throw Exception('iOS payments should use Apple IAP');
    }

    final response = await _apiClient.post(
      ApiEndpoints.paymentsInit,
      data: {'plan': plan},
    );

    final data = response.data as Map<String, dynamic>;
    return data['checkout_url'] as String;
  }

  Future<EntitlementEntity> verifyIOSPurchase(String receipt) async {
    final response = await _apiClient.post(
      ApiEndpoints.iapVerify,
      data: {'app_store_receipt': receipt},
    );

    final data = response.data as Map<String, dynamic>;
    
    final entitlement = EntitlementEntity(
      plan: data['plan'] as String,
      startAt: DateTime.now(),
      endAt: DateTime.parse(data['end_at'] as String),
      source: 'apple_iap',
      isActive: data['active'] as bool,
    );

    // Cache locally
    await _database.insertEntitlement(EntitlementsCompanion(
      plan: drift.Value(entitlement.plan),
      startAt: drift.Value(entitlement.startAt),
      endAt: drift.Value(entitlement.endAt),
      source: drift.Value(entitlement.source),
    ));

    return entitlement;
  }

  Future<void> refreshEntitlements() async {
    try {
      final entitlement = await getActiveEntitlement();
      // Entitlement is automatically cached in getActiveEntitlement
    } catch (e) {
      // Refresh failed, use cached data
    }
  }

  Future<void> clearExpiredEntitlements() async {
    await _database.clearExpiredEntitlements();
  }

  Future<bool> hasActiveSubscription() async {
    final entitlement = await getActiveEntitlement();
    return entitlement?.isActive ?? false;
  }

  Future<DateTime?> getLastEntitlementCheck() async {
    final timestamp = _prefs.getInt('last_entitlement_check');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  Future<void> updateLastEntitlementCheck() async {
    await _prefs.setInt('last_entitlement_check', DateTime.now().millisecondsSinceEpoch);
  }
}

final entitlementRepositoryProvider = Provider<EntitlementRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final database = ref.read(databaseProvider);
  final prefs = ref.read(sharedPreferencesProvider);
  
  return EntitlementRepository(apiClient, database, prefs);
});
