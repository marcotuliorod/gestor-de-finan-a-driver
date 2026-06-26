import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuração inicial')),
      body: const Center(
        child: Text('Onboarding — Sprint 1'),
      ),
    );
  }
}
