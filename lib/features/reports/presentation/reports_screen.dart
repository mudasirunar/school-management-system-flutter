import 'package:flutter/material.dart';
import 'widgets/daily_report_view.dart';
import 'widgets/monthly_report_view.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Attendance Report'),
          bottom: TabBar(
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: const <Widget>[
              Tab(
                icon: Icon(Icons.today_rounded, size: 20),
                text: 'Daily Report',
              ),
              Tab(
                icon: Icon(Icons.date_range_rounded, size: 20),
                text: 'Monthly Report',
              ),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: <Widget>[
              DailyReportView(),
              MonthlyReportView(),
            ],
          ),
        ),
      ),
    );
  }
}
