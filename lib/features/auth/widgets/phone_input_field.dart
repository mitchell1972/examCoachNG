import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../widgets/app_text_field.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: 'Phone Number',
      hint: 'e.g. 08012345678',
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone),
      validator: validator,
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
        _PhoneNumberFormatter(),
      ],
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove all non-digit characters
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format Nigerian phone numbers
    String formatted = digits;
    if (digits.length > 4) {
      formatted = '${digits.substring(0, 4)} ${digits.substring(4)}';
    }
    if (digits.length > 7) {
      formatted = '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    }
    if (digits.length > 10) {
      formatted = '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 10)} ${digits.substring(10)}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
