import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../services/subscription_service.dart';
import '../../../widgets/app_button.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = true;
  String? _selectedPlan;

  @override
  void initState() {
    super.initState();
    _initializeSubscriptions();
  }

  Future<void> _initializeSubscriptions() async {
    await _subscriptionService.initialize();
    if (mounted) {
      setState(() {
        _isLoading = false;
        // Default to premium monthly
        _selectedPlan = SubscriptionService.kPremiumMonthly;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExamCoach Premium'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.school,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unlock Your Full Potential',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Get unlimited access to all questions and features',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Current subscription status
                  if (_subscriptionService.hasActiveSubscription)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Active Subscription',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Plan: ${_getProductName(_subscriptionService.activeSubscriptionId)}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Subscription Plans
                  Text(
                    'Choose Your Plan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Basic Plan
                  _buildPlanCard(
                    productId: SubscriptionService.kBasicMonthly,
                    title: 'Basic Monthly',
                    price: '₦1,000/month',
                    features: [
                      '100 questions per day',
                      'Basic explanations',
                      'Progress tracking',
                    ],
                    isPopular: false,
                  ),

                  // Premium Monthly Plan
                  _buildPlanCard(
                    productId: SubscriptionService.kPremiumMonthly,
                    title: 'Premium Monthly',
                    price: '₦2,500/month',
                    features: [
                      'Unlimited questions',
                      'Detailed explanations',
                      'Video solutions',
                      'Mock exams',
                      'Performance analytics',
                    ],
                    isPopular: true,
                  ),

                  // Premium Annual Plan
                  _buildPlanCard(
                    productId: SubscriptionService.kPremiumAnnual,
                    title: 'Premium Annual',
                    price: '₦20,000/year',
                    subtitle: 'Save ₦10,000!',
                    features: [
                      'Everything in Premium',
                      '2 months FREE',
                      'Priority support',
                      'Downloadable content',
                      'Early access to features',
                    ],
                    isPopular: false,
                  ),

                  const SizedBox(height: 24),

                  // Subscribe Button
                  AppButton(
                    text: _subscriptionService.purchasePending 
                        ? 'Processing...' 
                        : 'Subscribe Now',
                    onPressed: _subscriptionService.purchasePending || _selectedPlan == null
                        ? null
                        : () => _purchaseSubscription(_selectedPlan!),
                  ),

                  const SizedBox(height: 16),

                  // Restore Purchases
                  TextButton(
                    onPressed: _restorePurchases,
                    child: const Text('Restore Purchases'),
                  ),

                  const SizedBox(height: 24),

                  // Terms and Privacy
                  Text(
                    'By subscribing, you agree to our Terms of Service and Privacy Policy',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Subscriptions auto-renew. Cancel anytime in your app store settings.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanCard({
    required String productId,
    required String title,
    required String price,
    String? subtitle,
    required List<String> features,
    required bool isPopular,
  }) {
    final isSelected = _selectedPlan == productId;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = productId;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            if (isPopular)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      Radio<String>(
                        value: productId,
                        groupValue: _selectedPlan,
                        onChanged: (value) {
                          setState(() {
                            _selectedPlan = value;
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchaseSubscription(String productId) async {
    final success = await _subscriptionService.purchaseSubscription(productId);
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to initiate purchase. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    await _subscriptionService.restorePurchases();

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (_subscriptionService.hasActiveSubscription) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active subscriptions found'),
          ),
        );
      }
    }
  }

  String _getProductName(String? productId) {
    switch (productId) {
      case SubscriptionService.kBasicMonthly:
        return 'Basic Monthly';
      case SubscriptionService.kPremiumMonthly:
        return 'Premium Monthly';
      case SubscriptionService.kPremiumAnnual:
        return 'Premium Annual';
      default:
        return 'Unknown';
    }
  }
}
