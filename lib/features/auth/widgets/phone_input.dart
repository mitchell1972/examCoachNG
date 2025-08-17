import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class PhoneInput extends ConsumerStatefulWidget {
  const PhoneInput({super.key});

  @override
  ConsumerState<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends ConsumerState<PhoneInput> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your phone number',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Phone Number Input
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              prefixText: '+234 ',
              prefixStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              hintText: '8012345678',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.phone),
            ),
            validator: _validatePhoneNumber,
            onChanged: (value) {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Continue'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Alternative Login Methods
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Demo Login (for testing)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _demoLogin,
              icon: const Icon(Icons.person),
              label: const Text('Demo Login'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any non-digit characters
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check for Nigerian phone number patterns
    if (cleaned.length == 10 && cleaned.startsWith(RegExp(r'[789]'))) {
      return null; // Valid 10-digit number starting with 7, 8, or 9
    }
    
    if (cleaned.length == 11 && cleaned.startsWith('0')) {
      return null; // Valid 11-digit number starting with 0
    }
    
    return 'Please enter a valid Nigerian phone number';
  }

  String _formatPhoneNumber(String phone) {
    // Remove any non-digit characters
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Convert to international format
    if (cleaned.length == 10 && cleaned.startsWith(RegExp(r'[789]'))) {
      return '+234$cleaned';
    } else if (cleaned.length == 11 && cleaned.startsWith('0')) {
      return '+234${cleaned.substring(1)}';
    }
    
    return '+234$cleaned';
  }

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final formattedPhone = _formatPhoneNumber(_phoneController.text);
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.startOtpVerification(formattedPhone);
      
      if (success && mounted) {
        context.push('/otp?phone=$formattedPhone');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _demoLogin() {
    // For testing purposes - simulate successful login
    context.push('/otp?phone=+2348012345678');
  }
}
