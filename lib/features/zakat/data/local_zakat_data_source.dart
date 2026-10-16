import 'package:shared_preferences/shared_preferences.dart';

import '../domain/zakat_inputs.dart';

class LocalZakatDataSource {
  static const _storageKey = 'zakat_offline_inputs_v1';

  Future<ZakatInputs> load() async {
    final prefs = await SharedPreferences.getInstance();
    final values = <String, Object?>{
      'amount': prefs.getDouble('${_storageKey}_amount'),
      'nisab': prefs.getDouble('${_storageKey}_nisab'),
      'holdingYears': prefs.getDouble('${_storageKey}_holdingYears'),
      'incomeSource': prefs.getString('${_storageKey}_incomeSource'),
      'currency': prefs.getString('${_storageKey}_currency'),
    };
    return ZakatInputs.fromMap(values);
  }

  Future<void> save(ZakatInputs inputs) async {
    final prefs = await SharedPreferences.getInstance();
    final values = inputs.toMap();
    for (final entry in values.entries) {
      final key = '${_storageKey}_${entry.key}';
      final value = entry.value;
      if (value is double) await prefs.setDouble(key, value);
      if (value is bool) await prefs.setBool(key, value);
      if (value is int) await prefs.setInt(key, value);
      if (value is String) await prefs.setString(key, value);
    }
  }
}
