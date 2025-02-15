// Validate Name
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  }
  if (value.length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null; // Return null if valid
}

//Email validations
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an email';
  }
  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!regex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null; // Return null if valid
}

// Validate Password
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a password';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null; // Return null if valid
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Please enter your phone number';
  }

  // Regex breakdown:
  // ^           : start of string
  // (\+63|0)?   : optionally match "+63" or "0" at the beginning
  // \d{10}      : exactly 10 digits
  // $           : end of string
  final regex = RegExp(r'^(\+63|0)?\d{10}$');
  if (!regex.hasMatch(value.trim())) {
    return 'Please enter a valid phone number.\nAllowed formats:\n• 09106447828\n• +639106447828\n• 9106447828';
  }
  return null; // Return null if valid
}

// Validate Location (if required)
String? validateLocation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please set up your address';
  }
  return null; // Return null if valid
}

// Validate Location in the Add New Address
String? validateLocationNewAddress(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter an address';
  }
  return null; // Return null if valid
}

