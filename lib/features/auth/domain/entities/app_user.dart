class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppUser && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AppUser(id: $id, email: $email)';
}
