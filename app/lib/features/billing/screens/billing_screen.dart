import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart';
import '../providers/billing_provider.dart';

class BillingScreen extends HookConsumerWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingState = ref.watch(billingProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(billingProvider.notifier).refreshEntitlements(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current subscription status
              _buildCurrentSubscriptionCard(context, ref, billingState),
              
              const SizedBox(height: 24),
              
              // Available plans
              _buildAvailablePlansSection(context, ref, billingState),
              
              const SizedBox(height: 24),
              
              // Payment history
              _buildPaymentHistorySection(context, ref),
              
              const SizedBox(height: 24),
              
              // Help and support
              _buildHelpSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(BuildContext context, WidgetRef ref, BillingState state) {
    if (state.isLoading && state.currentPlan == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: LoadingWidget(message: 'Loading subscription...'),
        ),
      );
    }

    final currentPlan = state.currentPlan;
    final isActive = state.isSubscribed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive ? AppTheme.successColor : AppTheme.errorColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isActive ? 'Active Subscription' : 'No Active Subscription',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (isActive && currentPlan != null) ...[
              _buildStatusRow(
                context,
                label: 'Plan',
                value: AppConstants.paymentPlans[currentPlan.plan]?['name'] ?? currentPlan.plan,
              ),
              _buildStatusRow(
                context,
                label: 'Started',
                value: _formatDate(currentPlan.startAt),
              ),
              _buildStatusRow(
                context,
                label: 'Expires',
                value: _formatDate(currentPlan.endAt),
              ),
              _buildStatusRow(
                context,
                label: 'Payment Method',
                value: _getPaymentMethodName(currentPlan.source),
              ),
              
              const SizedBox(height: 16),
              
              // Time remaining
              _buildTimeRemaining(context, currentPlan.endAt),
            ] else ...[
              Text(
                'Subscribe to access all features including unlimited practice, mock exams, and detailed analytics.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: () => _scrollToPlans(context),
                child: const Text('Choose a Plan'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, {required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemaining(BuildContext context, DateTime endDate) {
    final now = DateTime.now();
    final remaining = endDate.difference(now);
    
    String timeText;
    Color timeColor;
    
    if (remaining.isNegative) {
      timeText = 'Expired';
      timeColor = AppTheme.errorColor;
    } else if (remaining.inDays > 30) {
      timeText = '${(remaining.inDays / 30).floor()} month(s) remaining';
      timeColor = AppTheme.successColor;
    } else if (remaining.inDays > 7) {
      timeText = '${remaining.inDays} days remaining';
      timeColor = AppTheme.warningColor;
    } else {
      timeText = '${remaining.inDays} days remaining';
      timeColor = AppTheme.errorColor;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: timeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: timeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: timeColor, size: 20),
          const SizedBox(width: 8),
          Text(
            timeText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: timeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePlansSection(BuildContext context, WidgetRef ref, BillingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Plans',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...AppConstants.paymentPlans.entries.map((entry) {
          final planId = entry.key;
          final planData = entry.value;
          final isCurrentPlan = state.currentPlan?.plan == planId;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildPlanCard(context, ref, planId, planData, isCurrentPlan, state.isLoading),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    WidgetRef ref,
    String planId,
    Map<String, dynamic> planData,
    bool isCurrentPlan,
    bool isLoading,
  ) {
    final price = planData['price'] as int;
    final duration = planData['duration'] as int;
    final features = planData['features'] as List<String>;
    final pricePerMonth = (price / (duration / 30)).round();

    return Card(
      elevation: isCurrentPlan ? 4 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isCurrentPlan 
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planData['name'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$duration days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₦${_formatPrice(price)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        '₦${_formatPrice(pricePerMonth)}/month',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Features
              ...features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              
              const SizedBox(height: 20),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: isCurrentPlan
                    ? OutlineButton(
                        onPressed: null,
                        child: const Text('Current Plan'),
                      )
                    : ElevatedButton(
                        onPressed: isLoading 
                            ? null 
                            : () => _purchasePlan(context, ref, planId),
                        child: isLoading
                            ? const LoadingWidget(size: 20)
                            : Text('Subscribe - ₦${_formatPrice(price)}'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHistorySection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Payment History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your payment history will appear here after your first purchase.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Help & Support',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Billing FAQ'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showBillingFAQ(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.contact_support),
                title: const Text('Contact Support'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _contactSupport(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.policy),
                title: const Text('Terms & Privacy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showTermsAndPrivacy(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _scrollToPlans(BuildContext context) {
    // Scroll to plans section
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _purchasePlan(BuildContext context, WidgetRef ref, String planId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Subscribe to ${AppConstants.paymentPlans[planId]?['name']}'),
        content: const Text('Choose your payment method:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initiatePayment(context, ref, planId, 'paystack');
            },
            child: const Text('Pay with Paystack'),
          ),
        ],
      ),
    );
  }

  void _initiatePayment(BuildContext context, WidgetRef ref, String planId, String method) {
    ref.read(billingProvider.notifier).initializePayment(planId, method).then((checkoutUrl) {
      if (checkoutUrl != null) {
        _showPaymentWebView(context, ref, checkoutUrl);
      }
    });
  }

  void _showPaymentWebView(BuildContext context, WidgetRef ref, String checkoutUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentWebViewScreen(
          checkoutUrl: checkoutUrl,
          onPaymentComplete: () {
            Navigator.of(context).pop();
            ref.read(billingProvider.notifier).refreshEntitlements();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment successful! Your subscription is now active.'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          },
          onPaymentFailed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment failed. Please try again.'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBillingFAQ(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Billing FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: How do I cancel my subscription?'),
              SizedBox(height: 8),
              Text('A: Contact support to cancel your subscription.'),
              SizedBox(height: 16),
              Text('Q: When will I be charged?'),
              SizedBox(height: 8),
              Text('A: You will be charged immediately upon subscription.'),
              SizedBox(height: 16),
              Text('Q: Do you offer refunds?'),
              SizedBox(height: 8),
              Text('A: Refunds are available within 7 days of purchase.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Email: support@examcoach.com\nPhone: +234 800 000 0000'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsAndPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Privacy'),
        content: const Text('View our terms of service and privacy policy on our website.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getPaymentMethodName(String source) {
    switch (source) {
      case 'paystack':
        return 'Paystack';
      case 'flutterwave':
        return 'Flutterwave';
      case 'apple_iap':
        return 'Apple In-App Purchase';
      default:
        return source;
    }
  }
}

class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final VoidCallback onPaymentComplete;
  final VoidCallback onPaymentFailed;

  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.onPaymentComplete,
    required this.onPaymentFailed,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
          onNavigationRequest: (request) {
            if (request.url.contains('success')) {
              widget.onPaymentComplete();
              return NavigationDecision.prevent;
            } else if (request.url.contains('failed') || request.url.contains('cancel')) {
              widget.onPaymentFailed();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: LoadingWidget(
                size: 48,
                message: 'Loading payment page...',
                showMessage: true,
              ),
            ),
        ],
      ),
    );
  }
}
