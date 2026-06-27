import 'package:drift/drift.dart';
import 'package:driver_finance/core/database/app_database.dart' as $db;
import 'package:driver_finance/core/utils/uuid_generator.dart';
import 'package:driver_finance/features/ai_chat/domain/entities/ai_conversation.dart';
import 'package:driver_finance/features/ai_chat/domain/entities/ai_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.isTyping = false,
    this.conversationId,
  });

  final List<AiMessage> messages;
  final bool isTyping;
  final String? conversationId;

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? isTyping,
    String? conversationId,
  }) =>
      AiChatState(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        conversationId: conversationId ?? this.conversationId,
      );
}

class AiChatNotifier extends FamilyNotifier<AiChatState, String?> {
  @override
  AiChatState build(String? arg) {
    if (arg != null) {
      Future.microtask(() => _loadMessages(arg));
    }
    return AiChatState(conversationId: arg);
  }

  Future<void> _loadMessages(String conversationId) async {
    final db = ref.read($db.appDatabaseProvider);
    final rows = await (db.select(db.aiMessages)
          ..where((t) => t.conversationId.equals(conversationId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    state = state.copyWith(
      messages: rows
          .map(
            (r) => AiMessage(
              id: r.id,
              role: r.role,
              content: r.content,
              createdAt: r.createdAt,
            ),
          )
          .toList(),
    );
  }

  Future<void> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.isTyping) return;

    final String conversationId = state.conversationId ?? generateUuid();
    if (state.conversationId == null) {
      final db = ref.read($db.appDatabaseProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final now = DateTime.now();
      final title =
          trimmed.length > 50 ? '${trimmed.substring(0, 50)}…' : trimmed;
      await db.into(db.aiConversations).insert(
            $db.AiConversationsCompanion(
              id: Value(conversationId),
              userId: Value(userId),
              title: Value(title),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      state = state.copyWith(conversationId: conversationId);
    }

    final userMsg = AiMessage(
      id: generateUuid(),
      role: 'user',
      content: trimmed,
      createdAt: DateTime.now(),
    );
    await _persistMessage(userMsg, conversationId);

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

      final assistantMsg = AiMessage(
        id: generateUuid(),
        role: 'assistant',
        content: assistantContent.isEmpty
            ? 'Desculpe, não consegui obter uma resposta.'
            : assistantContent,
        createdAt: DateTime.now(),
      );
      await _persistMessage(assistantMsg, conversationId);
      await _touchConversation(conversationId);

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isTyping: false,
      );
    } catch (_) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          AiMessage(
            id: generateUuid(),
            role: 'assistant',
            content: 'Desculpe, não consegui processar sua mensagem. '
                'Verifique sua conexão e tente novamente.',
            createdAt: DateTime.now(),
            isError: true,
          ),
        ],
        isTyping: false,
      );
    }
  }

  Future<void> _persistMessage(AiMessage msg, String conversationId) async {
    try {
      final db = ref.read($db.appDatabaseProvider);
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      await db.into(db.aiMessages).insert(
            $db.AiMessagesCompanion(
              id: Value(msg.id),
              conversationId: Value(conversationId),
              userId: Value(userId),
              role: Value(msg.role),
              content: Value(msg.content),
              createdAt: Value(msg.createdAt),
            ),
          );
    } catch (_) {}
  }

  Future<void> _touchConversation(String conversationId) async {
    try {
      final db = ref.read($db.appDatabaseProvider);
      await (db.update(db.aiConversations)
            ..where((t) => t.id.equals(conversationId)))
          .write(
        $db.AiConversationsCompanion(updatedAt: Value(DateTime.now())),
      );
    } catch (_) {}
  }
}

final aiChatProvider =
    NotifierProvider.family<AiChatNotifier, AiChatState, String?>(
  AiChatNotifier.new,
);

final watchConversationsProvider = StreamProvider<List<AiConversation>>((ref) {
  final db = ref.watch($db.appDatabaseProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return (db.select(db.aiConversations)
        ..where((t) => t.userId.equals(userId))
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
      .watch()
      .map(
        (rows) => rows
            .map(
              (r) => AiConversation(
                id: r.id,
                userId: r.userId,
                title: r.title,
                createdAt: r.createdAt,
                updatedAt: r.updatedAt,
              ),
            )
            .toList(),
      );
});

Future<void> deleteConversation(WidgetRef ref, String conversationId) async {
  final db = ref.read($db.appDatabaseProvider);
  await (db.delete(db.aiMessages)
        ..where((t) => t.conversationId.equals(conversationId)))
      .go();
  await (db.delete(db.aiConversations)
        ..where((t) => t.id.equals(conversationId)))
      .go();
}
