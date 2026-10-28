// Nama: Kadek Martini Aristianti
// NIM: 2415051004
// TAHAP 6: Form Tambah Course melalui HTTP POST

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() =>
      _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _codeController =
      TextEditingController();

  final TextEditingController _titleController =
      TextEditingController();

  final TextEditingController _creditsController =
      TextEditingController();

  String _selectedStatus = 'planned';

  // Mencegah pengiriman data berulang.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();

    super.dispose();
  }

  // ==========================================
  // VALIDASI INPUT
  // ==========================================

  String? _validateRequired(
    String? value,
    String label,
  ) {
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

  // ==========================================
  // MENYIMPAN COURSE MELALUI HTTP POST
  // ==========================================

  Future<void> _submitForm() async {
    // Pastikan seluruh input valid.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Mencegah submit ganda.
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Ambil provider sebelum proses asynchronous.
    final CourseProvider provider =
        context.read<CourseProvider>();

    // Membuat objek Course dari data formulir.
    final Course course = Course(
      code: _codeController.text.trim(),
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _selectedStatus,
    );

    try {
      // Alur: Screen -> Provider -> Repository -> Service.
      await provider.createCourse(course);

      // Refresh daftar setelah POST berhasil.
      await provider.loadCourses();

      // Periksa apakah State halaman masih aktif.
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Course ${course.code} berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Kembali ke halaman sebelumnya.
      Navigator.of(context).pop(true);
    } catch (e) {
      // Jangan gunakan context jika halaman sudah tidak aktif.
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menambahkan course: $e',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      // Hindari setState setelah widget dibuang.
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ==========================================
  // TAMPILAN FORM
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final bool providerIsSaving =
        context.watch<CourseProvider>().isSaving;

    final bool isBusy = _isSubmitting || providerIsSaving;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Course',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Identitas mahasiswa.
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
                    'Form Mata Kuliah',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Isi informasi course yang ingin ditambahkan.',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Card(
                    elevation: 2,
                    color: Colors.white,
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
                            // KODE COURSE
                            TextFormField(
                              controller: _codeController,
                              enabled: !isBusy,
                              textCapitalization:
                                  TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'Kode Course',
                                hintText: 'Contoh: MOB09',
                                prefixIcon: Icon(Icons.tag),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  _validateRequired(
                                value,
                                'Kode course',
                              ),
                            ),

                            const SizedBox(height: 16),

                            // NAMA MATA KULIAH
                            TextFormField(
                              controller: _titleController,
                              enabled: !isBusy,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                labelText: 'Nama Mata Kuliah',
                                hintText:
                                    'Contoh: Pemrograman Mobile',
                                prefixIcon:
                                    Icon(Icons.menu_book),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  _validateRequired(
                                value,
                                'Nama mata kuliah',
                              ),
                            ),

                            const SizedBox(height: 16),

                            // CREDITS / SKS
                            TextFormField(
                              controller: _creditsController,
                              enabled: !isBusy,
                              keyboardType:
                                  TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Credits / SKS',
                                hintText: 'Contoh: 3',
                                prefixIcon:
                                    Icon(Icons.school_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: _validateCredits,
                            ),

                            const SizedBox(height: 16),

                            // STATUS COURSE
                            DropdownButtonFormField<String>(
                              initialValue: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status Course',
                                prefixIcon:
                                    Icon(Icons.flag_outlined),
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
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Status wajib dipilih';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // TOMBOL SIMPAN
                            SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed:
                                    isBusy ? null : _submitForm,
                                icon: isBusy
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.save_outlined,
                                      ),
                                label: Text(
                                  isBusy
                                      ? 'Menyimpan...'
                                      : 'Simpan Course',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      Colors.blue.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
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