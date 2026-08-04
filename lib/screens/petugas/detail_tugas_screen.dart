import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/penugasan_model.dart';
import '../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/penugasan/penugasan_bloc.dart';
import '../../blocs/penugasan/penugasan_event.dart';
import '../../blocs/penugasan/penugasan_state.dart';
import '../../widgets/common/badge_status.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/network_ui_helper.dart';

class DetailTugasScreen extends StatefulWidget {
  const DetailTugasScreen({super.key});

  @override
  State<DetailTugasScreen> createState() => _DetailTugasScreenState();
}

class _DetailTugasScreenState extends State<DetailTugasScreen> {
  final _catatanPenutupController = TextEditingController();
  late PenugasanModel _tugas;
  bool _isInit = false;

  ImageProvider _getImageProvider(String url) {
    if (kIsWeb) return NetworkImage(url);
    if (url.startsWith('data:image')) return MemoryImage(base64Decode(url.split(',').last));
    if (url.startsWith('http')) return NetworkImage(url);
    return FileImage(File(url));
  }

  void _showImagePreview(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image(
                image: _getImageProvider(url),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _tugas = ModalRoute.of(context)!.settings.arguments as PenugasanModel;
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _catatanPenutupController.dispose();
    super.dispose();
  }

  void _showSelesaikanBottomSheet(BuildContext context, PenugasanModel tugas, String petugasId) {
    List<XFile> pickedImages = [];
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void pickImage(ImageSource source) async {
              try {
                if (source == ImageSource.gallery) {
                  final List<XFile> images = await picker.pickMultiImage();
                  if (images.isNotEmpty) {
                    setModalState(() {
                      pickedImages.addAll(images);
                    });
                  }
                } else {
                  final XFile? image = await picker.pickImage(source: source);
                  if (image != null) {
                    setModalState(() {
                      pickedImages.add(image);
                    });
                  }
                }
              } catch (e) {
                debugPrint('Error picking image: $e');
              }
            }

            void showImageSourceActionSheet() {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                builder: (context) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library, color: AppColors.primary),
                        title: const Text('Galeri Foto', style: TextStyle(fontSize: 14)),
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(ImageSource.gallery);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                        title: const Text('Kamera', style: TextStyle(fontSize: 14)),
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
                top: 24,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Selesaikan Tugas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textHint),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload Foto Bukti Selesai (Wajib)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textBody),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      if (pickedImages.isEmpty) {
                        showImageSourceActionSheet();
                      }
                    },
                    child: pickedImages.isNotEmpty 
                      ? SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: pickedImages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == pickedImages.length) {
                                return GestureDetector(
                                  onTap: showImageSourceActionSheet,
                                  child: Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(left: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5, style: BorderStyle.solid),
                                    ),
                                    child: const Center(child: Icon(Icons.add_a_photo, color: AppColors.primary)),
                                  ),
                                );
                              }
                              return Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    margin: EdgeInsets.only(right: index < pickedImages.length - 1 ? 12 : 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: FileImage(File(pickedImages[index].path)) as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: index < pickedImages.length - 1 ? 16 : 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          pickedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5, style: BorderStyle.solid),
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
                                      BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
                                    ]
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 28),
                                ),
                                const SizedBox(height: 12),
                                const Text('Ambil foto dari kamera / galeri', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              ],
                            ),
                          ),
                        ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Catatan Penutup (Opsional)',
                    hint: 'Masukkan keterangan selesai...',
                    controller: _catatanPenutupController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<PenugasanBloc, PenugasanState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: 'KIRIM & SELESAIKAN',
                          isLoading: state is PenugasanLoading,
                          onPressed: () async {
                            if (pickedImages.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Minimal satu foto bukti wajib dilampirkan'), backgroundColor: AppColors.danger)
                              );
                              return;
                            }
                            
                            context.read<PenugasanBloc>().add(
                                  SelesaikanTugas(
                                    penugasanId: tugas.id,
                                    fotoPaths: pickedImages.map((e) => e.path).toList(),
                                    catatanPenutup: _catatanPenutupController.text,
                                    petugasId: petugasId,
                                  ),
                                );
                            // Hapus Navigator.pop di sini agar tidak langsung tertutup sebelum proses selesai.
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String petugasId = context.read<AuthBloc>().state is AuthSuccess 
        ? (context.read<AuthBloc>().state as AuthSuccess).user.id 
        : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Penugasan', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: BlocConsumer<PenugasanBloc, PenugasanState>(
        listener: (context, state) {
          if (state is PenugasanUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
                elevation: 8,
                duration: const Duration(seconds: 3),
              ),
            );
            if (state.message.contains('diselesaikan')) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          } else if (state is PenugasanFailure) {
            NetworkUIHelper.showNetworkErrorModal(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is PenugasanLoaded) {
            try {
              _tugas = state.aktif.firstWhere((t) => t.id == _tugas.id);
            } catch (e) {
              try {
                _tugas = state.selesai.firstWhere((t) => t.id == _tugas.id);
              } catch (e) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tugas telah dihapus atau tidak ditemukan.'),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                });
                return const Center(child: CircularProgressIndicator());
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Detail Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ID Laporan: #${_tugas.laporanId}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textHint, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _tugas.pelaporNama ?? 'Tanpa Nama',
                                style: const TextStyle(fontSize: 18, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          BadgeStatus(status: _tugas.status),
                        ],
                      ),
                      const Divider(height: 32, color: AppColors.border),
                      _buildInfoRow('Jenis Kejadian', _tugas.displayJenisKejadian.toUpperCase(), Icons.warning_amber_rounded),
                      const SizedBox(height: 16),
                      _buildInfoRow('Nomor Polisi', _tugas.nomorPolisi ?? '-', Icons.directions_car_outlined),
                      const SizedBox(height: 16),
                      _buildInfoRow('Lokasi', _tugas.lokasi, Icons.location_on_outlined),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Icons.description_outlined, size: 18, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Text('Deskripsi Pengguna', style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _tugas.displayDeskripsi.isEmpty ? 'Tidak ada deskripsi tambahan.' : _tugas.displayDeskripsi,
                        style: TextStyle(
                          fontSize: 14, 
                          color: _tugas.displayDeskripsi.isEmpty ? AppColors.textHint : AppColors.textPrimary, 
                          fontStyle: _tugas.displayDeskripsi.isEmpty ? FontStyle.italic : FontStyle.normal,
                          height: 1.5
                        ),
                      ),
                      
                      if (_tugas.fotoKejadianUrls != null && _tugas.fotoKejadianUrls!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Icon(Icons.image_outlined, size: 18, color: AppColors.textMuted),
                            SizedBox(width: 8),
                            Text('Foto Kejadian', style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _tugas.fotoKejadianUrls!.length,
                            itemBuilder: (context, index) {
                              final String url = _tugas.fotoKejadianUrls![index];
                              return GestureDetector(
                                onTap: () => _showImagePreview(context, url),
                                child: Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                    image: DecorationImage(
                                      image: _getImageProvider(url),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.badgeAssignBg.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.badgeAssignText.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: AppColors.badgeAssignText),
                                SizedBox(width: 6),
                                Text('Catatan Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.badgeAssignText)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _tugas.catatanAdmin.isEmpty ? 'Tidak ada catatan tambahan dari Admin.' : _tugas.catatanAdmin,
                              style: TextStyle(
                                fontSize: 13, 
                                color: _tugas.catatanAdmin.isEmpty ? AppColors.badgeAssignText.withOpacity(0.6) : AppColors.textPrimary, 
                                fontStyle: _tugas.catatanAdmin.isEmpty ? FontStyle.italic : FontStyle.normal,
                                height: 1.5
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Progress Tracker
                _buildProgressTracker(_tugas.status),
                
                const SizedBox(height: 24),
                
                // Action Status Area
                const Text(
                  'Update Status Penanganan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 16),
                _buildDynamicActionButton(context, _tugas, petugasId)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDynamicActionButton(BuildContext context, PenugasanModel tugas, String petugasId) {
    final currentStatus = tugas.status.trim().toLowerCase();

    if (currentStatus == 'selesai') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'TUGAS SELESAI',
            style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (currentStatus == 'dibatalkan') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'TUGAS DIBATALKAN',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
    
    String label = '';
    String nextStatus = '';
    Color btnColor = AppColors.primary;
    
    switch (currentStatus) {
      case 'aktif':
      case 'ditugaskan':
        label = 'KONFIRMASI TERIMA TUGAS';
        nextStatus = 'diterima';
        break;
      case 'diterima':
        label = 'MENUJU LOKASI';
        nextStatus = 'menuju';
        btnColor = AppColors.badgeAssignText;
        break;
      case 'menuju':
        label = 'SUDAH TIBA DI LOKASI';
        nextStatus = 'tiba';
        btnColor = AppColors.badgeAssignText;
        break;
      case 'tiba':
        label = 'MULAI PENANGANAN';
        nextStatus = 'proses';
        btnColor = AppColors.badgeProcessText;
        break;
      case 'proses':
        label = 'SELESAIKAN TUGAS';
        nextStatus = 'selesai';
        btnColor = AppColors.success;
        break;
    }

    if (nextStatus.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            'STATUS TIDAK DIKENALI: "$currentStatus"',
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return CustomButton(
      label: label,
      color: btnColor,
      onPressed: () {
        if (nextStatus == 'selesai') {
          _showSelesaikanBottomSheet(context, tugas, petugasId);
        } else {
          context.read<PenugasanBloc>().add(
            UpdateStatusPenugasan(penugasanId: tugas.id, statusBaru: nextStatus, petugasId: petugasId)
          );
        }
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTracker(String currentStatus) {
    final statuses = [
      {'key': 'ditugaskan', 'label': 'Ditugaskan'},
      {'key': 'diterima', 'label': 'Diterima'},
      {'key': 'menuju', 'label': 'Menuju Lokasi'},
      {'key': 'tiba', 'label': 'Tiba di Lokasi'},
      {'key': 'proses', 'label': 'Diproses'},
      {'key': 'selesai', 'label': 'Selesai'},
    ];
    
    final currentIndex = _getStatusIndex(currentStatus);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.5), shape: BoxShape.circle),
                child: const Icon(Icons.timeline, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 12),
              const Text('Progress Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(statuses.length, (index) {
            final isDone = index < currentIndex || currentStatus.toLowerCase() == 'selesai';
            final isActive = index == currentIndex && currentStatus.toLowerCase() != 'selesai';
            final isLast = index == statuses.length - 1;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.success : (isActive ? AppColors.primary : Colors.grey.shade100),
                        shape: BoxShape.circle,
                        border: isActive ? Border.all(color: AppColors.primaryLight, width: 4) : Border.all(color: isDone ? AppColors.success : Colors.grey.shade300, width: 1.5),
                      ),
                      child: isDone
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : (isActive ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)))),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: isDone ? AppColors.success : Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: isLast ? 28 : 64,
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      statuses[index]['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.bold : (isDone ? FontWeight.w600 : FontWeight.w500),
                        color: isActive ? AppColors.textPrimary : (isDone ? AppColors.textPrimary.withOpacity(0.8) : AppColors.textHint),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  int _getStatusIndex(String status) {
    const statuses = ['ditugaskan', 'diterima', 'menuju', 'tiba', 'proses', 'selesai'];
    final idx = statuses.indexOf(status.toLowerCase());
    return idx == -1 ? 0 : idx;
  }
}
