import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class EditCoursePage extends StatefulWidget {
  const EditCoursePage({
    super.key,
    required this.course,
  });

  final Course course;

  @override
  State<EditCoursePage> createState() => _EditCoursePageState();
}

class _EditCoursePageState extends State<EditCoursePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;

  late String _selectedStatus;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _codeController = TextEditingController(
      text: widget.course.code,
    );

    _titleController = TextEditingController(
      text: widget.course.title,
    );

    _creditsController = TextEditingController(
      text: widget.course.credits.toString(),
    );

    _selectedStatus = widget.course.status;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }

    return null;
  }

  String? _validateCredits(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Credits wajib diisi';
    }

    final int? credits = int.tryParse(value.trim());

    if (credits == null) {
      return 'Credits harus berupa angka';
    }

    if (credits <= 0) {
      return 'Credits harus lebih dari 0';
    }

    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isSubmitting) {
      return;
    }

    final int? courseId = widget.course.id;

    if (courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Course tidak memiliki ID sehingga tidak dapat diedit.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final CourseProvider provider =
        context.read<CourseProvider>();

    final Course updatedCourse = Course(
      id: courseId,
      code: widget.course.code,
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _selectedStatus,
    );

    try {
      await provider.updateCourse(
        courseId,
        updatedCourse,
      );

      await provider.loadCourses();

      if (!mounted) {
        return;
      }

      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Course berhasil diperbarui, tetapi daftar gagal dimuat ulang.',
            ),
            backgroundColor: Colors.orange,
          ),
        );

        Navigator.of(context).pop(true);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Course ${updatedCourse.code} berhasil diperbarui!',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui course: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    final bool providerIsSaving =
        context.watch<CourseProvider>().isSaving;

    final bool isBusy = _isSubmitting || providerIsSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Course',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Kadek Martini Aristianti • 2415051004',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Perbarui Data Mata Kuliah',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ubah informasi yang diperlukan, lalu simpan.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _codeController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Kode Course',
                                helperText:
                                    'Kode tidak dapat diubah',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  _validateRequired(
                                value,
                                'Kode course',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              enabled: !isBusy,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                labelText: 'Nama Mata Kuliah',
                                prefixIcon: Icon(Icons.menu_book),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  _validateRequired(
                                value,
                                'Nama mata kuliah',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _creditsController,
                              enabled: !isBusy,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Credits / SKS',
                                prefixIcon:
                                    Icon(Icons.school_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: _validateCredits,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status Course',
                                prefixIcon: Icon(Icons.flag_outlined),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'planned',
                                  child: Text('Planned'),
                                ),
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem(
                                  value: 'done',
                                  child: Text('Done'),
                                ),
                              ],
                              onChanged: isBusy
                                  ? null
                                  : (value) {
                                      if (value == null) {
                                        return;
                                      }

                                      setState(() {
                                        _selectedStatus = value;
                                      });
                                    },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Status wajib dipilih';
                                }

                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed:
                                    isBusy ? null : _submitForm,
                                icon: isBusy
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.save_outlined),
                                label: Text(
                                  isBusy
                                      ? 'Menyimpan...'
                                      : 'Simpan Perubahan',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      Colors.blue.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}