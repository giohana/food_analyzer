import 'package:flutter/material.dart';

class ButtonBorderWidget extends StatelessWidget {
  const ButtonBorderWidget({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
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
        // Navegar para a próxima tela (ex: tela de login ou cadastro)
      },
      child:  Text(
        label,
        style: TextStyle(
          color: Colors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
