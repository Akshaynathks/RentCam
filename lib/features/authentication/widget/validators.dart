String? validateFullName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  } else if (!RegExp(r'^[a-zA-Z_]+$').hasMatch(value)) {
    return 'name can only contain letters and underscores';
  }
  return null;
}

String? validateStudioName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter studio name';
  }

  // Trim the value to handle leading/trailing spaces
  value = value.trim();

  // Check if the name is too short
  if (value.length < 2) {
    return 'Studio name must be at least 2 characters long';
  }

  // Check if the name is too long
  if (value.length > 50) {
    return 'Studio name cannot exceed 50 characters';
  }

  // Check for valid characters and single spaces
  if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9\s\-_]*[a-zA-Z0-9]$').hasMatch(value)) {
    return 'Studio name can only contain letters, numbers, single spaces, hyphens and underscores. Must start and end with a letter or number';
  }

  // Check for multiple spaces
  if (value.contains('  ')) {
    return 'Multiple spaces are not allowed';
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
