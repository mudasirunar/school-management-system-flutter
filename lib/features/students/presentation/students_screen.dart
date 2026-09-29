import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: SingleChildScrollView(
        padding: Responsive.screenPadding(context),
        child: Responsive.constrained(
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Students Management will be loaded in Phase 4.'),
            ),
          ),
        ),
      ),
    );
  }
}
