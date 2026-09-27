import 'package:flutter/foundation.dart';
import '../../core/result.dart';
import '../../core/validators/login_validators.dart';
import 'login_repository.dart';

class LoginController extends ChangeNotifier {
  final LoginRepository _repository;
  LoginController(this._repository);

  bool isLoading = false;
  String? errorMessage;

  Future<bool> login(String email, String password) async {
    errorMessage = null;

    final emailResult = LoginValidators.validateEmail(email);
    if (emailResult is Failure<String>) {
      errorMessage = emailResult.message;
      notifyListeners();
      return false;
    }

    final passwordResult = LoginValidators.validatePassword(password);
    if (passwordResult is Failure<String>) {
      errorMessage = passwordResult.message;
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    final result = await _repository.signIn(
      email: (emailResult as Success<String>).data,
      password: (passwordResult as Success<String>).data,
    );

    isLoading = false;

    return result.when(
      success: (_) {
        notifyListeners();
        return true;
      },
      failure: (message) {
        errorMessage = message;
        notifyListeners();
        return false;
      },
    );
  }
}