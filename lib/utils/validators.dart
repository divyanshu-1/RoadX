/// Form validation helpers used across auth and registration flows.
class Validators {
  static final RegExp emailRegex =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp vehicleRegex =
      RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$');
  static final RegExp aadhaarRegex = RegExp(r'^\d{12}$');
  static final RegExp phoneRegex = RegExp(r'^\d{10}$');

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final req = required(value, 'Email');
    if (req != null) return req;
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final req = required(value, 'Password');
    if (req != null) return req;
    if (value!.trim().length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? phone(String? value) {
    final req = required(value, 'Phone number');
    if (req != null) return req;
    if (!phoneRegex.hasMatch(value!.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? aadhaar(String? value) {
    final req = required(value, 'Aadhaar number');
    if (req != null) return req;
    if (!aadhaarRegex.hasMatch(value!.trim())) {
      return 'Aadhaar must be 12 digits';
    }
    return null;
  }

  static String? vehicleNumber(String? value) {
    final req = required(value, 'Vehicle number');
    if (req != null) return req;
    final formatted = value!.trim().toUpperCase().replaceAll(' ', '');
    if (!vehicleRegex.hasMatch(formatted)) {
      return 'Format: MH12AB1234';
    }
    return null;
  }

  static String? amount(String? value) {
    final req = required(value, 'Fine amount');
    if (req != null) return req;
    final amount = int.tryParse(value!.trim());
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }
    return null;
  }
}
