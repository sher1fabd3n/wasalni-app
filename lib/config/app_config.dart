/// ملف التكوين الآمن للتطبيق
/// يجب عدم رفع هذا الملف على Git مع المفاتيح الحقيقية
class AppConfig {
  /// مفتاح **Legacy** لـ FCM (`Authorization: key=…`) لإرسال HTTP إلى
  /// `fcm.googleapis.com/fcm/send`. جوجل أوقفت/تقلّصت هذه الطريقة لصالح **FCM HTTP v1**
  /// (OAuth2 + حساب خدمة) وعادةً تُنفَّذ من **خادم** (مثل Cloud Functions)، وليس من تطبيق الراكب.
  ///
  /// للعمل **داخليًا** أو بدون خادم: اترك القيمة الافتراضية؛ `DriverTripPush` يتخطّى الإرسال
  /// بصمت، والسواق يعتمد على تحديثات **Realtime Database** وتنبيهات تطبيق السواق المحلية.
  ///
  /// لو احتجت دفعًا للسواق والتطبيق مغلق: أنشئ Cloud Function تستخدم Admin SDK + FCM v1.
  static const String serverKeyFCM = String.fromEnvironment(
    'SERVER_KEY_FCM',
    defaultValue: 'paste your key here',
  );

  /// لسياسة استخدام بلاط OpenStreetMap — عادة نفس applicationId في Android
  static const String osmTileUserAgentPackage = 'com.waslny.users';

  /// بحث العناوين: رمز الدولة ISO (مثال: eg، ae)
  static const String mapSearchCountryCode = 'eg';

  // --- نطاق الخدمة: كفر الشيخ + الجزء القريب من البحيرة ---
  /// مركز مدينة كفر الشيخ (خريطة / مرجع)
  static const double cityCenterLatitude = 31.1070;
  static const double cityCenterLongitude = 30.9408;

  /// حدود تقريبية: كفر الشيخ + حزام قريب يشمل دمنهور/شبراخيت وما حولهما.
  static const double governorateMinLatitude = 30.70;
  static const double governorateMaxLatitude = 31.60;
  static const double governorateMinLongitude = 30.43;
  static const double governorateMaxLongitude = 31.55;

  static bool isInsideServiceGovernorate(double lat, double lon) {
    return lat >= governorateMinLatitude &&
        lat <= governorateMaxLatitude &&
        lon >= governorateMinLongitude &&
        lon <= governorateMaxLongitude;
  }

  /// (احتياطي) نصف قطر قديم — منطق التسعير الداخلي يعتمد الآن على [isInsideServiceGovernorate]
  static const double cityServiceRadiusKm = 22.0;

  /// سعر الرحلة داخل المدينة (ثابت)
  static const double cityFixedFareEgp = 30.0;

  /// تبويب «رحلة داخلية»: سعر ثابت (جنيه مصري) — نقطة انطلاق فقط
  static const double internalTabFixedFareEgp = 25.0;

  /// تبويب «رحلة خارجية»: سعر أساسي + (المسافة بالكم × سعر الكيلو)
  static const double externalBaseFareEgp = 5.0;
  static const double externalPricePerKmEgp = 6.0;

  /// خادم المسارات المجاني OSRM (للاستخدام الخفيف؛ للإنتاج الكبير استضف خادمك)
  static const String osrmRouteBaseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  /// إعادة جلب مسار OSRM أثناء تتبع السائق (متر) — يقلل الطلبات على الخادم.
  static const double driverRouteRefreshMinDistanceMeters = 60.0;

  // إعدادات التطبيق
  static const String appName = 'دسوق وصلني';
  static const String adminEmail = 'sher1fabd3n@gmail.com';

  /// معلومات المطوّر في شاشة «عن التطبيق» (عدّلها ببياناتك).
  static const String developerDisplayName = 'Sherif Ahmed Abden';
  /// مثال: +2010xxxxxxxx. اتركه فارغاً لإخفاء السطر.
  static const String developerPhone = '01029779141';
  /// رابط صفحة فيسبوك (https://…). اتركه فارغاً لإخفاء السطر.
  static const String developerFacebookUrl = 'https://www.facebook.com/share/1CwKsG5Rqf/';

  /// الاسم الظاهر في شاشة «عن التطبيق».
  static const String publisherDisplayName =
      'دسوق وصلني لخدمات النقل والتوصيل';

  /// رابط صفحة سياسة الخصوصية الكاملة على الويب (HTTPS).
  static const String privacyPolicyUrl =
      'https://sher1fabd3n.github.io/privacy-policy/';

  /// رابط حذف الحساب (مطلوب في Google Play — Data safety).
  static const String accountDeletionUrl =
      'https://sher1fabd3n.github.io/privacy-policy/delete-account.html';

  static bool get isPrivacyPolicyUrlConfigured {
    final u = privacyPolicyUrl.trim();
    if (u.isEmpty) return false;
    return !u.contains('example.com');
  }

  /// User-Agent لطلبات Nominatim (إلزامي وفق سياسة OSM)
  static const String nominatimUserAgent =
      'DesouqWasalnyUsersApp/1.0 (support: sher1fabd3n@gmail.com)';

  /// نطاق تقريبي لمدينة دسوق — اقتراحات وجهة الرحلة الداخلية
  static const double desoukMinLatitude = 31.08;
  static const double desoukMaxLatitude = 31.18;
  static const double desoukMinLongitude = 30.58;
  static const double desoukMaxLongitude = 30.72;

  /// بحث Nominatim؛ [biasDesouk] يقيّد النتائج لدسوق ويُلحق الاسم عند الحاجة
  static String nominatimSearchUrl(String query, {bool biasDesouk = false}) {
    var q = query.trim();
    if (biasDesouk && !q.contains('دسوق') && !q.toLowerCase().contains('desouk')) {
      q = '$q دسوق';
    }
    final encoded = Uri.encodeQueryComponent(q);
    var url =
        'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&limit=10&addressdetails=0&countrycodes=$mapSearchCountryCode';
    if (biasDesouk) {
      url +=
          '&viewbox=$desoukMinLongitude,$desoukMaxLatitude,$desoukMaxLongitude,$desoukMinLatitude&bounded=1';
    }
    return url;
  }

  // إعدادات Firebase
  static const String geofirePath = 'onlineDrivers';
  static const String usersPath = 'users';
  /// فهرس سريع: رقم هاتف مُ normaliz → email + uid (لتسجيل الدخول بالهاتف)
  static const String usersByPhonePath = 'usersByPhone';
  static const String driversPath = 'drivers';
  static const String tripRequestsPath = 'tripRequests';

  /// تقييمات الرحلات (مفتاح سجل = مفتاح الرحلة في tripRequests)
  static const String riderTripRatingsPath = 'riderTripRatings';

  /// شكاوى واقتراحات عامة (بدون ربط برحلة)
  static const String riderGeneralFeedbackPath = 'riderGeneralFeedback';

  /// طلبات «رحلات بالاشتراك / متكررة» (لوحة الإدارة — تبويب منفصل)
  static const String riderSubscriptionRequestsPath =
      'riderSubscriptionRequests';

  /// إعدادات عامة من لوحة الإدارة (أسعار الرحلات الخارجية وغيرها)
  static const String appSettingsPath = 'appSettings';

  /// تحت [appSettingsPath]: أسعار (داخلية ثابتة + خارجية أساسي/كم)
  static const String pricingPath = 'pricing';

  // إعدادات الرحلة
  static const double distancePerKmAmount = 0.4;
  static const double durationPerMinuteAmount = 0.3;
  static const double baseFareAmount = 2.0;
  static const int requestTimeoutSeconds = 20;

  // إعدادات الخريطة
  static const double defaultZoom = 15.0;

  /// أقصى بعد (كم) بين الانطلاق والسائق ليظهر في القائمة — داخل المحافظة فقط عبر [isInsideServiceGovernorate].
  static const double geofireRadius = 35.0;

  /// هل يوجد مفتاح Legacy مضبوط فعليًا (غير فارغ وليس placeholder).
  /// لا يُستخدم حاليًا في بقية الكود؛ `DriverTripPush` يتحقق من المفتاح بنفسه.
  static bool get areKeysConfigured {
    final k = serverKeyFCM.trim();
    return k.isNotEmpty && k != 'paste your key here';
  }
}
