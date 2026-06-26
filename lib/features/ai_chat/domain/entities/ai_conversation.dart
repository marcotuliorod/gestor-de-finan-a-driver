class AiConversation {
  const AiConversation({
    required this.id,
    required this.userId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;
}
