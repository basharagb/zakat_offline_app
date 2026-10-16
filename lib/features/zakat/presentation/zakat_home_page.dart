import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/app_colors.dart';
import '../domain/zakat_calculation.dart';
import 'zakat_controller.dart';

class ZakatHomePage extends GetView<ZakatController> {
  const ZakatHomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Obx(() {
        if (controller.activeTab.value == 1) return const _AboutContent();
        if (!controller.isReady.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          );
        }
        return const _CalculatorContent();
      }),
    ),
    bottomNavigationBar: Obx(
      () => NavigationBar(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.green.withValues(alpha: .18),
        selectedIndex: controller.activeTab.value,
        onDestinationSelected: (index) => controller.activeTab.value = index,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'الحاسبة',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'عن التطبيق',
          ),
        ],
      ),
    ),
  );
}

class _CalculatorContent extends GetView<ZakatController> {
  const _CalculatorContent();

  @override
  Widget build(BuildContext context) => Obx(() {
    final inputs = controller.inputs.value;
    final result = controller.calculation;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        const _TopHeader(),
        const SizedBox(height: 22),
        _ResultCard(result: result),
        const SizedBox(height: 18),
        const _SectionHeading(
          title: 'بيانات الدخل والعملة',
          subtitle: 'اكتب مصدر المبلغ وعملته، واستخدم العملة نفسها في الحقول',
          icon: Icons.work_outline,
        ),
        const SizedBox(height: 12),
        _TextEntryField(
          controller: controller.incomeSourceField,
          label: 'مصدر المبلغ، مثل راتب أو عمل حر',
          icon: Icons.work_outline,
          onChanged: controller.updateIncomeSource,
        ),
        _TextEntryField(
          controller: controller.currencyField,
          label: 'العملة، مثل ليرة سورية',
          icon: Icons.currency_exchange_outlined,
          onChanged: controller.updateCurrency,
        ),
        const SizedBox(height: 5),
        const _SectionHeading(
          title: 'المبلغ المراد حساب زكاته',
          subtitle: 'اكتب المبلغ المتبقي والمملوك لك بالعملة المحددة أعلاه',
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 12),
        _AmountField(
          controller: controller.fields['amount']!,
          label: 'المبلغ',
          icon: Icons.payments_outlined,
          onChanged: (v) => controller.updateAmount('amount', v),
        ),
        const SizedBox(height: 5),
        const _SectionHeading(
          title: 'النصاب والحول',
          subtitle: 'أدخل قيمة النصاب بعملتك وفق السعر المعتمد لديك',
          icon: Icons.calendar_month_outlined,
        ),
        const SizedBox(height: 12),
        _AmountField(
          controller: controller.fields['nisab']!,
          label: 'قيمة النصاب الحالية',
          icon: Icons.scale_outlined,
          onChanged: (v) => controller.updateAmount('nisab', v),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مدة امتلاك المال بعد بلوغ النصاب',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.holdingDurationField,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩]')),
                      ],
                      onChanged: controller.updateHoldingDuration,
                      decoration: const InputDecoration(
                        labelText: 'المدة',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: controller.holdingDurationUnit.value,
                      decoration: const InputDecoration(
                        labelText: 'الوحدة',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 13,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'day', child: Text('يوم')),
                        DropdownMenuItem(value: 'month', child: Text('شهر')),
                        DropdownMenuItem(value: 'year', child: Text('سنة')),
                      ],
                      onChanged: controller.updateDurationUnit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              const Text(
                'من يوم واحد إلى ١٠٠ سنة. لا تبدأ المدة من يوم قبض الراتب بالضرورة؛ أدخلها من بلوغ المال النصاب.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: controller.reset,
            icon: const Icon(Icons.restart_alt),
            label: const Text('مسح البيانات'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.muted,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'أدخل فقط المبلغ الذي ما زال مملوكًا لك. لا تُقسم الزكاة على مدة جمع الراتب؛ المعتبر بلوغ النصاب ومرور الحول. تختلف التفاصيل الفقهية بحسب نوع المال، فراجع جهة إفتاء موثوقة.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.6),
        ),
      ],
    );
  });
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: .16),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.mosque_outlined, color: AppColors.greenLight),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مؤوياتي',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'حاسبة الزكاة · تعمل دون إنترنت',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
      const Icon(
        Icons.offline_bolt_outlined,
        color: AppColors.greenLight,
        size: 21,
      ),
    ],
  );
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final ZakatCalculation result;

  @override
  Widget build(BuildContext context) {
    final message = result.nisab <= 0
        ? 'أدخل قيمة النصاب لمعرفة الاستحقاق'
        : !result.meetsNisab
        ? 'صافي المال لم يبلغ النصاب المدخل'
        : result.completedYears == 0
        ? 'لم يكتمل حول قمري منذ بلوغ النصاب'
        : 'الحساب عن ${result.completedYears} حول قمري مكتمل';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF102A20),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1D5135)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'مقدار الزكاة',
                  style: TextStyle(color: AppColors.greenLight, fontSize: 13),
                ),
              ),
              Icon(
                result.isDue ? Icons.check_circle_outline : Icons.info_outline,
                size: 19,
                color: AppColors.greenLight,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            _money(result.zakatDue, result.currency),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.greenLight,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.percent, size: 15, color: AppColors.greenLight),
                SizedBox(width: 6),
                Text(
                  '٢٫٥٪ عن كل حول قمري مكتمل',
                  style: TextStyle(color: AppColors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: AppColors.greenLight),
      const SizedBox(width: 9),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
    ],
  );
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩.,]')),
      ],
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19, color: AppColors.muted),
        suffixText: 'المبلغ',
        suffixStyle: const TextStyle(color: AppColors.muted, fontSize: 11),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border),
    ),
    child: child,
  );
}

class _TextEntryField extends StatelessWidget {
  const _TextEntryField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19, color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    ),
  );
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const _TopHeader(),
      const SizedBox(height: 22),
      const _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طريقة الحساب',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'أدخل المبلغ الذي تملكه حاليًا، ومصدره، وعملته. إذا بلغ المبلغ النصاب الذي أدخلته، يحسب التطبيق ٢٫٥٪ عن كل حول قمري مكتمل منذ بلوغه.',
              style: TextStyle(
                color: AppColors.muted,
                height: 1.7,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'مدة كسب الراتب أو الدخل ليست هي مدة امتلاك المال بعد بلوغ النصاب؛ لذلك لا تقسم الحاسبة الزكاة على أشهر الكسب. أربعة أشهر لا تكمل حولًا، وسنتان كاملتان تُحسبان حولين. أدخل قيمة النصاب الحالية يدويًا، واسأل جهة إفتاء عن حالتك والتفاصيل الفقهية.',
              style: TextStyle(
                color: AppColors.muted,
                height: 1.7,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'تقدير السنوات المتعددة يفترض ثبات صافي المال وعدم إخراج زكاة سابقة عنه؛ إن تغيّر المال أو أُخرجت زكاة في سنة سابقة فقد يختلف المبلغ.',
              style: TextStyle(
                color: AppColors.muted,
                height: 1.7,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      const _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'خصوصية وعمل دون اتصال',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'تُحفظ الأرقام على هذا الجهاز فقط باستخدام التخزين المحلي. لا يتطلب التطبيق اتصالًا بالإنترنت ولا يرسل بياناتك.',
              style: TextStyle(
                color: AppColors.muted,
                height: 1.7,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      const _Card(
        child: Column(
          children: [
            Text(
              'التصميم: بشار زبداني',
              style: TextStyle(color: AppColors.white, fontSize: 13),
            ),
            SizedBox(height: 7),
            Text(
              'إشراف: ميار رنه',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'مرجع عام: دار الإفتاء المصرية، نصاب زكاة المال ومقدارها (٢٫٥٪).',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.6),
        ),
      ),
    ],
  );
}

String _money(double value, String currency) {
  final rounded = value.toStringAsFixed(2);
  final amount = rounded.endsWith('.00')
      ? rounded.substring(0, rounded.length - 3)
      : rounded;
  return currency.trim().isEmpty ? amount : '$amount ${currency.trim()}';
}
