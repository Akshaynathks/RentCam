String? validateFullName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  } else if (!RegExp(r'^[a-zA-Z_]+$').hasMatch(value)) {
    return 'name can only contain letters and underscores';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  } else if (value.contains(' ')) {
    return 'Email cannot contain spaces';
  } else if (!RegExp(r'^[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+$')
      .hasMatch(value)) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validateMobile(String? value) {
  value = value?.replaceAll(' ', '');
  if (value == null || value.isEmpty) {
    return 'Please enter your mobile number';
  } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
    return 'Invalid mobile number';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  } else if (value.contains(' ')) {
    return 'Password cannot contain spaces';
  } else if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

String? validateConfirmPassword(String? value, String originalPassword) {
  if (value == null || value.isEmpty) {
    return 'Please confirm your password';
  } else if (value.contains(' ')) {
    return 'Password cannot contain spaces';
  } else if (value != originalPassword) {
    return 'Passwords do not match';
  }
  return null;
}
