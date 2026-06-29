/// [AppException] represents a generic application exception.
class AppException implements Exception {
  final String userMessage;
  final Object? details;

  AppException(this.userMessage, {this.details});

  @override
  String toString() => 'AppException(message: $userMessage)';
}
