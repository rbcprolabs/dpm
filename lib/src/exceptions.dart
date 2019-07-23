class PackageResolveException implements Exception {
  PackageResolveException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ScriptDoesNotExistException implements Exception {
  ScriptDoesNotExistException(this.message);
  final String message;
  @override
  String toString() => message;
}
