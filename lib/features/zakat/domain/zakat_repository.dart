import 'zakat_inputs.dart';

abstract interface class ZakatRepository {
  Future<ZakatInputs> loadInputs();
  Future<void> saveInputs(ZakatInputs inputs);
}
