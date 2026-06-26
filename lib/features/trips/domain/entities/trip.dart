class Trip {
  const Trip({
    required this.id,
    required this.userId,
    required this.platformId,
    required this.grossAmountCents,
    this.bonusAmountCents = 0,
    this.tipAmountCents = 0,
    this.promotionCents = 0,
    this.cancellationCents = 0,
    required this.tripDate,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String platformId;
  final int grossAmountCents;
  final int bonusAmountCents;
  final int tipAmountCents;
  final int promotionCents;
  final int cancellationCents;
  final DateTime tripDate;
  final String? notes;
  final DateTime createdAt;

  int get totalIncomeCents =>
      grossAmountCents +
      bonusAmountCents +
      tipAmountCents +
      promotionCents +
      cancellationCents;

  Trip copyWith({
    int? grossAmountCents,
    int? bonusAmountCents,
    int? tipAmountCents,
    int? promotionCents,
    int? cancellationCents,
    DateTime? tripDate,
    String? notes,
  }) =>
      Trip(
        id: id,
        userId: userId,
        platformId: platformId,
        grossAmountCents: grossAmountCents ?? this.grossAmountCents,
        bonusAmountCents: bonusAmountCents ?? this.bonusAmountCents,
        tipAmountCents: tipAmountCents ?? this.tipAmountCents,
        promotionCents: promotionCents ?? this.promotionCents,
        cancellationCents: cancellationCents ?? this.cancellationCents,
        tripDate: tripDate ?? this.tripDate,
        notes: notes ?? this.notes,
        createdAt: createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Trip && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
