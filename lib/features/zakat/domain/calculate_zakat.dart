import 'zakat_calculation.dart';
import 'zakat_inputs.dart';
import 'zakat_repository.dart';

class CalculateZakat {
  const CalculateZakat(this._repository);

  final ZakatRepository _repository;

  Future<ZakatInputs> load() => _repository.loadInputs();

  Future<void> save(ZakatInputs inputs) => _repository.saveInputs(inputs);

  ZakatCalculation call(ZakatInputs inputs) {
    final assets = inputs.amount.clamp(0.0, double.infinity).toDouble();
    final net = assets;
    final meetsNisab = inputs.nisab > 0 && net >= inputs.nisab;
    final completedYears = inputs.holdingYears.floor().clamp(0, 100).toInt();
    final due = meetsNisab ? net * 0.025 * completedYears : 0.0;
    return ZakatCalculation(
      nisab: inputs.nisab,
      zakatDue: due,
      meetsNisab: meetsNisab,
      completedYears: completedYears,
      currency: inputs.currency,
    );
  }
}
