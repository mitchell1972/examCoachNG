import 'package:freezed_annotation/freezed_annotation.dart';

part 'entitlement.freezed.dart';

@freezed
class EntitlementEntity with _$EntitlementEntity {
  const factory EntitlementEntity({
    required String plan,
    required DateTime startAt,
    required DateTime endAt,
    required String source,
    required bool isActive,
  }) = _EntitlementEntity;

  const EntitlementEntity._();

  Duration get remainingTime => endAt.difference(DateTime.now());
  
  bool get isExpired => endAt.isBefore(DateTime.now());
  
  bool get isExpiringSoon => remainingTime.inDays <= 7;

  String get formattedRemainingTime {
    if (isExpired) return 'Expired';
    
    final days = remainingTime.inDays;
    if (days > 0) {
      return '${days} day${days == 1 ? '' : 's'} remaining';
    }
    
    final hours = remainingTime.inHours;
    if (hours > 0) {
      return '${hours} hour${hours == 1 ? '' : 's'} remaining';
    }
    
    final minutes = remainingTime.inMinutes;
    return '${minutes} minute${minutes == 1 ? '' : 's'} remaining';
  }

  String get planDisplayName {
    switch (plan.toLowerCase()) {
      case 'monthly':
        return 'Monthly Plan';
      case 'term':
        return 'Term Plan';
      case 'annual':
        return 'Annual Plan';
      default:
        return plan;
    }
  }

  String get sourceDisplayName {
    switch (source) {
      case 'paystack':
        return 'Paystack';
      case 'flutterwave':
        return 'Flutterwave';
      case 'apple_iap':
        return 'Apple App Store';
      default:
        return 'Unknown';
    }
  }
}
