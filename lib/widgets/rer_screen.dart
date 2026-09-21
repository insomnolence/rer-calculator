import 'package:flutter/material.dart';

import '../branding.dart';
import '../rer_calculator.dart';
import 'app_logo.dart';
import 'disclaimer.dart';
import 'weight_input.dart';
import 'result_display.dart';
import 'restriction_section.dart';

class RerScreen extends StatefulWidget {
  const RerScreen({super.key, this.brand = Brand.generic});

  final Brand brand;

  @override
  State<RerScreen> createState() => _RerScreenState();
}

class _RerScreenState extends State<RerScreen> {
  final _calculator = RerCalculator();
  final _weightController = TextEditingController();
  final _percentageController = TextEditingController(text: '100');

  @override
  void dispose() {
    _calculator.dispose();
    _weightController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: BrandAppBarIcon(brand: widget.brand),
        ),
        title: Text(widget.brand.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About this calculator',
            onPressed: () => showAboutRerDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: ListenableBuilder(
              listenable: _calculator,
              builder: (context, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AppLogo(brand: widget.brand),
                      ),
                      const SizedBox(height: 8),
                      WeightInput(
                        calculator: _calculator,
                        controller: _weightController,
                      ),
                      ResultDisplay(calculator: _calculator),
                      RestrictionSection(
                        calculator: _calculator,
                        percentageController: _percentageController,
                      ),
                      const DisclaimerFooter(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
