import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../domain/teacher.dart';
import '../providers/teacher_providers.dart';

class TeacherFormScreen extends ConsumerStatefulWidget {
  const TeacherFormScreen({
    super.key,
    this.teacher,
  });

  final Teacher? teacher;

  bool get isEditing => teacher != null;

  @override
  ConsumerState<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends ConsumerState<TeacherFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _employeeIdController;
  late final TextEditingController _subjectController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;

  bool _isSubmitting = false;
  bool _submittedOnce = false;
  String? _employeeIdError;

  @override
  void initState() {
    super.initState();
    final Teacher? t = widget.teacher;
    _nameController = TextEditingController(text: t?.name ?? '');
    _employeeIdController = TextEditingController(text: t?.employeeId ?? '');
    _subjectController = TextEditingController(text: t?.subject ?? '');
    _contactController = TextEditingController(text: t?.contact ?? '');
    _emailController = TextEditingController(text: t?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _subjectController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    final Teacher? t = widget.teacher;
    if (t == null) {
      return _nameController.text.isNotEmpty ||
          _employeeIdController.text.isNotEmpty ||
          _subjectController.text.isNotEmpty ||
          _contactController.text.isNotEmpty ||
          _emailController.text.isNotEmpty;
    }
    return _nameController.text != t.name ||
        _employeeIdController.text != t.employeeId ||
        _subjectController.text != t.subject ||
        _contactController.text != t.contact ||
        _emailController.text != t.email;
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges()) return true;
    return ConfirmDialog.show(
      context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      isDestructive: true,
    );
  }

  Future<void> _submit() async {
    setState(() {
      _submittedOnce = true;
      _employeeIdError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String now = DateTime.now().toIso8601String();

      final Teacher teacherToSave = Teacher(
        id: widget.teacher?.id,
        name: _nameController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
        subject: _subjectController.text.trim(),
        contact: _contactController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        createdAt: widget.teacher?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.isEditing) {
        await ref.read(teacherListProvider.notifier).updateTeacher(teacherToSave);
        if (mounted) {
          AppSnackbar.showSuccess(context, 'Teacher updated successfully');
          Navigator.of(context).pop(true);
        }
      } else {
        await ref.read(teacherListProvider.notifier).addTeacher(teacherToSave);
        if (mounted) {
          AppSnackbar.showSuccess(context, 'Teacher added successfully');
          Navigator.of(context).pop(true);
        }
      }
    } on DuplicateException catch (e) {
      if (e.field == 'employee_id') {
        setState(() {
          _employeeIdError = 'Employee ID already exists';
        });
      } else if (mounted) {
        AppSnackbar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to save teacher: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final bool shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Teacher' : 'Add Teacher'),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: Responsive.screenPadding(context),
                  child: Responsive.constrained(
                    maxWidth: 600,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _submittedOnce
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'e.g. Dr. Ahmed Hassan',
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                            validator: Validators.validateName,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _employeeIdController,
                            label: 'Employee ID',
                            hint: 'e.g. EMP-101',
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.characters,
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                            errorText: _employeeIdError,
                            validator: (String? val) {
                              if (_employeeIdError != null) return _employeeIdError;
                              return Validators.validateEmployeeId(val);
                            },
                            onChanged: (_) {
                              if (_employeeIdError != null) {
                                setState(() {
                                  _employeeIdError = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _subjectController,
                            label: 'Subject',
                            hint: 'e.g. Mathematics, Physics, English',
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: const Icon(Icons.menu_book_outlined, size: 20),
                            validator: Validators.validateSubject,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _contactController,
                            label: 'Contact Number',
                            hint: 'e.g. +923001234567',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            validator: Validators.validateContact,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'e.g. ahmed.hassan@school.edu.pk',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Sticky Bottom Save Action
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
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                            ),
                          )
                        : Text(widget.isEditing ? 'Update Teacher' : 'Save Teacher'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
