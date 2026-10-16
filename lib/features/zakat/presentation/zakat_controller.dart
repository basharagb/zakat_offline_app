import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../domain/calculate_zakat.dart';
import '../domain/zakat_calculation.dart';
import '../domain/zakat_inputs.dart';

class ZakatController extends GetxController {
  ZakatController(this._calculateZakat);

  final CalculateZakat _calculateZakat;
  final inputs = const ZakatInputs().obs;
  final isReady = false.obs;
  final activeTab = 0.obs;
  final incomeSourceField = TextEditingController();
  final currencyField = TextEditingController();
  final holdingDurationField = TextEditingController(text: '1');
  final holdingDurationUnit = 'day'.obs;

  ZakatCalculation get calculation => _calculateZakat(inputs.value);

  final fields = <String, TextEditingController>{
    'amount': TextEditingController(),
    'nisab': TextEditingController(),
  };

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final stored = await _calculateZakat.load();
    inputs.value = stored;
    incomeSourceField.text = stored.incomeSource;
    currencyField.text = stored.currency;
    _showDuration(stored.holdingYears);
    for (final entry in fields.entries) {
      final value = switch (entry.key) {
        'amount' => stored.amount,
        'nisab' => stored.nisab,
        _ => 0.0,
      };
      if (value != 0) entry.value.text = _formatInput(value);
    }
    isReady.value = true;
  }

  String _formatInput(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  void updateAmount(String key, String value) {
    final normalized = value
        .replaceAll(',', '.')
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9');
    final parsed = double.tryParse(normalized) ?? 0;
    final current = inputs.value;
    inputs.value = switch (key) {
      'amount' => current.copyWith(amount: parsed),
      'nisab' => current.copyWith(nisab: parsed),
      _ => current,
    };
    _save();
  }

  void updateIncomeSource(String value) {
    inputs.value = inputs.value.copyWith(incomeSource: value);
    _save();
  }

  void updateCurrency(String value) {
    inputs.value = inputs.value.copyWith(currency: value);
    _save();
  }

  void _showDuration(double years) {
    final wholeYears = years.round();
    if (wholeYears >= 1 && (years - wholeYears).abs() < 0.000001) {
      holdingDurationUnit.value = 'year';
      holdingDurationField.text = '$wholeYears';
      return;
    }
    final months = (years * 12).round();
    if (months >= 1 && (years * 12 - months).abs() < 0.000001) {
      holdingDurationUnit.value = 'month';
      holdingDurationField.text = '$months';
      return;
    }
    holdingDurationUnit.value = 'day';
    holdingDurationField.text = '${(years * 354).round().clamp(1, 35400)}';
  }

  void updateDurationUnit(String? unit) {
    if (unit == null) return;
    holdingDurationUnit.value = unit;
    updateHoldingDuration(holdingDurationField.text);
  }

  void updateHoldingDuration(String value) {
    final normalized = _normalizeDigits(value);
    final parsed = int.tryParse(normalized);
    if (parsed == null) {
      inputs.value = inputs.value.copyWith(holdingYears: 0);
      _save();
      return;
    }
    final unit = holdingDurationUnit.value;
    final maxValue = switch (unit) {
      'month' => 1200,
      'year' => 100,
      _ => 35400,
    };
    final bounded = parsed.clamp(1, maxValue).toInt();
    if (bounded.toString() != normalized) {
      holdingDurationField.value = TextEditingValue(
        text: '$bounded',
        selection: TextSelection.collapsed(offset: '$bounded'.length),
      );
    }
    final years = switch (unit) {
      'month' => bounded / 12,
      'year' => bounded.toDouble(),
      _ => bounded / 354,
    };
    inputs.value = inputs.value.copyWith(holdingYears: years);
    _save();
  }

  String _normalizeDigits(String value) => value
      .replaceAll('٠', '0')
      .replaceAll('١', '1')
      .replaceAll('٢', '2')
      .replaceAll('٣', '3')
      .replaceAll('٤', '4')
      .replaceAll('٥', '5')
      .replaceAll('٦', '6')
      .replaceAll('٧', '7')
      .replaceAll('٨', '8')
      .replaceAll('٩', '9');

  void _save() => _calculateZakat.save(inputs.value);

  Future<void> reset() async {
    inputs.value = const ZakatInputs();
    for (final field in fields.values) {
      field.clear();
    }
    incomeSourceField.clear();
    currencyField.clear();
    holdingDurationUnit.value = 'day';
    holdingDurationField.text = '1';
    await _calculateZakat.save(inputs.value);
  }

  @override
  void onClose() {
    for (final field in fields.values) {
      field.dispose();
    }
    incomeSourceField.dispose();
    currencyField.dispose();
    holdingDurationField.dispose();
    super.onClose();
  }
}
