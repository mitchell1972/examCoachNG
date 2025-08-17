class Validators {
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove spaces and special characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Nigerian phone number validation
    if (cleanPhone.length < 10 || cleanPhone.length > 14) {
      return 'Please enter a valid phone number';
    }
    
    // Must start with valid Nigerian prefix
    final validPrefixes = ['234', '0803', '0806', '0813', '0816', '0818', '0703', '0706', '0803', '0806', '0810', '0813', '0814', '0816', '0903', '0906', '0913', '0916', '0701', '0708', '0802', '0808', '0812', '0701', '0902', '0904', '0907', '0911', '0915'];
    
    bool hasValidPrefix = false;
    for (final prefix in validPrefixes) {
      if (cleanPhone.startsWith(prefix)) {
        hasValidPrefix = true;
        break;
      }
    }
    
    if (!hasValidPrefix && !cleanPhone.startsWith('234')) {
      return 'Please enter a valid Nigerian phone number';
    }
    
    return null;
  }
  
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }
    
    return null;
  }
  
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }
  
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    
    return null;
  }
  
  static String? numeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '$fieldName must contain only numbers';
    }
    
    return null;
  }
  
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Convert to international format
    if (cleanPhone.startsWith('0')) {
      return '234${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('234')) {
      return cleanPhone;
    } else {
      return '234$cleanPhone';
    }
  }
}
