import 'package:flutter/material.dart';

import 'branding.dart';
import 'theme.dart';
import 'widgets/rer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RerApp(brand: await Brand.load()));
}

class RerApp extends StatelessWidget {
  const RerApp({super.key, this.brand = Brand.generic});

  final Brand brand;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: brand.appTitle,
      theme: buildAppTheme(brand),
      home: RerScreen(brand: brand),
      debugShowCheckedModeBanner: false,
    );
  }
}
