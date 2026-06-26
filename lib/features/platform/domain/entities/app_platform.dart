class AppPlatform {
  const AppPlatform({
    required this.id,
    required this.userId,
    required this.type,
    this.customName,
    this.isActive = true,
  });

  final String id;
  final String userId;
  final String type;
  final String? customName;
  final bool isActive;

  String get displayName {
    return switch (type) {
      'uber' => 'Uber',
      'app99' => '99',
      'indrive' => 'inDrive',
      'taxi' => 'Táxi',
      'delivery' => 'Delivery',
      'custom' => customName ?? 'Outra',
      _ => type,
    };
  }

  static const defaultTypes = [
    'uber',
    'app99',
    'indrive',
    'taxi',
    'delivery',
  ];

  AppPlatform copyWith({bool? isActive}) {
    return AppPlatform(
      id: id,
      userId: userId,
      type: type,
      customName: customName,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppPlatform && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
