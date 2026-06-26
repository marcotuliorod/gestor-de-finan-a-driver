import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:driver_finance/features/ai_chat/domain/entities/ai_conversation.dart';
import 'package:driver_finance/features/ai_chat/presentation/providers/ai_chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConversationListPage extends ConsumerWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(watchConversationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Assistente IA')),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Erro ao carregar conversas')),
        data: (conversations) => conversations.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (_, i) {
                  final conv = conversations[i];
                  return _ConversationTile(
                    conversation: conv,
                    onDelete: () => deleteConversation(ref, conv.id),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ai/chat'),
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('Nova conversa'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma conversa ainda',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque em "Nova conversa" para começar.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onDelete,
  });

  final AiConversation conversation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final date = conversation.updatedAt;
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final dateLabel = isToday
        ? '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

    return Dismissible(
      key: ValueKey(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.expense,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Apagar conversa'),
            content: const Text('Esta ação não pode ser desfeita.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Apagar',
                  style: TextStyle(color: AppColors.expense),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
        title: Text(
          conversation.title ?? 'Conversa sem título',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          dateLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () => context.push('/ai/chat/${conversation.id}'),
      ),
    );
  }
}
