class AiMessage {
  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isError = false,
  });

  final String id;
  final String role;
  final String content;
  final DateTime createdAt;
  final bool isError;

  bool get isUser => role == 'user';
}
