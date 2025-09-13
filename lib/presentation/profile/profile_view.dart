import 'package:flutter/material.dart';
import 'package:food_analyzer/configuration/auth_service.dart';
import 'package:food_analyzer/presentation/onboarding/onboarding.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userName = authService.value.getUser()?.displayName ?? 'Usuário';
    final email = authService.value.getUser()?.email ?? 'Usuário';
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfil',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                Text(
                  'Olá, $userName!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'email: $email',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Center(
                    child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                      ),
                      onPressed: () => _dialogSingOut(context),
                      child: Text('Sair', style: TextStyle(color: Colors.black, fontSize: 18)),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => _dialogDeleteAccount(context),
                      child: Text('Deletar conta', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () => _dialogResetPassword(context, email),
                      child: const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            ),
        ],
      ),
    ));
  }

  Future<void> _dialogSingOut(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: const Text('Tem certeza que deseja sair?', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                setState(() => _isLoading = true);
                await authService.value.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (context) => const Onboarding(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _dialogDeleteAccount(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deletar Conta'),
          content: const Text('Tem certeza que deseja deletar sua conta? Esta ação não pode ser desfeita.',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Deletar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                setState(() => _isLoading = true);
                await authService.value.deleteAccount();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (context) => const Onboarding(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _dialogResetPassword(BuildContext context, String email) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Redefinir Senha'),
          content: Text('Um email de redefinição de senha será enviado para $email.'),
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
                await authService.value.resetPassword(email: email);
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
