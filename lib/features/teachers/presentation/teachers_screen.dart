import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
      ),
      body: SingleChildScrollView(
        padding: Responsive.screenPadding(context),
        child: Responsive.constrained(
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Teachers Management will be loaded in Phase 5.'),
            ),
          ),
        ),
      ),
    );
  }
}
