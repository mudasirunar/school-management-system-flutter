import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/filter_chips_row.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/skeleton.dart';
import '../domain/student.dart';
import '../providers/student_providers.dart';
import 'student_form_screen.dart';
import 'widgets/student_card.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddForm() {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const StudentFormScreen(),
      ),
    );
  }

  void _openEditForm(Student student) {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => StudentFormScreen(student: student),
      ),
    );
  }

  Future<void> _confirmDelete(Student student) async {
    final bool confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Student',
      message:
          'Are you sure you want to delete ${student.name} (Roll: ${student.rollNumber})? This will also remove all associated attendance records.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await ref.read(studentListProvider.notifier).deleteStudent(
            student.id!,
            studentName: student.name,
          );

      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          'Student ${student.name} deleted',
          actionLabel: 'Undo',
          onAction: () async {
            // Restore student
            await ref.read(studentListProvider.notifier).addStudent(student);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to delete student: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<Student>> studentsAsync = ref.watch(studentListProvider);
    final AsyncValue<List<String>> classesAsync = ref.watch(studentClassListProvider);
    final String currentQuery = ref.watch(studentSearchProvider);
    final String? currentClassFilter = ref.watch(studentClassFilterProvider);

    final bool hasStudents = (studentsAsync.valueOrNull ?? <Student>[]).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      floatingActionButton: hasStudents
          ? FloatingActionButton(
              onPressed: _openAddForm,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: Column(
        children: <Widget>[
          // Search & Filter header
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
                hint: 'Search students...',
                onChanged: (String value) {
                  ref.read(studentSearchProvider.notifier).state = value;
                },
                onClear: () {
                  ref.read(studentSearchProvider.notifier).state = '';
                },
              ),
            ),
          ),
          // Class Filter Chips
          classesAsync.when(
            data: (List<String> classes) {
              if (classes.isEmpty) return const SizedBox.shrink();

              final List<FilterItem<String?>> filterItems = <FilterItem<String?>>[
                const FilterItem<String?>(label: 'All Classes', value: null),
                ...classes.map(
                  (String c) => FilterItem<String?>(label: c, value: c),
                ),
              ];

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: FilterChipsRow<String?>(
                  items: filterItems,
                  selectedValue: currentClassFilter,
                  onSelected: (String? selected) {
                    ref.read(studentClassFilterProvider.notifier).state = selected;
                  },
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (Object _, StackTrace _) => const SizedBox.shrink(),
          ),
          // Students List or States
          Expanded(
            child: studentsAsync.when(
              loading: () => const SkeletonList(itemCount: 8),
              error: (Object err, _) => ErrorState(
                message: 'Failed to load students. Please try again.',
                onRetry: () => ref.invalidate(studentListProvider),
              ),
              data: (List<Student> students) {
                final bool isFiltered = currentQuery.isNotEmpty || currentClassFilter != null;

                if (students.isEmpty) {
                  if (isFiltered) {
                    return EmptyState.noResults(
                      onClear: () {
                        _searchController.clear();
                        ref.read(studentSearchProvider.notifier).state = '';
                        ref.read(studentClassFilterProvider.notifier).state = null;
                      },
                    );
                  }
                  return EmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'No students yet',
                    message: 'Add your first student to get started with attendance tracking.',
                    actionLabel: 'Add Student',
                    onAction: _openAddForm,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Count indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xxs,
                      ),
                      child: Text(
                        '${students.length} ${students.length == 1 ? 'student' : 'students'}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          88, // bottom padding for FAB
                        ),
                        itemCount: students.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (BuildContext context, int index) {
                          final Student student = students[index];
                          return Responsive.constrained(
                            child: StudentCard(
                              student: student,
                              onEdit: () => _openEditForm(student),
                              onDelete: () => _confirmDelete(student),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
