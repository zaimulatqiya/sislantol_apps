import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/laporan/laporan_bloc.dart';
import '../../blocs/laporan/laporan_event.dart';
import '../../blocs/laporan/laporan_state.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class LaporScreen extends StatefulWidget {
  const LaporScreen({super.key});

  @override
  State<LaporScreen> createState() => _LaporScreenState();
}

class _LaporScreenState extends State<LaporScreen> {
  String _jenisKejadian = 'mogok';
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _jenisKejadianLainnyaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  void _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> images = await _picker.pickMultiImage();
        if (images.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(images);
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            _selectedImages.add(image);
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Galeri Foto', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Kamera', style: TextStyle(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _jenisKejadianLainnyaController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthSuccess) {
        List<String>? finalFotoPaths;
        if (_selectedImages.isNotEmpty) {
          finalFotoPaths = _selectedImages.map((file) => file.path).toList();
        }

        if (!mounted) return;
        
        final String jenisKejadianKirim = _jenisKejadian == 'lainnya' 
            ? _jenisKejadianLainnyaController.text 
            : _jenisKejadian;

        context.read<LaporanBloc>().add(
              SubmitLaporan(
                userId: authState.user.id,
                pelaporNama: authState.user.nama,
                pelaporNoHp: authState.user.noHp,
                jenisKejadian: jenisKejadianKirim,
                lokasi: _lokasiController.text,
                deskripsi: _deskripsiController.text,
                fotoPaths: finalFotoPaths,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Laporan',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: BlocListener<LaporanBloc, LaporanState>(
        listener: (context, state) {
          if (state is LaporanSubmitSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                icon: const Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 48),
                title: const Text('Laporan Berhasil',
                    style: TextStyle(fontSize: 16)),
                content: const Text(
                  'Laporan Anda telah berhasil dikirim dan sedang menunggu respon dari petugas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
                actions: [
                  CustomButton(
                    label: 'Kembali ke Beranda',
                    onPressed: () {
                      Navigator.of(context).pop(); // Close Dialog
                      Navigator.of(context).pop(); // Go back to Home
                    },
                  )
                ],
              ),
            );
          } else if (state is LaporanFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_jenisKejadian == 'lainnya') ...[
                    CustomTextField(
                      label: 'Jenis Kejadian',
                      hint: 'Ketik jenis kejadian...',
                      controller: _jenisKejadianLainnyaController,
                      validator: (val) => (val == null || val.isEmpty)
                          ? 'Jenis kejadian wajib diisi'
                          : null,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textHint),
                        onPressed: () {
                          setState(() {
                            _jenisKejadian = 'mogok';
                            _jenisKejadianLainnyaController.clear();
                          });
                        },
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Jenis Kejadian',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBody),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _jenisKejadian,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 8,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textHint),
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500),
                          items: const [
                            DropdownMenuItem(
                                value: 'mogok', child: Text('Kendaraan Mogok')),
                            DropdownMenuItem(
                                value: 'kecelakaan',
                                child: Text('Kecelakaan lalu lintas')),
                            DropdownMenuItem(
                                value: 'hambatan',
                                child:
                                    Text('Hambatan di jalan (Ban Pecah, dll)')),
                            DropdownMenuItem(
                                value: 'lainnya', child: Text('Lainnya')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _jenisKejadian = val);
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Lokasi Kejadian',
                    hint: 'Misal: KM 12 Tol Sby-Gmpl',
                    controller: _lokasiController,
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Lokasi wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Deskripsi Tambahan',
                    hint: 'Jelaskan kondisi dengan detail',
                    controller: _deskripsiController,
                    maxLines: 4,
                    maxLength: 300,
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Deskripsi wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Simulated Photo Picker
                  const Text(
                    'Foto Bukti (Opsional)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBody),
                  ),
                  const SizedBox(height: 12),

                  // Image Preview List
                  if (_selectedImages.isNotEmpty) ...[
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _selectedImages.length) {
                            // Add button at the end
                            return GestureDetector(
                              onTap: _showImageSourceActionSheet,
                              child: Container(
                                width: 90,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.border,
                                      width: 1,
                                      style: BorderStyle.solid),
                                ),
                                child: const Icon(Icons.add_a_photo_outlined,
                                    color: AppColors.primary, size: 24),
                              ),
                            );
                          }

                          return Stack(
                            children: [
                              Container(
                                width: 90,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.border, width: 0.5),
                                  image: DecorationImage(
                                    image: FileImage(File(_selectedImages[index].path)) as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    // Empty state (Original Container updated for picking)
                    GestureDetector(
                      onTap: _showImageSourceActionSheet,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1.5,
                              style: BorderStyle.solid),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2))
                                    ]),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(height: 12),
                              const Text('Ketuk untuk menambah foto',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  BlocBuilder<LaporanBloc, LaporanState>(
                    builder: (context, state) {
                      return CustomButton(
                        label: 'KIRIM LAPORAN',
                        isLoading: state is LaporanLoading,
                        onPressed: _submit,
                      );
                    },
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
