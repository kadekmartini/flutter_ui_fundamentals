
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import 'home_page.dart' show StudentIdentityBanner;

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
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color backgroundColor = Color(0xFFF4F8FC);
  static const Color textColor = Color(0xFF26364A);

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
      return 'Jumlah SKS wajib diisi';
    }

    final credits = int.tryParse(value.trim());

    if (credits == null || credits <= 0) {
      return 'Jumlah SKS harus berupa angka lebih dari 0';
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
          content: Text('ID kursus tidak ditemukan.'),
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

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Gagal memperbarui kursus: $error'
                : 'Gagal menambahkan kursus: $error',
          ),
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

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: primaryColor,
        size: 21,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE1E9F2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE1E9F2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 17,
      ),
    );
  }

  Widget _buildFormCard(bool isBusy) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8EEF5),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(
              icon: Icons.menu_book_rounded,
              title: 'Informasi Kursus',
              subtitle: 'Lengkapi informasi kursus di bawah ini.',
            ),
            const SizedBox(height: 25),
            TextFormField(
              controller: _codeController,
              readOnly: isEditing,
              enabled: !isBusy,
              textCapitalization: TextCapitalization.characters,
              decoration: _inputDecoration(
                label: 'Kode Kursus',
                hint: 'Contoh: PTI501',
                icon: Icons.tag_rounded,
              ),
              validator: (value) {
                return _validateRequired(value, 'Kode kursus');
              },
            ),
            const SizedBox(height: 19),
            TextFormField(
              controller: _titleController,
              enabled: !isBusy,
              textCapitalization: TextCapitalization.sentences,
              decoration: _inputDecoration(
                label: 'Nama Kursus',
                hint: 'Masukkan nama kursus',
                icon: Icons.book_outlined,
              ),
              validator: (value) {
                return _validateRequired(value, 'Nama kursus');
              },
            ),
            const SizedBox(height: 19),
            TextFormField(
              controller: _creditsController,
              enabled: !isBusy,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: _inputDecoration(
                label: 'Jumlah SKS',
                hint: 'Contoh: 3',
                icon: Icons.school_outlined,
              ),
              validator: _validateCredits,
            ),
            const SizedBox(height: 19),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: _inputDecoration(
                label: 'Status Kursus',
                hint: 'Pilih status kursus',
                icon: Icons.flag_outlined,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'planned',
                  child: Text('Terencana'),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Berjalan'),
                ),
                DropdownMenuItem(
                  value: 'done',
                  child: Text('Selesai'),
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
                  return 'Status kursus wajib dipilih';
                }

                return null;
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 51,
              child: FilledButton.icon(
                onPressed: isBusy ? null : _submitForm,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.blueGrey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: isBusy
                    ? const SizedBox(
                        width: 19,
                        height: 19,
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
                          : 'Tambahkan Kursus',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isEditing
                  ? 'Periksa kembali perubahan sebelum menyimpan.'
                  : 'Pastikan seluruh informasi kursus sudah benar.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF718096),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerSaving = context.watch<CourseProvider>().isSaving;
    final isBusy = _isSubmitting || providerSaving;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Kursus' : 'Tambah Kursus',
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const StudentIdentityBanner(),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(21),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1976D2),
                          Color(0xFF1255A0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.17),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isEditing
                                ? Icons.edit_note_rounded
                                : Icons.add_box_outlined,
                            color: Colors.white,
                            size: 29,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing
                                    ? 'Perbarui Informasi'
                                    : 'Buat Kursus Baru',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isEditing
                                    ? 'Ubah informasi kursus yang dipilih.'
                                    : 'Isi formulir untuk menambahkan kursus.',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 19),
                  _buildFormCard(isBusy),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
