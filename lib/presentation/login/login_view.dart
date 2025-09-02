import 'package:flutter/material.dart';
import 'package:food_analyzer/presentation/home/home_view.dart';
import 'package:food_analyzer/presentation/widgets/button_full_widget.dart';

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
      body: SingleChildScrollView(
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
                    labelText: 'Password',
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
                        await _viewModel.loginUser();
                        if (_viewModel.errorMessageLogin.isEmpty) {
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute<void>(
                                builder: (context) => const HomeView(),
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
                    },
                    label: 'LOGIN',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
