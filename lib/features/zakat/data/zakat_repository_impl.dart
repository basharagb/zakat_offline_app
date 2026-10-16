import '../domain/zakat_inputs.dart';
import '../domain/zakat_repository.dart';
import 'local_zakat_data_source.dart';

class ZakatRepositoryImpl implements ZakatRepository {
  const ZakatRepositoryImpl(this._localDataSource);

  final LocalZakatDataSource _localDataSource;

  @override
  Future<ZakatInputs> loadInputs() => _localDataSource.load();

  @override
  Future<void> saveInputs(ZakatInputs inputs) => _localDataSource.save(inputs);
}
