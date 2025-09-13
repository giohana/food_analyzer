import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_analyzer/configuration/auth_service.dart';

class RegistrationViewModel {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  String errorMessageRegister = '';
  String errorMessageLogin = '';
  String errorMessageName = '';

  bool validatorEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<void> registerUser() async {
    try {
      await authService.value.createAccount(
        email: emailController.text,
        password: passwordController.text,
      );
      await updateDisplayName();
    } on FirebaseAuthException catch (_) {
      errorMessageRegister = 'Erro ao registrar usuário, tente novamente mais tarde.';
    }
  }

  Future<void> updateDisplayName() async {
    try {
      await authService.value.updateDisplayName(nameController.text);
    } on FirebaseAuthException catch (_) {
      errorMessageName = 'Cadastro realizado, mas falha ao salvar nome.';
    }
  }

  Future<void> loginUser() async {
    try {
      await authService.value.singIn(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (_) {
      errorMessageLogin = 'Erro ao fazer login, tente novamente mais tarde.';
    }
  }
}
