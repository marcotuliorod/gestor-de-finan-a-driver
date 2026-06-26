import 'package:flutter/material.dart';

class AiChatPage extends StatelessWidget {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistente IA')),
      body: const Center(
        child: Text('Chat com IA — Sprint 5'),
      ),
    );
  }
}
