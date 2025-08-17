import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/billing_provider.dart';
import '../widgets/plan_card.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/error_widget.dart';

class BillingScreen extends ConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingState = ref.watch(billingProvider);
    final entitlementAsync = ref.watch(entitlementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(billingProvider.notifier).refreshEntitlement();
            },
          ),
        ],
      ),
      body: billingState.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => AppErrorWidget(
          error: error.toString(),
          onRetry: () => ref.refresh(billingProvider),
        ),
        data: (state) {
          // Listen to state changes for navigation and feedback
          ref.listen<AsyncValue<BillingState>>(billingProvider, (previous, next) {
            next.whenData((state) {
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                ref.read(billingProvider.notifier).clearError();
              }

              if (state.purchaseCompleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Purchase completed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                ref.read(billingProvider.notifier).clearPurchaseCompleted();
              }

              if (state.checkoutUrl != null) {
                _launchCheckout(context, state.checkoutUrl!);
              }
            });
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current subscription status
                entitlementAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (entitlement) {
                    if (entitlement != null && entitlement.isActive) {
                      return _buildCurrentSubscription(context, entitlement);
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Header
                if (!state.hasActiveSubscription) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unlock Premium Features',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get unlimited access to all exam preparation materials and features',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Plans
                Text(
                  state.hasActiveSubscription ? 'Available Plans' : 'Choose Your Plan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                ...state.plans.map((plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PlanCard(
                    plan: plan,
                    isSelected: state.selectedPlan == plan.id,
                    isProcessing: state.isProcessingPayment && state.selectedPlan == plan.id,
                    onSelect: state.isProcessingPayment
                        ? null
                        : () => _handlePlanSelection(context, ref, plan.id),
                  ),
                )),

                const SizedBox(height: 32),

                // Features comparison
                if (!state.hasActiveSubscription) ...[
                  _buildFeaturesComparison(context),
                  const SizedBox(height: 32),
                ],

                // FAQ or support info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.help,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Need Help?',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Contact our support team if you have any questions about billing or subscriptions.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Open support/contact
                          },
                          child: const Text('Contact Support'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentSubscription(BuildContext context, entitlement) {
    final isExpiring = entitlement.isExpiringSoon;
    final isExpired = entitlement.isExpired;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.red.withOpacity(0.1)
            : isExpiring
                ? Colors.orange.withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired
              ? Colors.red
              : isExpiring
                  ? Colors.orange
                  : Colors.green,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isExpired
                    ? Icons.error
                    : isExpiring
                        ? Icons.warning
                        : Icons.check_circle,
                color: isExpired
                    ? Colors.red
                    : isExpiring
                        ? Colors.orange
                        : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                isExpired
                    ? 'Subscription Expired'
                    : isExpiring
                        ? 'Subscription Expiring Soon'
                        : 'Active Subscription',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isExpired
                      ? Colors.red
                      : isExpiring
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entitlement.planDisplayName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entitlement.formattedRemainingTime,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (isExpiring || isExpired) ...[
            const SizedBox(height: 12),
            Text(
              isExpired
                  ? 'Renew your subscription to continue accessing premium features.'
                  : 'Renew now to avoid interruption of service.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesComparison(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Free vs Premium',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _ComparisonRow(
              feature: 'Practice Questions',
              free: '10 per day',
              premium: 'Unlimited',
            ),
            _ComparisonRow(
              feature: 'Mock Exams',
              free: '1 per week',
              premium: 'Unlimited',
            ),
            _ComparisonRow(
              feature: 'Offline Access',
              free: 'Limited',
              premium: 'Full access',
            ),
            _ComparisonRow(
              feature: 'Detailed Analytics',
              free: 'Basic',
              premium: 'Advanced',
            ),
            _ComparisonRow(
              feature: 'Customer Support',
              free: 'Email only',
              premium: 'Priority support',
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlanSelection(BuildContext context, WidgetRef ref, String planId) {
    final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    
    ref.read(billingProvider.notifier).initializePayment(
      planId: planId,
      platform: platform,
    );
  }

  Future<void> _launchCheckout(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch checkout URL');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open checkout: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String free;
  final String premium;

  const _ComparisonRow({
    required this.feature,
    required this.free,
    required this.premium,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              free,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              premium,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
