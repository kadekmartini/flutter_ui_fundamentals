
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseFormPage extends StatefulWidget {
  final Course? course;

  const CourseFormPage({
    super.key,
    this.course,
  });

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;

  late String _selectedStatus;
  bool _isSubmitting = false;

  bool get isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();

    _codeController = TextEditingController(
      text: widget.course?.code ?? '',
    );
    _titleController = TextEditingController(
      text: widget.course?.title ?? '',
    );
    _creditsController = TextEditingController(
      text: widget.course?.credits.toString() ?? '',
    );

    _selectedStatus = widget.course?.status ?? 'planned';
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

    final credits = int.tryParse(value.trim());

    if (credits == null || credits <= 0) {
      return 'Credits harus berupa angka lebih dari 0';
    }

    return null;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    if (isEditing && widget.course!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID course tidak ditemukan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<CourseProvider>();

    final course = Course(
      id: widget.course?.id,
      code: _codeController.text.trim(),
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _selectedStatus,
    );

    try {
      if (isEditing) {
        await provider.updateCourse(widget.course!.id!, course);
      } else {
        await provider.createCourse(course);
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Gagal memperbarui course: $error'
                : 'Gagal menambahkan course: $error',
          ),
          backgroundColor: Colors.red.shade700,
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
    final providerSaving = context.watch<CourseProvider>().isSaving;
    final isBusy = _isSubmitting || providerSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Course' : 'Tambah Course'),
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
                      color: const Color(0xFFEEF5FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '2415051004 • Kadek Martini Aristianti',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23496D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _codeController,
                              readOnly: isEditing,
                              enabled: !isBusy,
                              decoration: const InputDecoration(
                                labelText: 'Kode Course',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  _validateRequired(value, 'Kode course'),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _titleController,
                              enabled: !isBusy,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                labelText: 'Judul Course',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  _validateRequired(value, 'Judul course'),
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
                                border: OutlineInputBorder(),
                              ),
                              validator: _validateCredits,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status Course',
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
                                      if (value != null) {
                                        setState(() {
                                          _selectedStatus = value;
                                        });
                                      }
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
                              child: FilledButton.icon(
                                onPressed: isBusy ? null : _submitForm,
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
                                      : isEditing
                                          ? 'Simpan Perubahan'
                                          : 'Simpan Course',
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
