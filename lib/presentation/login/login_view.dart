import 'package:flutter/material.dart';
import 'package:food_analyzer/presentation/widgets/button_full_widget.dart';

import '../../configuration/auth_service.dart';
import '../home/bottom_bar_view.dart';
import '../widgets/input_form_widget.dart';
import 'login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _viewModel = LoginViewModel();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 25),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InputFormWidget(
                        labelText: 'Email',
                        controller: _viewModel.emailController,
                        focusNode: _viewModel.emailFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InputFormWidget(
                        labelText: 'Senha',
                        controller: _viewModel.passwordController,
                        focusNode: _viewModel.passwordFocusNode,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ButtonFull(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            await _viewModel.loginUser();
                            if (_viewModel.errorMessageLogin.isEmpty) {
                              if (mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute<void>(
                                    builder: (context) => const BottomNavigationBarView(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_viewModel.errorMessageLogin),
                                ),
                              );
                            }
                          }
                          setState(() => _isLoading = false);
                        },
                        label: 'LOGIN',
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => _dialogResetPassword(context),
                        child: const Text(
                          'Esqueceu a senha?',
                          style: TextStyle(color: Colors.green, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogResetPassword(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Redefinir Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Um email de redefinição de senha será enviado para:'),
              const SizedBox(height: 8),
              InputFormWidget(
                labelText: 'Email',
                controller: _viewModel.emailControllerReset,
                focusNode: _viewModel.emailFocusNode,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
              ),
            ],

          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Enviar',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () async {
                await authService.value.resetPassword(email: _viewModel.emailControllerReset.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email de redefinição de senha enviado!'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
