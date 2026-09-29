import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/skeleton.dart';
import '../domain/teacher.dart';
import '../providers/teacher_providers.dart';
import 'teacher_form_screen.dart';
import 'widgets/teacher_card.dart';

class TeachersScreen extends ConsumerStatefulWidget {
  const TeachersScreen({super.key});

  @override
  ConsumerState<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends ConsumerState<TeachersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddForm() {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => const TeacherFormScreen(),
      ),
    );
  }

  void _openEditForm(Teacher teacher) {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => TeacherFormScreen(teacher: teacher),
      ),
    );
  }

  Future<void> _confirmDelete(Teacher teacher) async {
    final bool confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Teacher',
      message:
          'Are you sure you want to delete ${teacher.name} (${teacher.subject}, ID: ${teacher.employeeId})?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await ref.read(teacherListProvider.notifier).deleteTeacher(
            teacher.id!,
            teacherName: teacher.name,
          );

      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          'Teacher ${teacher.name} deleted',
          actionLabel: 'Undo',
          onAction: () async {
            // Restore teacher
            await ref.read(teacherListProvider.notifier).addTeacher(teacher);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to delete teacher: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<Teacher>> teachersAsync = ref.watch(teacherListProvider);
    final String currentQuery = ref.watch(teacherSearchProvider);
    final bool hasTeachers = (teachersAsync.valueOrNull ?? <Teacher>[]).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
      ),
      floatingActionButton: hasTeachers
          ? FloatingActionButton(
              heroTag: null,
              onPressed: _openAddForm,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: Column(
        children: <Widget>[
          // Search header
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
                hint: 'Search teachers...',
                onChanged: (String value) {
                  ref.read(teacherSearchProvider.notifier).state = value;
                },
                onClear: () {
                  ref.read(teacherSearchProvider.notifier).state = '';
                },
              ),
            ),
          ),
          // Teachers List or States
          Expanded(
            child: teachersAsync.when(
              loading: () => const SkeletonList(itemCount: 8),
              error: (Object err, _) => ErrorState(
                message: 'Failed to load teachers. Please try again.',
                onRetry: () => ref.invalidate(teacherListProvider),
              ),
              data: (List<Teacher> teachers) {
                final bool isFiltered = currentQuery.isNotEmpty;

                if (teachers.isEmpty) {
                  if (isFiltered) {
                    return EmptyState.noResults(
                      onClear: () {
                        _searchController.clear();
                        ref.read(teacherSearchProvider.notifier).state = '';
                      },
                    );
                  }
                  return EmptyState(
                    icon: Icons.badge_outlined,
                    title: 'No teachers yet',
                    message: 'Add faculty members to manage teachers and subjects.',
                    actionLabel: 'Add Teacher',
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
                        '${teachers.length} ${teachers.length == 1 ? 'teacher' : 'teachers'}',
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
                        itemCount: teachers.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (BuildContext context, int index) {
                          final Teacher teacher = teachers[index];
                          return Responsive.constrained(
                            child: TeacherCard(
                              teacher: teacher,
                              onEdit: () => _openEditForm(teacher),
                              onDelete: () => _confirmDelete(teacher),
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
