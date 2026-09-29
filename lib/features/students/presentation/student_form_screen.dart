import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../domain/student.dart';
import '../providers/student_providers.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({
    super.key,
    this.student,
  });

  final Student? student;

  bool get isEditing => student != null;

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _rollNumberController;
  late final TextEditingController _ageController;
  late final TextEditingController _contactController;

  String? _selectedClass;
  String _selectedGender = 'Male';
  bool _isSubmitting = false;
  bool _submittedOnce = false;
  String? _rollNumberError;

  @override
  void initState() {
    super.initState();
    final Student? s = widget.student;
    _nameController = TextEditingController(text: s?.name ?? '');
    _rollNumberController = TextEditingController(text: s?.rollNumber ?? '');
    _ageController = TextEditingController(text: s != null ? s.age.toString() : '');
    _contactController = TextEditingController(text: s?.contact ?? '');
    _selectedClass = s?.className ?? AppConstants.classes.first;
    _selectedGender = s?.gender ?? 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollNumberController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    final Student? s = widget.student;
    if (s == null) {
      return _nameController.text.isNotEmpty ||
          _rollNumberController.text.isNotEmpty ||
          _ageController.text.isNotEmpty ||
          _contactController.text.isNotEmpty;
    }
    return _nameController.text != s.name ||
        _rollNumberController.text != s.rollNumber ||
        _ageController.text != s.age.toString() ||
        _contactController.text != s.contact ||
        _selectedClass != s.className ||
        _selectedGender != s.gender;
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
      _rollNumberError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String now = DateTime.now().toIso8601String();
      final int age = int.parse(_ageController.text.trim());

      final Student studentToSave = Student(
        id: widget.student?.id,
        name: _nameController.text.trim(),
        rollNumber: _rollNumberController.text.trim(),
        className: _selectedClass!,
        age: age,
        gender: _selectedGender,
        contact: _contactController.text.trim(),
        createdAt: widget.student?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.isEditing) {
        await ref.read(studentListProvider.notifier).updateStudent(studentToSave);
        if (mounted) {
          AppSnackbar.showSuccess(context, 'Student updated successfully');
          Navigator.of(context).pop(true);
        }
      } else {
        await ref.read(studentListProvider.notifier).addStudent(studentToSave);
        if (mounted) {
          AppSnackbar.showSuccess(context, 'Student added successfully');
          Navigator.of(context).pop(true);
        }
      }
    } on DuplicateException catch (e) {
      if (e.field == 'roll_number') {
        setState(() {
          _rollNumberError = 'Roll number already exists';
        });
      } else if (mounted) {
        AppSnackbar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to save student: ${e.toString()}');
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
          title: Text(widget.isEditing ? 'Edit Student' : 'Add Student'),
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
                            hint: 'e.g. Ali Khan',
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                            validator: Validators.validateName,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _rollNumberController,
                            label: 'Roll Number',
                            hint: 'e.g. 101 or CS-21',
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.characters,
                            prefixIcon: const Icon(Icons.pin_outlined, size: 20),
                            errorText: _rollNumberError,
                            validator: (String? val) {
                              if (_rollNumberError != null) return _rollNumberError;
                              return Validators.validateRollNumber(val);
                            },
                            onChanged: (_) {
                              if (_rollNumberError != null) {
                                setState(() {
                                  _rollNumberError = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Class Dropdown
                          Text(
                            'Class',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedClass,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.class_outlined, size: 20),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.md,
                              ),
                            ),
                            items: AppConstants.classes.map((String c) {
                              return DropdownMenuItem<String>(
                                value: c,
                                child: Text(c),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedClass = value;
                              });
                            },
                            validator: Validators.validateClass,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _ageController,
                            label: 'Age',
                            hint: '3 to 25',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            prefixIcon: const Icon(Icons.cake_outlined, size: 20),
                            validator: Validators.validateAge,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Gender Selector
                          Text(
                            'Gender',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<String>(
                              segments: AppConstants.genders.map((String g) {
                                return ButtonSegment<String>(
                                  value: g,
                                  label: Text(g),
                                );
                              }).toList(),
                              selected: <String>{_selectedGender},
                              onSelectionChanged: (Set<String> newSelection) {
                                setState(() {
                                  _selectedGender = newSelection.first;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _contactController,
                            label: 'Contact Number',
                            hint: 'e.g. +923001234567',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            validator: Validators.validateContact,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Sticky Bottom Action
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
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(widget.isEditing ? 'Update Student' : 'Save Student'),
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
