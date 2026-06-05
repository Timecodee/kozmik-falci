import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  EnvService._();

  static String get pollinationsApiKey {
    final key = dotenv.env['POLLINATIONS_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception("Hata: POLLINATIONS_API_KEY bulunamadı! Lütfen .env dosyasını kontrol edin.");
    }
    return key;
  }
}
