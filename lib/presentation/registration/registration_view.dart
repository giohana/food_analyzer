import 'package:flutter/material.dart';
import 'package:food_analyzer/presentation/home/home_view.dart';
import 'package:food_analyzer/presentation/widgets/input_form_widget.dart';

import '../widgets/button_full_widget.dart';
import 'registration_view_model.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _viewModel = RegistrationViewModel();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
            child: Column(
              children: [
                Text(
                  'Cadastro',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InputFormWidget(
                        labelText: 'Nome Completo',
                        controller: _viewModel.nameController,
                        focusNode: _viewModel.nameFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InputFormWidget(
                        labelText: 'Email',
                        controller: _viewModel.emailController,
                        focusNode: _viewModel.emailFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu email';
                          } else if (!_viewModel.validatorEmail(value)) {
                            return 'Por favor, insira um email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InputFormWidget(
                        labelText: 'Senha',
                        controller: _viewModel.passwordController,
                        focusNode: _viewModel.passwordFocusNode,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: _obscurePassword
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          } else if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      InputFormWidget(
                        labelText: 'Confirmar Senha',
                        controller: _viewModel.confirmPasswordController,
                        focusNode: _viewModel.confirmPasswordFocusNode,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: _obscureConfirmPassword
                              ? const Icon(Icons.visibility_off)
                              : const Icon(Icons.visibility),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, confirme sua senha';
                          } else if (value !=
                              _viewModel.passwordController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      ButtonFull(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _viewModel.registerUser();
                            if (_viewModel.errorMessageRegister.isEmpty) {
                              await _viewModel.loginUser();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Usuário registrado com sucesso!',
                                  ),
                                ),
                              );
                              if (_viewModel.errorMessageName.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(_viewModel.errorMessageName),
                                  ),
                                );
                              }
                              if (_viewModel.errorMessageLogin.isEmpty) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute<void>(
                                    builder: (context) => const HomeView(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _viewModel.errorMessageRegister,
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        label: 'CADASTRAR',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
