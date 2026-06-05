import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mystic_loader.dart';
import '../../shared/presentation/result_screen.dart';
import 'providers/eye_provider.dart';

class EyeScreen extends ConsumerStatefulWidget {
  const EyeScreen({super.key});

  @override
  ConsumerState<EyeScreen> createState() => _EyeScreenState();
}

class _EyeScreenState extends ConsumerState<EyeScreen> {
  final TextEditingController _intentionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  // Fotoğraf kırpma fonksiyonu
  Future<XFile?> _cropImage(String path) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Fotoğrafı Kırp',
            toolbarColor: AppTheme.deepNavy,
            toolbarWidgetColor: AppTheme.gold,
            activeControlsWidgetColor: AppTheme.gold,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Fotoğrafı Kırp',
          ),
        ],
      );
      if (croppedFile != null) {
        return XFile(croppedFile.path);
      }
    } catch (e) {
      debugPrint("Kırpma hatası: $e");
    }
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final cropped = await _cropImage(pickedFile.path);
        if (cropped != null) {
          ref.read(eyeProvider.notifier).selectImage(cropped);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Görsel seçilirken hata oluştu: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eyeProvider);

    if (state.readingResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = state.readingResult!;
        ref.read(eyeProvider.notifier).clearImage();
        _intentionController.clear();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: "GÖZ FALI YORUMU",
              resultText: result,
            ),
          ),
        );
      });
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("GÖZ FALI"),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.spaceDark,
                  AppTheme.deepNavy,
                  AppTheme.spaceDark,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: GoogleFonts.lora(color: Colors.redAccent, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Text(
                      "Gözünüzün Fotoğrafı",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "(Kırpma penceresinden sadece gözünüzü odaklayarak seçin)",
                      style: GoogleFonts.lora(
                        color: AppTheme.goldLight.withOpacity(0.5),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showImageSourceBottomSheet(),
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: AppTheme.deepNavy,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: state.selectedImage != null
                                ? AppTheme.gold
                                : AppTheme.midnightBlue,
                            width: 1.5,
                          ),
                          image: state.selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(File(state.selectedImage!.path)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: state.selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye,
                                    color: AppTheme.gold.withOpacity(0.6),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Göz resmi seçip kırpmak için dokun",
                                    style: GoogleFonts.lora(
                                      color: AppTheme.goldLight.withOpacity(0.5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                alignment: Alignment.bottomRight,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: AppTheme.spaceDark,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () {
                                      ref.read(eyeProvider.notifier).clearImage();
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "Niyetiniz veya Sorunuz",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _intentionController,
                      maxLines: 4,
                      style: GoogleFonts.lora(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Zihnini boşalt, gözlerindeki kader ışığını okumak için niyetini buraya yaz...",
                        hintStyle: GoogleFonts.lora(color: Colors.white30, fontSize: 14),
                        fillColor: AppTheme.deepNavy,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.midnightBlue, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(eyeProvider.notifier).getReading(
                                _intentionController.text,
                              );
                        },
                        child: const Text("GÖZLERİMİ ANALİZ ET"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (state.isLoading)
          const MysticLoader(
            message: "Göz renginiz, iris desenleriniz og bakışınızdaki kozmik enerji çözümleniyor...",
          ),
      ],
    );
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.deepNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Göz Fotoğrafı Seç",
                  style: GoogleFonts.cinzel(
                    color: AppTheme.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppTheme.goldLight),
                  title: Text("Kamera ile Fotoğraf Çek", style: GoogleFonts.lora()),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppTheme.goldLight),
                  title: Text("Galeriden Fotoğraf Seç", style: GoogleFonts.lora()),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
