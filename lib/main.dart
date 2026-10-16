import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app_colors.dart';
import 'features/zakat/data/local_zakat_data_source.dart';
import 'features/zakat/data/zakat_repository_impl.dart';
import 'features/zakat/domain/calculate_zakat.dart';
import 'features/zakat/presentation/zakat_controller.dart';
import 'features/zakat/presentation/zakat_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = ZakatRepositoryImpl(LocalZakatDataSource());
  Get.put(ZakatController(CalculateZakat(repository)), permanent: true);
  runApp(const ZakatApp());
}

class ZakatApp extends StatelessWidget {
  const ZakatApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'مؤوياتي',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        brightness: Brightness.dark,
        surface: AppColors.card,
      ),
      fontFamily: 'SF Pro',
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.field,
        hintStyle: const TextStyle(color: AppColors.muted),
        labelStyle: const TextStyle(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
      ),
    ),
    home: const Directionality(
      textDirection: TextDirection.rtl,
      child: ZakatHomePage(),
    ),
  );
}
