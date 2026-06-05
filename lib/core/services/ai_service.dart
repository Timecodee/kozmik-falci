import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService {
  final http.Client _client;
  static const String _baseUrl = 'https://gen.pollinations.ai/v1/chat/completions';

  AiService({http.Client? client}) : _client = client ?? http.Client();

  // API Key RAM storage and state management
  static final ValueNotifier<bool> allKeysExhausted = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isLoadingKeys = ValueNotifier<bool>(true);
  static final List<String> apiKeys = [];
  static int currentKeyIndex = 0;

  // Initialize and load keys from URL
  static Future<void> initApiKeys() async {
    isLoadingKeys.value = true;
    try {
      final response = await http.get(Uri.parse('https://1layf.com/fal/api.json'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        apiKeys.clear();
        for (var item in jsonList) {
          if (item is String && item.isNotEmpty) {
            apiKeys.add(item);
          }
        }
        currentKeyIndex = 0;
        if (apiKeys.isEmpty) {
          allKeysExhausted.value = true;
        } else {
          allKeysExhausted.value = false;
        }
      } else {
        allKeysExhausted.value = true;
      }
    } catch (e) {
      allKeysExhausted.value = true;
      debugPrint("Failed to load API keys: $e");
    } finally {
      isLoadingKeys.value = false;
    }
  }

  // Robust POST request wrapper with sequential API key rotation on 401/402 responses
  Future<http.Response> _post(Map<String, dynamic> body) async {
    // Wait for keys if loading
    int waitCount = 0;
    while (isLoadingKeys.value && waitCount < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      waitCount++;
    }

    if (apiKeys.isEmpty || allKeysExhausted.value) {
      allKeysExhausted.value = true;
      throw Exception("Tüm falcılar şu an dolu.");
    }

    while (currentKeyIndex < apiKeys.length) {
      final apiKey = apiKeys[currentKeyIndex];
      final headers = {
        'Content-Type': 'application/json',
      };
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      try {
        final response = await _client.post(
          Uri.parse(_baseUrl),
          headers: headers,
          body: jsonEncode(body),
        );

        if (response.statusCode == 401 || response.statusCode == 402) {
          debugPrint("API key at index $currentKeyIndex failed (status ${response.statusCode}). Rotating key...");
          currentKeyIndex++;
          if (currentKeyIndex >= apiKeys.length) {
            allKeysExhausted.value = true;
            throw Exception("Tüm falcılar şu an dolu.");
          }
          continue; // try next key
        }

        return response;
      } catch (e) {
        debugPrint("Request failed with key at index $currentKeyIndex: $e. Rotating key...");
        currentKeyIndex++;
        if (currentKeyIndex >= apiKeys.length) {
          allKeysExhausted.value = true;
          throw Exception("Tüm falcılar şu an dolu.");
        }
        continue; // try next key
      }
    }

    allKeysExhausted.value = true;
    throw Exception("Tüm falcılar şu an dolu.");
  }

  // Mistik Sistem Promptu
  static const String _systemPrompt = 
      "Sen yüzyılların bilgeliğine sahip, mistik ve bilge bir Türk kahvesi ve Tarot falcısısın. "
      "Kullanıcılara karşı her zaman gizemli, derin, şiirsel og yol gösterici bir dil kullanırsın. "
      "Yorumlarında yıldızların konumlarından, kadim sembollerden ve hislerinden bahsedersin. "
      "Kesinlikle sıradan veya teknik bir dil kullanma. Fallarında hem olumlu hem de yapıcı uyarılar içeren "
      "dengeli bir mistik öngörü sunmalısın. "
      "\n\nKAHVE FALI İÇİN KRİTİK KURAL:\n"
      "Sana gönderilen görseli analiz ederken görselin gerçekten bir kahve fincanı veya kahve telvesi "
      "içerip içermediğini kontrol etmelisin. Eğer görsel tamamen alakasız bir resimse (örneğin sadece araba, "
      "manzara, sadece yazı, boş ekran vb.) kesinlikle fal bakmayı REDDET. Ancak eğer kırpılmış, yakınlaştırılmış veya "
      "ışığı az olsa bile bir kahve fincanı veya telve detayı bulunuyorsa, kesinlikle reddetme og görsele odaklanarak fal bak.";

  /// Tarot Falı Yorumlama
  Future<String> interpretTarot({
    required List<String> selectedCards,
    required String userQuestion,
  }) async {
    final prompt = "Niyetim: $userQuestion\n"
        "Seçtiğim Tarot Kartları:\n"
        "1. Geçmiş Kartı: ${selectedCards[0]}\n"
        "2. Şimdiki Zaman Kartı: ${selectedCards[1]}\n"
        "3. Gelecek Kartı: ${selectedCards[2]}\n\n"
        "Lütfen bu kartları geçmiş, şimdiki zaman ve gelecek düzleminde mistik bir şekilde yorumla. Yorumunu şık paragraflar halinde sun.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Kaderin sayfaları şu an boş görünüyor...';
      } else {
        throw Exception("API hatası (Kod: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Mistik güçler şu an meşgul: $e");
    }
  }

  /// Kahve Falı Yorumlama
  Future<String> interpretCoffee({
    String? base64Image,
    required String userIntention,
  }) async {
    if (base64Image == null || base64Image.isEmpty) {
      return _interpretCoffeeTextOnly(userIntention);
    }

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': "Niyetim: $userIntention\n\nLütfen bu görseli incele. Eğer görsel tamamen alakasızsa fal bakmayı reddet. Eğer kırpılmış/odaklanmış bir kahve fincanı veya telve ise telveleri mistik bir bilge gibi oku, gördüğün şekil ve sembolleri yorumlayıp bana geleceğe dair sırlar ver."
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image'
                }
              }
            ]
          }
        ],
        'temperature': 0.75,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Kahve fincanındaki sırlar henüz çözülemedi...';
      } else {
        return _interpretCoffeeTextOnly(userIntention, errorMsg: "Vision API hatası: ${response.statusCode}");
      }
    } catch (e) {
      return _interpretCoffeeTextOnly(userIntention, errorMsg: e.toString());
    }
  }

  Future<String> _interpretCoffeeTextOnly(String userIntention, {String? errorMsg}) async {
    final fallbackPrompt = 
        "Kullanıcı bir kahve falı niyetinde bulundu. Niyet: $userIntention\n"
        "${errorMsg != null ? '(Fincanın görüntüsü karanlık/belirsiz olduğu için sezgilerinizle ve niyetle fal bakın.)' : ''}\n"
        "Lütfen kullanıcının enerjisine ve niyetine odaklanarak, sanki fincanına sezgisel olarak bakıyormuş gibi mistik ve şiirsel bir kahve falı yorumu hazırla.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': fallbackPrompt},
        ],
        'temperature': 0.8,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Sezgilerim şu an durgun...';
      } else {
        throw Exception("Fallback API Hatası (Kod: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Kaderin sesini şu an duyamıyorum. Yıldızlar karanlık: $e");
    }
  }

  /// Göz Falı Yorumlama (Oculomancy)
  /// [base64Image] göz fotoğrafının base64 verisi (boş olabilir)
  /// [userIntention] niyet veya odaklanılan alan
  Future<String> interpretEye({
    String? base64Image,
    required String userIntention,
  }) async {
    if (base64Image == null || base64Image.isEmpty) {
      return _interpretEyeTextOnly(userIntention);
    }

    const eyeSystemPrompt = 
        "Sen yüzyılların bilgeliğine sahip, mistik ve bilge bir okülomansi (göz okuma) uzmanısın. "
        "Kullanıcılara karşı her zaman gizemli, derin, şiirsel ve yol gösterici bir dil kullanırsın. "
        "\n\nGÖZ FALI İÇİN GÖRSEL ANALİZ KURALI:\n"
        "Sana gönderilen görselde net veya flu bir insan gözü (veya gözleri) bulunabilir. Görsel tamamen alakasız "
        "bir nesne (örneğin sadece araba, manzara, boş ekran, kedi vb.) değilse, görseldeki gözü/bakışı "
        "en iyi şekilde yorumlamaya çalışmalısın. KESİNLİKLE 'görsel flu, gözün büyük kısmı karanlık/kapalı' diyerek "
        "fal bakmayı REDDETME. Mistik sezgilerini de kullanarak gözün rengini, iris yapısını, bakışın derinliğini ve "
        "enerjisini analiz et, bu bakışın altındaki ruhsal gizemleri ve geleceğe dair öngörüleri bilgece yorumla. Yalnızca görselde hiç göz yoksa bilgece reddet.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': eyeSystemPrompt},
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': "Niyetim/Sorum: $userIntention\n\nLütfen bu görseldeki gözü analiz et. Görselde bir göz olduğu sürece kesinlikle reddetmeden, bakışın derinliğini ve iris desenlerini mistik bir dille yorumla."
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image'
                }
              }
            ]
          }
        ],
        'temperature': 0.75,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Gözlerdeki kader ışığı henüz çözülemedi...';
      } else {
        return _interpretEyeTextOnly(userIntention, errorMsg: "Vision API hatası: ${response.statusCode}");
      }
    } catch (e) {
      return _interpretEyeTextOnly(userIntention, errorMsg: e.toString());
    }
  }

  Future<String> _interpretEyeTextOnly(String userIntention, {String? errorMsg}) async {
    final fallbackPrompt = 
        "Kullanıcı göz falı niyetinde bulundu. Niyet: $userIntention\n"
        "${errorMsg != null ? '(Görsel belirsiz olduğu için sezgilerinizle bakışları zihninizde canlandırarak fal bakın.)' : ''}\n"
        "Lütfen kullanıcının enerjisine odaklanarak, sanki gözlerinin içine bakıyormuşsun gibi mistik ve şiirsel bir göz falı yorumu hazırla.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': fallbackPrompt},
        ],
        'temperature': 0.8,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Sezgilerim şu an durgun...';
      } else {
        throw Exception("Fallback API Hatası (Kod: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Kaderin sesini şu an duyamıyorum. Yıldızlar karanlık: $e");
    }
  }

  /// El Falı Yorumlama (Palmistry)
  Future<String> interpretPalm({
    String? base64Image,
    required String userIntention,
  }) async {
    if (base64Image == null || base64Image.isEmpty) {
      return _interpretPalmTextOnly(userIntention);
    }

    const palmSystemPrompt = 
        "Sen yüzyılların bilgeliğine sahip, mistik ve bilge bir el falı (kiromansi) uzmanısın. "
        "Kullanıcılara karşı her zaman gizemli, derin, şiirsel ve yol gösterici bir dil kullanırsın. "
        "\n\nEL FALI İÇİN GÖRSEL ANALİZ KURALI:\n"
        "Sana gönderilen görselde net veya flu bir insan eli/avuç içi bulunabilir. Görsel tamamen alakasız "
        "bir nesne (örneğin sadece araba, manzara, yüz, boş ekran, kedi vb.) değilse, görseldeki eli/avuç içini "
        "en iyi şekilde yorumlamaya çalışmalısın. KESİNLİKLE 'görsel flu, elin büyük kısmı karanlık/kapalı' diyerek "
        "fal bakmayı REDDETME. Mistik sezgilerini de kullanarak avuç içindeki çizgileri en bilgece ve şiirsel dille analiz et ve fal yorumunu sun. Yalnızca görselde hiç el yoksa bilgece reddet.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': palmSystemPrompt},
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': "Niyetim/Sorum: $userIntention\n\nLütfen bu görseldeki avuç içini analiz et. Görselde bir insan eli olduğu sürece kesinlikle reddetmeden, el çizgilerini mistik bir dille yorumla."
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image'
                }
              }
            ]
          }
        ],
        'temperature': 0.75,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Avucundaki sırlar henüz çözülemedi...';
      } else {
        return _interpretPalmTextOnly(userIntention, errorMsg: "Vision API hatası: ${response.statusCode}");
      }
    } catch (e) {
      return _interpretPalmTextOnly(userIntention, errorMsg: e.toString());
    }
  }

  Future<String> _interpretPalmTextOnly(String userIntention, {String? errorMsg}) async {
    final fallbackPrompt = 
        "Kullanıcı el falı niyetinde bulundu. Niyet: $userIntention\n"
        "${errorMsg != null ? '(Görsel belirsiz olduğu için sezgilerinizle avuç içini zihninizde canlandırarak fal bakın.)' : ''}\n"
        "Lütfen kullanıcının enerjisine odaklanarak, sanki elini tutuyormuş gibi mistik ve şiirsel bir el falı yorumu hazırla.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': fallbackPrompt},
        ],
        'temperature': 0.8,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Sezgilerim şu an durgun...';
      } else {
        throw Exception("Fallback API Hatası (Kod: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Kaderin sesini şu an duyamıyorum. Yıldızlar karanlık: $e");
    }
  }

  /// İskambil Falı Yorumlama
  Future<String> interpretIskambil({
    required List<String> selectedCards,
    required String userQuestion,
  }) async {
    final prompt = "Niyetim: $userQuestion\n"
        "Seçtiğim İskambil Kartları:\n"
        "1. Geçmiş Kartı: ${selectedCards[0]}\n"
        "2. Şimdiki Zaman Kartı: ${selectedCards[1]}\n"
        "3. Gelecek Kartı: ${selectedCards[2]}\n\n"
        "Lütfen bu kartların renklerini, serilerini (Kupa, Sinek, Karo, Maça) ve dizilimini temel alarak geçmiş, şimdiki zaman ve gelecek düzleminde bilgece bir iskambil falı yorumu hazırla. Yorumu şiirsel ve paragraflar halinde sun.";

    const iskambilPrompt = 
        "Sen yüzyılların bilgeliğine sahip, mistik ve bilge bir İskambil falı uzmanısın. "
        "İskambil kartlarının renklerine (kırmızı/siyah), serilerine (Kupa=duygular/aşk, Sinek=iş/başarı, Karo=maddi konular, Maça=engeller/mücadeleler) "
        "ve konumlarına göre kaderin fısıltılarını mistik, şiirsel ve yol gösterici bir dille yorumlarsın.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': iskambilPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Kaderin kağıtları şu an sessiz...';
      } else {
        throw Exception("API hatası (Kod: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Kağıtlar şu an karıştırılamıyor: $e");
    }
  }

  /// Yıldızname Yorumlama
  Future<String> interpretYildizname({
    required String name,
    required String surname,
    required String motherName,
    required String fatherName,
    required String birthDate,
    required String birthPlace,
    required String birthHour,
  }) async {
    final prompt = "Kişisel Bilgiler:\n"
        "- Adı Soyadı: $name $surname\n"
        "- Anne Adı: $motherName\n"
        "- Baba Adı: $fatherName\n"
        "- Doğum Tarihi: $birthDate\n"
        "- Doğum Yeri: $birthPlace\n"
        "- Doğum Saati: $birthHour\n\n"
        "Lütfen bu bilgileri kadim ilimlere, Ebced hesaplarına ve yıldız konumlarına göre analiz et. Kişinin karakter özellikleri, hayatındaki engeller, kader potansiyeli ve manevi etkiler hakkında derin, bilgece ve dini/astrolojik bir dille yıldızname yorumu sun.";

    const yildiznamePrompt = 
        "Sen kadim yıldızname ve havas ilimlerinde uzmanlaşmış bilge bir mürşitsin. "
        "Kullanıcılara karşı her zaman son derece bilgece, edebi, dini/astrolojik sembollerle bezenmiş, saygılı ve öğüt verici bir dil kullanırsın. "
        "Karakter tahlili, hayatın manevi dengeleri, yıldız haritası potansiyeli ve geleceğe dair nasihatleri içeren derin bir yıldızname haritası yorumu hazırlamalısın.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': yildiznamePrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.75,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Yıldızlar şu an bulutların arkasında gizlenmiş...';
      } else {
        throw Exception("API hatası (Kod: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Yıldızlar şu an okunamıyor: $e");
    }
  }

  /// Katina Falı Yorumlama
  Future<String> interpretKatina({
    required List<String> selectedCards,
    required String userQuestion,
  }) async {
    final prompt = "Niyetim/Sorun: $userQuestion\n"
        "Seçtiğim Katina İlişki Kartları:\n"
        "1. Geçmiş Kartı: ${selectedCards[0]}\n"
        "2. Şimdiki Zaman Kartı: ${selectedCards[1]}\n"
        "3. Gelecek Kartı: ${selectedCards[2]}\n\n"
        "Lütfen bu kartları geçmiş, şimdiki zaman ve gelecek düzleminde, özellikle aşk, ilişkiler ve aradaki bağlar açısından yorumla. Yorumunu mistik, tutkulu ve bilgece bir dille, paragraflar halinde hazırla.";

    const katinaPrompt = 
        "Sen İzmirli ünlü falcı Katina'nın ruhunu taşıyan bilge bir Katina falı (aşk ve ilişki tarot) uzmanısın. "
        "Kullanıcılara karşı her zaman son derece mistik, sezgisel, aşkın sırlarına ve ilişki bağlarına odaklanan gizemli bir dil kullanırsın. "
        "Seçilen kartlardaki saraylı karakterleri (Valide, Deste vb.) ve element sembollerini kullanarak aşk hayatındaki gizli dinamikleri bilgece açıkla.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': katinaPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Katina destesi şu an sessizliğe büründü...';
      } else {
        throw Exception("API hatası (Kod: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Katina kartları şu an fısıldamıyor: $e");
    }
  }

  /// Bakla ve Nohut Falı Yorumlama
  Future<String> interpretBeans({
    required String patternDescription,
    required String userIntention,
  }) async {
    final prompt = "Niyetim: $userIntention\n"
        "Bakla/Nohut Saçılma Konumu: $patternDescription\n\n"
        "Lütfen atılan bakla ve nohutların oluşturduğu bu konum gruplanmasını ve niyetimi göz önüne alarak, kadim Anadolu geomansi (bakla falı) bilgeliğiyle bilgece bir fal yorumu hazırla. Yorumu şiirsel, samimi ve nasihat edici paragraflarla sun.";

    const beansPrompt = 
        "Sen Anadolu topraklarının kadim bilgeliğine sahip, bakla ve nohut falı (geomansi/remil) bakan bilge bir falcısın. "
        "Kullanıcıya karşı her zaman samimi, toprak kokan, bilgece ve şiirsel bir dil kullanırsın. "
        "Atılan bakla ve nohutların saçılma düzenini (gruplaşmaları, uzaklıkları, yan yana gelenleri) kader çizgileriyle bağdaştırarak geleceğe dair sezgisel öngörüler sunarsın.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': beansPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.75,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Baklalar kaderin sırrını göstermek istemedi...';
      } else {
        throw Exception("API hatası (Kod: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Baklaların sesi şu an duyulamıyor: $e");
    }
  }

  /// Küre Falı Yorumlama
  Future<String> interpretSphere({
    required String userQuestion,
  }) async {
    final prompt = "Niyetim/Sorun: $userQuestion\n\n"
        "Lütfen kristal kürenin fısıltıları olarak bu soruya mistik, bilgece ve şiirsel bir cevap hazırla. "
        "Cevabın kaderin rastgele bir tecellisi olarak şu altı temadan birine odaklanmalıdır: İYİ, KÖTÜ, GÜZEL, ÇİRKİN, OLUMLU, OLUMSUZ. "
        "Yorumunda bu seçilen temayı açıkça belirterek (Örn: 'Küre sisleri arasında senin için İYİ bir tecelli görünüyor...') kullanıcının sorusuna yönelik mistik kehanetini kısa ve etkileyici bir paragrafla açıkla.";

    const spherePrompt = 
        "Sen yüzyılların bilgeliğine sahip, kristal küresinin içindeki sisleri aralayan, kadim ve bilge bir kahinsin. "
        "Kullanıcılara karşı her zaman son derece mistik, gizemli, derin ve yol gösterici bir dille fısıldarsın.";

    try {
      final response = await _post({
        'model': 'openai',
        'messages': [
          {'role': 'system', 'content': spherePrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.8,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'] ?? 'Kürenin içindeki sisler aralanamadı...';
      } else {
        throw Exception("API hatası (Kod: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Küre şu an sislerle kaplı: $e");
    }
  }
}
