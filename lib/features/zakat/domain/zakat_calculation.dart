class ZakatCalculation {
  const ZakatCalculation({
    required this.nisab,
    required this.zakatDue,
    required this.meetsNisab,
    required this.completedYears,
    required this.currency,
  });

  final double nisab;
  final double zakatDue;
  final bool meetsNisab;
  final int completedYears;
  final String currency;

  bool get isDue => zakatDue > 0;
}
