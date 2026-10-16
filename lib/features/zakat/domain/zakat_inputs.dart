class ZakatInputs {
  const ZakatInputs({
    this.amount = 0,
    this.nisab = 0,
    this.holdingYears = 1 / 354,
    this.incomeSource = '',
    this.currency = '',
  });

  final double amount;
  final double nisab;
  final double holdingYears;
  final String incomeSource;
  final String currency;

  ZakatInputs copyWith({
    double? amount,
    double? nisab,
    double? holdingYears,
    String? incomeSource,
    String? currency,
  }) => ZakatInputs(
    amount: amount ?? this.amount,
    nisab: nisab ?? this.nisab,
    holdingYears: holdingYears ?? this.holdingYears,
    incomeSource: incomeSource ?? this.incomeSource,
    currency: currency ?? this.currency,
  );

  Map<String, Object> toMap() => {
    'amount': amount,
    'nisab': nisab,
    'holdingYears': holdingYears,
    'incomeSource': incomeSource,
    'currency': currency,
  };

  factory ZakatInputs.fromMap(Map<String, Object?> map) => ZakatInputs(
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    nisab: (map['nisab'] as num?)?.toDouble() ?? 0,
    holdingYears: (map['holdingYears'] as num?)?.toDouble() ?? 1 / 354,
    incomeSource: map['incomeSource'] as String? ?? '',
    currency: map['currency'] as String? ?? '',
  );
}
