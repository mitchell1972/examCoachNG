import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../widgets/otp_input_field.dart';
import '../../../widgets/app_button.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/constants.dart';

class OtpScreen extends HookConsumerWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final authState = ref.watch(authProvider);
    final resendTimer = useState<int>(60);
    final canResend = useState<bool>(false);

    // Countdown timer for resend
    useEffect(() {
      if (resendTimer.value > 0) {
        final timer = Stream.periodic(const Duration(seconds: 1), (i) => i)
            .take(resendTimer.value)
            .listen((i) {
          resendTimer.value = 60 - i - 1;
          if (resendTimer.value <= 0) {
            canResend.value = true;
          }
        });
        return timer.cancel;
      }
      return null;
    }, []);

    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      next.when(
        data: (state) {
          if (state.isAuthenticated) {
            // Check if onboarding is complete
            ref.read(authProvider.notifier).isOnboardingComplete().then((complete) {
              if (complete) {
                context.go('/home');
              } else {
                context.go('/subjects');
              }
            });
          }
        },
        loading: () {},
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              
              // Verification icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.message,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Verify your phone number',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'We sent a 6-digit code to',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              
              Text(
                phone,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // OTP input form
              Form(
                key: formKey,
                child: Column(
                  children: [
                    OtpInputField(
                      controller: otpController,
                      validator: Validators.otp,
                      onCompleted: (code) {
                        if (formKey.currentState!.validate()) {
                          ref.read(authProvider.notifier)
                              .verifyOtp(phone, code);
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    AppButton(
                      text: 'Verify Code',
                      isLoading: authState.isLoading,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          ref.read(authProvider.notifier)
                              .verifyOtp(phone, otpController.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (canResend.value)
                    TextButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).startOtp(phone);
                        resendTimer.value = 60;
                        canResend.value = false;
                      },
                      child: const Text('Resend'),
                    )
                  else
                    Text(
                      'Resend in ${resendTimer.value}s',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
