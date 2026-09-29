class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
  );

  static final RegExp _nameRegex = RegExp(
    r"^[a-zA-Z\s.'\-]+$",
  );

  static final RegExp _contactRegex = RegExp(
    r'^\+?[0-9]{10,15}$',
  );

  static final RegExp _rollNumberRegex = RegExp(
    r'^[a-zA-Z0-9\-_]{1,15}$',
  );

  static final RegExp _employeeIdRegex = RegExp(
    r'^[a-zA-Z0-9\-]{2,20}$',
  );

  static String? required(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    final String trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 60) {
      return 'Name must be between 2 and 60 characters';
    }
    if (!_nameRegex.hasMatch(trimmed)) {
      return 'Enter a valid name';
    }
    return null;
  }

  static String? validateRollNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Roll number is required';
    }
    final String trimmed = value.trim();
    if (!_rollNumberRegex.hasMatch(trimmed)) {
      return 'Enter a valid roll number (1–15 characters)';
    }
    return null;
  }

  static String? validateClass(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Select a class';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    final String trimmed = value.trim();
    final int? age = int.tryParse(trimmed);
    if (age == null) {
      return 'Age must be a number';
    }
    if (age < 3 || age > 25) {
      return 'Enter an age between 3 and 25';
    }
    return null;
  }

  static String? validateGender(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Select a gender';
    }
    return null;
  }

  static String? validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact is required';
    }
    final String trimmed = value.trim();
    if (!_contactRegex.hasMatch(trimmed)) {
      return 'Enter a valid contact number (10–15 digits)';
    }
    return null;
  }

  static String? validateEmployeeId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Employee ID is required';
    }
    final String trimmed = value.trim();
    if (!_employeeIdRegex.hasMatch(trimmed)) {
      return 'Enter a valid employee ID (2–20 characters)';
    }
    return null;
  }

  static String? validateSubject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject is required';
    }
    final String trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 40) {
      return 'Subject must be between 2 and 40 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final String trimmed = value.trim().toLowerCase();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
