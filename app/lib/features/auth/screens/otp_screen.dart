import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../providers/auth_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';
import '../../../core/theme/app_theme.dart';

class OTPScreen extends HookConsumerWidget {
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    
    final otpController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final focusNode = FocusNode();

    // Timer state for resend OTP
    Timer? resendTimer;
    ValueNotifier<int> resendCountdown = ValueNotifier(60);
    ValueNotifier<bool> canResend = ValueNotifier(false);

    // Start countdown timer
    void startResendTimer() {
      resendCountdown.value = 60;
      canResend.value = false;
      
      resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (resendCountdown.value > 0) {
          resendCountdown.value--;
        } else {
          canResend.value = true;
          timer.cancel();
        }
      });
    }

    // Start timer on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startResendTimer();
      focusNode.requestFocus();
    });

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.error != next.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        authNotifier.clearError();
      }

      if (previous?.isAuthenticated != next.isAuthenticated && next.isAuthenticated) {
        // Check if user has completed onboarding
        if (next.user?.subjects.isEmpty ?? true) {
          context.go('/subjects');
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/phone'),
        ),
        title: const Text('Verify Phone'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Icon
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.message,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Enter verification code',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'We sent a 6-digit code to\n$phoneNumber',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // OTP Input
                TextFormField(
                  controller: otpController,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    letterSpacing: 8.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: AppTheme.textHint,
                      letterSpacing: 8.0,
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the verification code';
                    }
                    if (value.length != 6) {
                      return 'Please enter a valid 6-digit code';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value.length == 6) {
                      // Auto-verify when 6 digits are entered
                      _verifyOTP(authNotifier, otpController.text, formKey);
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Verify Button
                CustomButton(
                  onPressed: authState.isLoading ? null : () {
                    _verifyOTP(authNotifier, otpController.text, formKey);
                  },
                  child: authState.isLoading 
                    ? const LoadingWidget(size: 20)
                    : const Text('Verify'),
                ),
                
                const SizedBox(height: 32),
                
                // Resend OTP
                ValueListenableBuilder<bool>(
                  valueListenable: canResend,
                  builder: (context, canResendValue, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the code? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (canResendValue)
                          TextButton(
                            onPressed: () async {
                              await authNotifier.startOTP(phoneNumber);
                              startResendTimer();
                            },
                            child: const Text('Resend'),
                          )
                        else
                          ValueListenableBuilder<int>(
                            valueListenable: resendCountdown,
                            builder: (context, countdown, child) {
                              return Text(
                                'Resend in ${countdown}s',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
                
                const Spacer(),
                
                // Change Phone Number
                TextButton(
                  onPressed: () => context.go('/phone'),
                  child: const Text('Change phone number'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verifyOTP(
    AuthNotifier authNotifier,
    String code,
    GlobalKey<FormState> formKey,
  ) {
    if (formKey.currentState?.validate() ?? false) {
      authNotifier.verifyOTP(phoneNumber, code);
    }
  }
}
