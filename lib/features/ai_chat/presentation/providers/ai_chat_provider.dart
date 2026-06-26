import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/ai_chat/domain/entities/ai_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.isTyping = false,
  });

  final List<AiMessage> messages;
  final bool isTyping;

  AiChatState copyWith({List<AiMessage>? messages, bool? isTyping}) =>
      AiChatState(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
      );
}

class AiChatNotifier extends Notifier<AiChatState> {
  @override
  AiChatState build() => const AiChatState();

  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.isTyping) return;

    final userMsg = AiMessage(
      id: generateUuid(),
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    try {
      final response = await Supabase.instance.client.functions.invoke(
        'ai-chat',
        body: {
          'messages': state.messages
              .where((m) => !m.isError)
              .map((m) => {'role': m.role, 'content': m.content})
              .toList(),
        },
      );

      final data = response.data;
      final assistantContent = (data is Map<String, dynamic>)
          ? (data['content'] as String? ?? '')
          : '';

      state = state.copyWith(
        messages: [
          ...state.messages,
          AiMessage(
            id: generateUuid(),
            role: 'assistant',
            content: assistantContent.isEmpty
                ? 'Desculpe, não consegui obter uma resposta.'
                : assistantContent,
            createdAt: DateTime.now(),
          ),
        ],
        isTyping: false,
      );
    } catch (_) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          AiMessage(
            id: generateUuid(),
            role: 'assistant',
            content:
                'Desculpe, não consegui processar sua mensagem. '
                'Verifique sua conexão e tente novamente.',
            createdAt: DateTime.now(),
            isError: true,
          ),
        ],
        isTyping: false,
      );
    }
  }
}

final aiChatProvider =
    NotifierProvider<AiChatNotifier, AiChatState>(AiChatNotifier.new);
