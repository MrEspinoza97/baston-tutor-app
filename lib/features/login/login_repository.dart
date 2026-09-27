import 'package:firebase_auth/firebase_auth.dart';
import '../../core/result.dart';

class LoginRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return Result.failure('No se pudo iniciar sesión.');
      }
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'Correo o contraseña incorrectos.',
        'invalid-email' => 'El formato de correo no es válido.',
        'user-disabled' => 'Este usuario está deshabilitado.',
        'too-many-requests' => 'Demasiados intentos. Intenta más tarde.',
        _ => 'Error al iniciar sesión: ${e.message}',
      };
      return Result.failure(message);
    } catch (_) {
      return Result.failure('Error de conexión. Verifica tu internet.');
    }
  }
}