import '../result.dart';

class LoginValidators {
  static final _emailFormat = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  static Result<String> validateEmail(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return Result.failure('El correo es obligatorio.');
    }
    if (trimmed.contains('*')) {
      return Result.failure('El correo no puede contener asteriscos.');
    }
    if (!_emailFormat.hasMatch(trimmed)) {
      return Result.failure('Ingresa un correo válido.');
    }
    return Result.success(trimmed);
  }

  static Result<String> validatePassword(String value) {
    if (value.isEmpty) {
      return Result.failure('La contraseña es obligatoria.');
    }
    if (value.contains('*')) {
      return Result.failure('La contraseña no puede contener asteriscos.');
    }
    if (value.length < 6) {
      return Result.failure('La contraseña debe tener al menos 6 caracteres.');
    }
    return Result.success(value);
  }
}