import 'package:flutter/material.dart';
import 'package:food_analyzer/presentation/login/login_view.dart';
import 'package:food_analyzer/presentation/registration/registration_view.dart';
import 'package:food_analyzer/presentation/widgets/button_full_widget.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 150, height: 150),
              const SizedBox(height: 20),
              const Text(
                'Bem-Vindo ao Food Analyzer',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Analise a qualidade nutricional dos alimentos de forma rápida e fácil.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              ButtonFull(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const Registration(),
                    ),
                  );
                },
                label: 'Começar Agora',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.green),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.green),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
                child: const Text(
                  'Já Tenho Conta',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
