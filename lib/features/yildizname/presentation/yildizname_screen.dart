import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mystic_loader.dart';
import '../../shared/presentation/result_screen.dart';
import 'providers/yildizname_provider.dart';

class YildiznameScreen extends ConsumerStatefulWidget {
  const YildiznameScreen({super.key});

  @override
  ConsumerState<YildiznameScreen> createState() => _YildiznameScreenState();
}

class _YildiznameScreenState extends ConsumerState<YildiznameScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();
  final TextEditingController _birthHourController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _motherNameController.dispose();
    _fatherNameController.dispose();
    _birthDateController.dispose();
    _birthPlaceController.dispose();
    _birthHourController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ref.read(yildiznameProvider.notifier).getReading(
            name: _nameController.text,
            surname: _surnameController.text,
            motherName: _motherNameController.text,
            fatherName: _fatherNameController.text,
            birthDate: _birthDateController.text,
            birthPlace: _birthPlaceController.text,
            birthHour: _birthHourController.text.trim().isEmpty
                ? "Bilinmiyor"
                : _birthHourController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(yildiznameProvider);

    // Navigate to results
    if (state.readingResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = state.readingResult!;
        ref.read(yildiznameProvider.notifier).reset();
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              title: "YILDIZNAME YORUMU",
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
            title: const Text("YILDIZNAME FALI"),
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
                child: Form(
                  key: _formKey,
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
                          child: Text(
                            state.errorMessage!,
                            style: GoogleFonts.lora(color: Colors.redAccent, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      Text(
                        "Kişisel Yıldızname Bilgileri",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Yıldız haritanızın çıkarılması ve kaderinizin şifrelerinin çözülmesi için aşağıdaki alanları doldurun.",
                        style: GoogleFonts.lora(
                          color: AppTheme.goldLight.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Alanları
                      _buildTextField(
                        controller: _nameController,
                        label: "Adınız",
                        hint: "Adınızı girin",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _surnameController,
                        label: "Soyadınız",
                        hint: "Soyadınızı girin",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _motherNameController,
                        label: "Anne Adı",
                        hint: "Annenizin adını girin",
                        icon: Icons.woman,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _fatherNameController,
                        label: "Baba Adı",
                        hint: "Babanızın adını girin",
                        icon: Icons.man,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _birthDateController,
                        label: "Doğum Tarihi",
                        hint: "Doğum tarihinizi seçin",
                        icon: Icons.calendar_month,
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(1995, 8, 24),
                            firstDate: DateTime(1920),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppTheme.gold,
                                    onPrimary: AppTheme.spaceDark,
                                    surface: AppTheme.deepNavy,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _birthDateController.text =
                                  "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _birthPlaceController,
                        label: "Doğum Yeri",
                        hint: "İl ve İlçe (Örn: İstanbul, Kadıköy)",
                        icon: Icons.location_on,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _birthHourController,
                        label: "Doğum Saati",
                        hint: "Doğum saatinizi seçin veya boş bırakın",
                        icon: Icons.access_time,
                        readOnly: true,
                        isRequired: false,
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 12, minute: 0),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppTheme.gold,
                                    onPrimary: AppTheme.spaceDark,
                                    surface: AppTheme.deepNavy,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _birthHourController.text =
                                  "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 40),

                      // Yorumla Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text("YILDIZNAME RAPORU OLUŞTUR"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (state.isLoading)
          const MysticLoader(
            message: "Ebced hesaplamaları yapılıyor, yıldız konumları ve kader haritanız çıkarılıyor...",
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    VoidCallback? onTap,
    bool readOnly = false,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cinzel(
            color: AppTheme.goldLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return "Bu alan boş bırakılamaz";
            }
            return null;
          },
          style: GoogleFonts.lora(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.lora(color: Colors.white24, fontSize: 13),
            prefixIcon: Icon(icon, color: AppTheme.gold.withOpacity(0.6), size: 18),
            fillColor: AppTheme.deepNavy,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            errorStyle: GoogleFonts.lora(color: Colors.redAccent, fontSize: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.midnightBlue, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
