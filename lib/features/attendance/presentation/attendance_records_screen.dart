import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_chip.dart';
import '../domain/attendance_filter.dart';
import '../domain/attendance_record.dart';
import '../domain/attendance_status.dart';
import '../providers/attendance_providers.dart';

class AttendanceRecordsScreen extends ConsumerStatefulWidget {
  const AttendanceRecordsScreen({super.key});

  @override
  ConsumerState<AttendanceRecordsScreen> createState() => _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends ConsumerState<AttendanceRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateFilter() async {
    final AttendanceFilter currentFilter = ref.read(attendanceRecordsFilterProvider);
    DateTime initial = DateTime.now();
    if (currentFilter.date != null) {
      try {
        initial = AppDateUtils.parseIsoDate(currentFilter.date!);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final String iso = AppDateUtils.toIsoDate(picked);
      ref.read(attendanceRecordsFilterProvider.notifier).state =
          currentFilter.copyWith(date: iso);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AttendanceFilter filter = ref.watch(attendanceRecordsFilterProvider);
    final AsyncValue<List<AttendanceRecord>> recordsAsync = ref.watch(attendanceRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
        actions: <Widget>[
          if (filter.date != null || filter.className != null || filter.status != null || (filter.query?.isNotEmpty == true))
            IconButton(
              icon: const Icon(Icons.filter_alt_off_rounded),
              tooltip: 'Reset Filters',
              onPressed: () {
                _searchController.clear();
                ref.read(attendanceRecordsFilterProvider.notifier).state = const AttendanceFilter();
              },
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Responsive.constrained(
              child: SearchField(
                controller: _searchController,
                hint: 'Search by student name or roll...',
                onChanged: (String value) {
                  ref.read(attendanceRecordsFilterProvider.notifier).state =
                      filter.copyWith(query: value);
                },
                onClear: () {
                  ref.read(attendanceRecordsFilterProvider.notifier).state =
                      filter.copyWith(clearQuery: true);
                },
              ),
            ),
          ),
          // Filter Chips: Date, Class, Status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: <Widget>[
                // Date Chip
                FilterChip(
                  avatar: const Icon(Icons.calendar_today_rounded, size: 14),
                  label: Text(
                    filter.date != null ? AppDateUtils.formatIsoForDisplay(filter.date!) : 'All Dates',
                  ),
                  selected: filter.date != null,
                  onSelected: (_) => _pickDateFilter(),
                ),
                if (filter.date != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.xxs),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    tooltip: 'Clear Date Filter',
                    onPressed: () {
                      ref.read(attendanceRecordsFilterProvider.notifier).state =
                          filter.copyWith(clearDate: true);
                    },
                  ),
                ],
                const SizedBox(width: AppSpacing.xs),
                // Status Filter
                FilterChip(
                  label: Text(filter.status == null ? 'All Status' : filter.status!.label),
                  selected: filter.status != null,
                  onSelected: (_) {
                    final AttendanceStatus? next = switch (filter.status) {
                      null => AttendanceStatus.present,
                      AttendanceStatus.present => AttendanceStatus.absent,
                      AttendanceStatus.absent => null,
                    };
                    ref.read(attendanceRecordsFilterProvider.notifier).state =
                        filter.copyWith(status: next, clearStatus: next == null);
                  },
                ),
                const SizedBox(width: AppSpacing.xs),
                // Class Dropdown Chip
                PopupMenuButton<String?>(
                  onSelected: (String? c) {
                    ref.read(attendanceRecordsFilterProvider.notifier).state =
                        filter.copyWith(className: c, clearClass: c == null);
                  },
                  itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String?>>[
                    const PopupMenuItem<String?>(
                      value: null,
                      child: Text('All Classes'),
                    ),
                    ...AppConstants.classes.map(
                      (String c) => PopupMenuItem<String?>(
                        value: c,
                        child: Text(c),
                      ),
                    ),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.class_outlined, size: 14),
                    label: Text(filter.className ?? 'Class'),
                  ),
                ),
              ],
            ),
          ),
          // Records List
          Expanded(
            child: recordsAsync.when(
              loading: () => const SkeletonList(itemCount: 8),
              error: (Object err, _) => ErrorState(
                message: 'Failed to load records. Please try again.',
                onRetry: () => ref.invalidate(attendanceRecordsProvider),
              ),
              data: (List<AttendanceRecord> records) {
                final bool isFiltered = filter.date != null ||
                    filter.className != null ||
                    filter.status != null ||
                    (filter.query?.isNotEmpty == true);

                if (records.isEmpty) {
                  if (isFiltered) {
                    return EmptyState.noResults(
                      onClear: () {
                        _searchController.clear();
                        ref.read(attendanceRecordsFilterProvider.notifier).state =
                            const AttendanceFilter();
                      },
                    );
                  }
                  return const EmptyState(
                    icon: Icons.fact_check_outlined,
                    title: 'No attendance records',
                    message: 'Mark attendance for a class to view history here.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: records.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (BuildContext context, int index) {
                    final AttendanceRecord record = records[index];
                    return Responsive.constrained(
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    record.studentName ?? 'Student',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${record.className ?? ''} • Roll: ${record.studentRollNumber ?? ''} • ${AppDateUtils.formatIsoForDisplay(record.date)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(
                              status: record.status == AttendanceStatus.present
                                  ? AttendanceChipStatus.present
                                  : AttendanceChipStatus.absent,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
