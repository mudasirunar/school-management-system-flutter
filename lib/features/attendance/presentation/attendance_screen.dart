import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../students/domain/student.dart';
import '../domain/attendance_status.dart';
import '../providers/attendance_providers.dart';
import 'attendance_records_screen.dart';
import 'widgets/attendance_student_tile.dart';
import 'widgets/attendance_summary_strip.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final DateTime currentDate = ref.read(selectedAttendanceDateProvider);
    final AttendanceSheetState? sheetState = ref.read(attendanceSheetProvider).valueOrNull;

    if (sheetState != null && sheetState.isDirty) {
      final bool discard = await ConfirmDialog.show(
        context,
        title: 'Unsaved Changes',
        message: 'You have unsaved attendance marks. Change date and discard changes?',
        confirmLabel: 'Discard',
        isDestructive: true,
      );
      if (!discard) return;
      if (!context.mounted) return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // Future dates strictly forbidden
    );

    if (picked != null) {
      ref.read(selectedAttendanceDateProvider.notifier).state = picked;
    }
  }

  Future<void> _selectClass(BuildContext context, WidgetRef ref, String newClass) async {
    final String? currentClass = ref.read(selectedAttendanceClassProvider);
    if (newClass == currentClass) return;

    final AttendanceSheetState? sheetState = ref.read(attendanceSheetProvider).valueOrNull;
    if (sheetState != null && sheetState.isDirty) {
      final bool discard = await ConfirmDialog.show(
        context,
        title: 'Unsaved Changes',
        message: 'You have unsaved attendance marks. Change class and discard changes?',
        confirmLabel: 'Discard',
        isDestructive: true,
      );
      if (!discard) return;
    }

    ref.read(selectedAttendanceClassProvider.notifier).state = newClass;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final DateTime selectedDate = ref.watch(selectedAttendanceDateProvider);
    final String? selectedClass = ref.watch(selectedAttendanceClassProvider);
    final AsyncValue<AttendanceSheetState?> sheetAsync = ref.watch(attendanceSheetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Attendance Records',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const AttendanceRecordsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top Controls: Date & Class selector
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Responsive.constrained(
                child: Row(
                  children: <Widget>[
                    // Date Selector Button
                    Expanded(
                      flex: 5,
                      child: InkWell(
                        onTap: () => _pickDate(context, ref),
                        borderRadius: AppSpacing.borderRadiusInput,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: AppSpacing.borderRadiusInput,
                            border: Border.all(color: theme.colorScheme.outline),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      'Date',
                                      style: theme.textTheme.labelSmall,
                                    ),
                                    Text(
                                      AppDateUtils.formatShortForDisplay(selectedDate),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Class Selector Dropdown
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: AppSpacing.borderRadiusInput,
                          border: Border.all(color: theme.colorScheme.outline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedClass,
                            hint: const Text('Select Class'),
                            isExpanded: true,
                            items: AppConstants.classes.map((String c) {
                              return DropdownMenuItem<String>(
                                value: c,
                                child: Text(
                                  c,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                _selectClass(context, ref, value);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main Body: Empty prompt, Skeletons, or Attendance Sheet
            Expanded(
              child: selectedClass == null
                  ? const EmptyState(
                      icon: Icons.class_outlined,
                      title: 'No class selected',
                      message: 'Please choose a class from the dropdown above to mark attendance.',
                    )
                  : sheetAsync.when(
                      loading: () => const SkeletonList(itemCount: 7),
                      error: (Object err, _) => ErrorState(
                        message: 'Failed to load class attendance. Please try again.',
                        onRetry: () => ref.invalidate(attendanceSheetProvider),
                      ),
                      data: (AttendanceSheetState? state) {
                        if (state == null || state.students.isEmpty) {
                          return EmptyState(
                            icon: Icons.people_outline_rounded,
                            title: 'No students enrolled',
                            message: 'There are no students in $selectedClass yet. Add students to this class first.',
                          );
                        }

                        return Column(
                          children: <Widget>[
                            // Summary Strip + Bulk actions
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.md,
                                AppSpacing.xs,
                                AppSpacing.md,
                                AppSpacing.xs,
                              ),
                              child: Responsive.constrained(
                                child: Column(
                                  children: <Widget>[
                                    AttendanceSummaryStrip(
                                      presentCount: state.presentCount,
                                      absentCount: state.absentCount,
                                      unmarkedCount: state.unmarkedCount,
                                      totalStudents: state.students.length,
                                      isSavedRecord: state.hasSavedRecord,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    // Bulk helpers
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        TextButton.icon(
                                          icon: const Icon(Icons.done_all_rounded, size: 16),
                                          label: const Text('Mark All Present'),
                                          onPressed: () {
                                            ref
                                                .read(attendanceSheetProvider.notifier)
                                                .markAll(AttendanceStatus.present);
                                          },
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        TextButton.icon(
                                          icon: const Icon(Icons.remove_done_rounded, size: 16),
                                          label: const Text('Mark All Absent'),
                                          onPressed: () {
                                            ref
                                                .read(attendanceSheetProvider.notifier)
                                                .markAll(AttendanceStatus.absent);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Students attendance list
                            Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.md,
                                  0,
                                  AppSpacing.md,
                                  AppSpacing.md,
                                ),
                                itemCount: state.students.length,
                                separatorBuilder: (BuildContext context, int index) =>
                                    const SizedBox(height: AppSpacing.xs),
                                itemBuilder: (BuildContext context, int index) {
                                  final Student student = state.students[index];
                                  final AttendanceStatus? status = state.currentStatuses[student.id];

                                  return Responsive.constrained(
                                    child: AttendanceStudentTile(
                                      student: student,
                                      currentStatus: status,
                                      onStatusChanged: (AttendanceStatus newStatus) {
                                        ref
                                            .read(attendanceSheetProvider.notifier)
                                            .setStatus(student.id!, newStatus);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Sticky Bottom Save Button
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                border: Border(
                                  top: BorderSide(color: theme.colorScheme.outline),
                                ),
                              ),
                              child: Responsive.constrained(
                                maxWidth: 600,
                                child: ElevatedButton.icon(
                                  icon: state.isSaving
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                                          ),
                                        )
                                      : const Icon(Icons.save_rounded, size: 20),
                                  label: Text(
                                    state.isSaving
                                        ? 'Saving...'
                                        : (state.hasSavedRecord ? 'Update Attendance' : 'Save Attendance'),
                                  ),
                                  onPressed: state.canSave
                                      ? () async {
                                          await ref.read(attendanceSheetProvider.notifier).save();
                                          if (context.mounted) {
                                            AppSnackbar.showSuccess(
                                              context,
                                              'Attendance saved successfully for $selectedClass',
                                            );
                                          }
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
