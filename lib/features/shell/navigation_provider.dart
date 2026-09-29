import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the active tab index of HomeShell across the application:
/// 0: Dashboard
/// 1: Students
/// 2: Teachers
/// 3: Attendance
/// 4: Reports
final StateProvider<int> navigationIndexProvider = StateProvider<int>((Ref ref) => 0);
