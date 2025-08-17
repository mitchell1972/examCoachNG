import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: _isFocused ? AppTheme.primaryColor : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscureText && _isObscured,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onSubmitted,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textHint,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            errorText: widget.errorText,
            filled: true,
            fillColor: widget.enabled 
              ? (_isFocused 
                  ? AppTheme.primaryColor.withOpacity(0.05)
                  : Colors.grey.shade50)
              : Colors.grey.shade100,
            border: _buildBorder(Colors.grey.shade300),
            enabledBorder: _buildBorder(Colors.grey.shade300),
            focusedBorder: _buildBorder(AppTheme.primaryColor),
            errorBorder: _buildBorder(AppTheme.errorColor),
            focusedErrorBorder: _buildBorder(AppTheme.errorColor),
            disabledBorder: _buildBorder(Colors.grey.shade200),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            counterText: widget.maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          color: AppTheme.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: color,
        width: color == AppTheme.primaryColor ? 2 : 1,
      ),
    );
  }
}

// Specialized text field variants
class PasswordTextField extends CustomTextField {
  const PasswordTextField({
    super.key,
    super.controller,
    super.label = 'Password',
    super.hint = 'Enter your password',
    super.validator,
    super.onChanged,
    super.focusNode,
    super.textInputAction = TextInputAction.done,
  }) : super(
    obscureText: true,
    keyboardType: TextInputType.visiblePassword,
  );
}

class EmailTextField extends CustomTextField {
  const EmailTextField({
    super.key,
    super.controller,
    super.label = 'Email',
    super.hint = 'Enter your email',
    super.validator,
    super.onChanged,
    super.focusNode,
    super.textInputAction = TextInputAction.next,
  }) : super(
    keyboardType: TextInputType.emailAddress,
    inputFormatters: [
      FilteringTextInputFormatter.deny(RegExp(r'\s')),
    ],
  );
}

class PhoneTextField extends CustomTextField {
  const PhoneTextField({
    super.key,
    super.controller,
    super.label = 'Phone Number',
    super.hint = '+234 800 000 0000',
    super.validator,
    super.onChanged,
    super.focusNode,
    super.textInputAction = TextInputAction.done,
  }) : super(
    keyboardType: TextInputType.phone,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d+\s\-\(\)]')),
    ],
  );
}

class SearchTextField extends CustomTextField {
  const SearchTextField({
    super.key,
    super.controller,
    super.hint = 'Search...',
    super.onChanged,
    super.focusNode,
    super.textInputAction = TextInputAction.search,
    super.onSubmitted,
  }) : super(
    prefixIcon: const Icon(Icons.search),
    keyboardType: TextInputType.text,
  );
}
