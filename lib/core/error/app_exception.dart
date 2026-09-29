sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class DuplicateException extends AppException {
  const DuplicateException(this.field, String message) : super(message);
  final String field;
}

class DatabaseOperationException extends AppException {
  const DatabaseOperationException(super.message, [this.cause]);
  final Object? cause;
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
