import 'package:meta/meta.dart';

@immutable
class DpmException implements Exception {
  DpmException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PackageNotFoundException extends DpmException {
  PackageNotFoundException(String message) : super(message);
}

class ScriptDoesNotExistException extends DpmException {
  ScriptDoesNotExistException(String message) : super(message);
}

class InsufficientPrivilegesException extends DpmException {
  InsufficientPrivilegesException(String message) : super(message);
}

@immutable
class Errors {
  static DpmException simple(String message) => DpmException(message);

  static DpmException packageNotFound(String packageName) =>
      PackageNotFoundException(
          'Unable to resolve package within pub: "$packageName"');

  static DpmException scriptDoesNotExis(String script, String package) =>
      ScriptDoesNotExistException('Could not find a script or dev_package '
          'named "$script" in project "${package ?? '<untitled>'}".');

  static DpmException insufficientPrivileges() =>
      InsufficientPrivilegesException(
          'Windows platform requires administrative rights or '
          'enable developer mode to create symbolic links');
}
