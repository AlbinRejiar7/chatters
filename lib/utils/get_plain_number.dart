String getPlainPhoneNumber(String phoneNumber) {
  // Remove country code +91 if it exists
  if (phoneNumber.startsWith('+91')) {
    phoneNumber = phoneNumber.replaceFirst('+91', '');
  }

  // Trim any spaces from the phone number
  return phoneNumber.trim();
}
