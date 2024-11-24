import 'package:get/get_utils/src/get_utils/get_utils.dart';

class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Use GetUtils to validate phone number format
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Enter a valid phone number';
    }

    return null; // Valid input
  }
}
