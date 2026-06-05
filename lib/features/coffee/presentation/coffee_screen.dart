import 'dart:io';
import 'package:flutter/material';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mystic_loader.dart';
import '../../shared/presentation/result_screen.dart';
import 'providers/coffee_provider.dart';

class CoffeeScreen extends ConsumerStatefulWidget {
  const CoffeeScreen({super.key});

  @override
  ConsumerState<CoffeeScreen> createState() => _CoffeeScreenState();
}

class _CoffeeScreenState extends ConsumerState<CoffeeScreen> {
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

  // Fotoğraf çekme / seçme fonksiyonu
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
          ref.read(coffeeProvider.notifier).selectImage(cropped);
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
    final state = ref.watch(coffeeProvider);

    if (state.readingResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = state.readingResult!;
        ref.read(coffeeProvider.notifier).clearImage();
        _intentionController.clear();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: "KAHVE FALI YORUMU",
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
            title: const Text("KAHVE FALI"),
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
                      "Fincanın Fotoğrafı",
                      style: Theme.of(context).textTheme.titleLarge,
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
                                    Icons.add_a_photo,
                                    color: AppTheme.gold.withOpacity(0.6),
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Fincan resmini seçip kırpmak için dokun",
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
                                      ref.read(coffeeProvider.notifier).clearImage();
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      "Fal Niyeti",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _intentionController,
                      maxLines: 4,
                      style: GoogleFonts.lora(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Zihnini boşalt, niyetine odaklan ve buraya yaz... (Örn: Aşk hayatım, geleceğim veya iş durumum...)",
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
                          ref.read(coffeeProvider.notifier).getReading(
                                _intentionController.text,
                              );
                        },
                        child: const Text("FALIMI YORUMLA"),
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
            message: "Fincanın derinliklerine iniliyor, kahve telvelerinin gizemi çözülüyor...",
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
                  "Fincan Fotoğrafı Seç",
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
