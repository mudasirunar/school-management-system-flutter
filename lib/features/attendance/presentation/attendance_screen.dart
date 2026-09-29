import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: SingleChildScrollView(
        padding: Responsive.screenPadding(context),
        child: Responsive.constrained(
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Attendance Management will be loaded in Phase 6.'),
            ),
          ),
        ),
      ),
    );
  }
}
