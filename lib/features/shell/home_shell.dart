import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/responsive.dart';
import '../attendance/presentation/attendance_screen.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../reports/presentation/reports_screen.dart';
import '../students/presentation/students_screen.dart';
import '../teachers/presentation/teachers_screen.dart';
import 'navigation_provider.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    StudentsScreen(),
    TeachersScreen(),
    AttendanceScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(navigationIndexProvider);
    final bool isPhone = Responsive.isPhone(context);

    void onDestinationSelected(int index) {
      if (currentIndex == index) return;
      ref.read(navigationIndexProvider.notifier).state = index;
    }

    if (isPhone) {
      return Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Students',
            ),
            NavigationDestination(
              icon: Icon(Icons.badge_outlined),
              selectedIcon: Icon(Icons.badge_rounded),
              label: 'Teachers',
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check_rounded),
              label: 'Attendance',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reports',
            ),
          ],
        ),
      );
    }

    // Tablet / Desktop layout with NavigationRail
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.school_rounded, size: 32),
            ),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: Text('Students'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.badge_outlined),
                selectedIcon: Icon(Icons.badge_rounded),
                label: Text('Teachers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.fact_check_outlined),
                selectedIcon: Icon(Icons.fact_check_rounded),
                label: Text('Attendance'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart_rounded),
                label: Text('Reports'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}
