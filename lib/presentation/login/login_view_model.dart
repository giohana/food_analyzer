import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../configuration/auth_service.dart';

class LoginViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController emailControllerReset = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  String errorMessageLogin = '';

  Future<void> loginUser() async {
    try {
      authService.value.singIn(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (_) {
      errorMessageLogin = 'Erro ao fazer login, tente novamente mais tarde.';
    }
  }
}
