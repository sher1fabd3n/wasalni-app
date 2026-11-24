// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دسوق وصلني';

  @override
  String get loginTitle => 'مرحبا بكم نتمني لكم رحلة سعيدة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get loginEmailOrPhone => 'البريد أو رقم الهاتف';

  @override
  String get validationLoginIdentifier =>
      'أدخل بريداً إلكترونياً أو رقم هاتف صالحاً';

  @override
  String get loginPhoneNotFound => 'لا يوجد حساب مرتبط بهذا رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signingIn => 'جاري تسجيل الدخول...';

  @override
  String get loginInvalidCredentials => 'البريد أو كلمة المرور غير صحيحة';

  @override
  String get loginUserNotFound => 'لا يوجد حساب بهذا البريد';

  @override
  String get loginTooManyRequests => 'محاولات كثيرة. حاول لاحقاً';

  @override
  String get loginRequestTimeout =>
      'انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مرة أخرى.';

  @override
  String get noAccountSignUp => 'ليس لديك حساب؟ سجّل من هنا';

  @override
  String get signUpTitle => 'تسجيل مستخدم جديد';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get signUp => 'اشتراك جديد';

  @override
  String get signUpInProgress => 'جاري التسجيل...';

  @override
  String get haveAccountLogin => 'لديك حساب بالفعل؟ دخول من هنا';

  @override
  String get validationNameShort => 'الاسم يجب أن يحتوي على 4 أحرف على الأقل';

  @override
  String get validationPhone => 'رقم الهاتف يجب أن يكون 11 رقماً على الأقل';

  @override
  String get validationEmail => 'أدخل بريداً إلكترونياً صالحاً';

  @override
  String get validationPassword =>
      'كلمة المرور يجب أن تكون 6 أحرف أو أرقام على الأقل';

  @override
  String get registeringAccount => 'جاري تسجيل الحساب...';

  @override
  String get errorSignupGeneric => 'حدث خطأ أثناء التسجيل';

  @override
  String get errorEmailInUse => 'البريد الإلكتروني مستخدم مسبقاً';

  @override
  String get errorInvalidEmail => 'البريد الإلكتروني غير صحيح';

  @override
  String get errorWeakPassword => 'كلمة المرور ضعيفة (6 أحرف على الأقل)';

  @override
  String get errorNetworkFirebase =>
      'فشل الاتصال بـ Firebase. جرّب جهازاً حقيقياً إن كنت على محاكي.';

  @override
  String get errorFirebaseEmulatorHint =>
      'Firebase قد يفشل على المحاكي. جرّب على هاتف حقيقي.';

  @override
  String get errorGeneric => 'حدث خطأ';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get history => 'سجل الرحلات';

  @override
  String get about => 'عن التطبيق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get language => 'اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSystem => 'لغة الجهاز';

  @override
  String get comingSoonShort => 'قريباً';

  @override
  String get resolvingPickupGps => 'جاري تحديد موقع الانطلاق...';

  @override
  String get tripRequestDataIncomplete =>
      'بيانات الرحلة غير مكتملة. حدد الانطلاق والوصول ثم أعد المحاولة.';

  @override
  String get pickupOutsideServiceArea =>
      'نقطة الانطلاق أو الوصول خارج نطاق خدمة محافظة كفر الشيخ.';

  @override
  String get fcmKeyMissing =>
      'لم يُضبط مفتاح إرسال الإشعارات. أعد البناء مع --dart-define=SERVER_KEY_FCM=… من إعدادات Firebase → Cloud Messaging.';

  @override
  String get fcmHttp404 =>
      'فشل إرسال إشعار للسائق (404). فعّل «Cloud Messaging API (Legacy)» في Google Cloud لمشروع Firebase هذا، أو تأكد من الرابط والمشروع.';

  @override
  String get fcmHttp401 =>
      'فشل الإشعار (401/403). تحقق من مفتاح SERVER_KEY_FCM في لوحة Firebase (Server key).';

  @override
  String fcmDownstreamError(String error) {
    return 'وصل الطلب لـ FCM لكن فشل: $error';
  }

  @override
  String get fcmNetworkError =>
      'تعذر الاتصال بخوادم الإشعارات. تحقق من الإنترنت.';

  @override
  String get tripTabInternal => 'رحلة داخلية';

  @override
  String get tripTabExternal => 'رحلة خارجية';

  @override
  String internalTabIntro(String egp) {
    return 'يُعرض موقعك الحالي كنقطة انطلاق. اكتب وجهتك في دسوق (حرفين على الأقل) واختر من القائمة. السعر ثابت $egp ج.م.';
  }

  @override
  String get internalDestinationHint => 'إلى — وجهتك في دسوق';

  @override
  String get internalDestinationRequired =>
      'اكتب وجهتك في دسوق واختر عنواناً من النتائج، أو اكتب اسماً واضحاً (3 أحرف على الأقل).';

  @override
  String get dropoffSetSnackbar => 'تم تحديد الوجهة';

  @override
  String get continueShowPrice => 'متابعة — عرض السعر';

  @override
  String get externalTabIntro =>
      'حدد الانطلاق والوصول. السعر يُحسب حسب المسافة. اكتب حرفين ثم اختر من النتائج أسفل الصفحة.';

  @override
  String get fromPickupHint => 'من — عنوان الانطلاق';

  @override
  String get toDestinationHint => 'إلى — عنوان الوصول';

  @override
  String get planTripTitle => 'تحديد الرحلة';

  @override
  String get pickupResults => 'نتائج الانطلاق';

  @override
  String get dropoffResults => 'نتائج الوصول';

  @override
  String pricingInternalFixed(String egp) {
    return 'رحلة داخلية — سعر ثابت $egp ج.م';
  }

  @override
  String get pricingExternalDistance => 'رحلة خارجية — السعر حسب المسافة (كم)';

  @override
  String get estimatedFareLabel => 'السعر التقريبي قبل الطلب';

  @override
  String externalFareFormula(String base, String perKm) {
    return 'أساسي $base ج.م + $perKm ج.م × المسافة بالكم';
  }

  @override
  String get confirmRequestRide => 'تأكيد وطلب الرحلة';

  @override
  String get currencyEgp => 'ج.م';

  @override
  String get payCash => 'دفع نقدي';

  @override
  String amountDueDriver(String amount) {
    return 'المبلغ المستحق $amount ج.م — ادفع للسائق.';
  }

  @override
  String get loadingFirebase => 'جاري تهيئة Firebase...';

  @override
  String get firebaseInitFailed =>
      'تعذر تهيئة Firebase. تحقق من الإنترنت وملف google-services.json ثم أعد المحاولة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get locationGpsError =>
      'تعذر تحديد الموقع. فعّل خدمة الموقع وتحقق من الإنترنت ثم أعد المحاولة.';

  @override
  String get locationServiceDisabled =>
      'خدمة الموقع مغلقة على الجهاز. شغّل «الموقع» من الإعدادات أو لوحة التنبيهات.';

  @override
  String get locationPermissionDenied =>
      'يحتاج التطبيق إذن الموقع. اضغط «السماح» عند الطلب.';

  @override
  String get locationPermissionForeverDenied =>
      'تم رفض الموقع للتطبيق. فعّله من الإعدادات ← التطبيقات ← وصلني ← أذونات.';

  @override
  String blockedMessage(String email) {
    return 'تم حظرك. تواصل مع المشرف: $email';
  }

  @override
  String get gettingDirection => 'جاري جلب المسار...';

  @override
  String get routeFetchError =>
      'تعذر جلب المسار. تحقق من الاتصال أو جرّب لاحقاً.';

  @override
  String get internalPickupRequired =>
      'اختر نقطة الانطلاق من النتائج أو انتظر تحميل موقعك الحالي.';

  @override
  String get noDriverTitle => 'لا يوجد سائق متاح';

  @override
  String get noDriverMessage => 'لا يوجد سائق قريب. حاول مرة أخرى بعد قليل.';

  @override
  String get driverArriving => 'السائق في الطريق';

  @override
  String get driverHasArrived => 'وصل السائق';

  @override
  String get estimatingDriverEta => 'جاري حساب وقت الوصول…';

  @override
  String get driverArrivedNotificationTitle => 'السائق وصل';

  @override
  String get driverArrivedNotificationBody => 'السائق الآن عند نقطة الانطلاق.';

  @override
  String driverComingEta(String eta) {
    return 'السائق قادم — $eta';
  }

  @override
  String drivingToDropoffEta(String eta) {
    return 'متجه للوجهة — $eta';
  }

  @override
  String get tripsHistoryTitle => 'رحلاتي';

  @override
  String get tripFrom => 'من';

  @override
  String get tripTo => 'إلى';

  @override
  String get noTripsYet => 'لا توجد رحلات مكتملة بعد';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get aboutDevelopedBy => 'تطوير';

  @override
  String get aboutBlurb => 'هذا التطبيق مخصص لخدمة الركاب (وصلني).';

  @override
  String aboutContactAdmin(String email) {
    return 'للبلاغات تواصل مع: $email';
  }

  @override
  String get aboutPageTitle => 'عن التطبيق';

  @override
  String get aboutFieldVersionLabel => 'الإصدار';

  @override
  String get aboutSectionWhatIsTitle => 'ما هو التطبيق؟';

  @override
  String get aboutWhatIsBody =>
      '«وصلني» تطبيق للركاب لطلب رحلات داخل نطاق الخدمة المحدد، ومتابعة حالة الرحلة والتواصل مع السائق عبر المنصة.';

  @override
  String get aboutSectionServiceAreaTitle => 'نطاق الخدمة';

  @override
  String get aboutServiceAreaBody =>
      'الخدمة في جمهورية مصر العربية فقط، وضمن نطاق محافظة كفر الشيخ والمناطق المسموح بها في التطبيق على الخريطة. الطلبات خارج هذا النطاق لا تُقبل.';

  @override
  String get aboutSectionPublisherTitle => 'الجهة المنشورة';

  @override
  String get aboutFieldSupportEmailLabel => 'بريد الدعم والبلاغات';

  @override
  String get aboutDeleteAccountHint =>
      'يمكنك حذف حسابك وبياناتك من القائمة الرئيسية ثم اختيار «حذف حسابي».';

  @override
  String get aboutSectionDeveloperTitle => 'مطوّر التطبيق';

  @override
  String get aboutFieldDeveloperPhoneLabel => 'رقم الهاتف';

  @override
  String get aboutFieldDeveloperFacebookLabel => 'صفحة فيسبوك';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacySummaryIntro =>
      'نلتزم بحماية خصوصيتك. يوضح هذا الملخص كيف نتعامل مع بياناتك عند استخدام تطبيق وصلني. للتفاصيل القانونية الكاملة يُفضّل قراءة الصفحة على الويب عندما يكون الرابط متاحاً.';

  @override
  String get privacySectionDataTitle => 'البيانات التي نجمعها';

  @override
  String get privacySectionDataBody =>
      'بيانات الحساب (الاسم، البريد، الهاتف) عند التسجيل؛ وبيانات الرحلة (نقاط الانطلاق والوصول، الحالة، السعر؛ معلومات مرتبطة بالسائق عند تعيين رحلة؛ والتقييمات أو الشكاوى/المقترحات إذا أرسلتها.';

  @override
  String get privacySectionLocationTitle => 'الموقع';

  @override
  String get privacySectionLocationBody =>
      'نستخدم موقع الجهاز داخل مصر لعرض الخريطة وتحديد عنوان الانطلاق ومطابقة طلبات الرحلات مع السائقين القريبين ضمن نطاق محافظة كفر الشيخ والمناطق المسموح بها في التطبيق.';

  @override
  String get privacySectionThirdPartiesTitle => 'جهات خارجية';

  @override
  String get privacySectionThirdPartiesBody =>
      'قد نعتمد على مقدمي خدمات مثل Google Firebase (مصادقة، قاعدة بيانات، تخزين)، وخدمات خرائط/بحث أماكن (مثل OpenStreetMap/Nominatim) وخادم مسارات (مثل OSRM) عند الحاجة. تخضع هذه الجهات لسياساتهم الخاصة.';

  @override
  String get privacySectionRetentionTitle => 'الاحتفاظ بالبيانات';

  @override
  String get privacySectionRetentionBody =>
      'نحتفظ بالبيانات للمدة اللازمة لتشغيل الخدمة والامتثال للقانون أو حل النزاعات. يمكنك طلب حذف حسابك من التطبيق لإزالة بياناتك المرتبطة بحسب الإمكانيات التقنية وقواعد الوصول.';

  @override
  String get privacySectionRightsTitle => 'حقوقك';

  @override
  String get privacySectionRightsBody =>
      'يمكنك طلب تصحيح بيانات الاتصال أو حذف الحساب. لطلبات خصوصية إضافية راسلنا على بريد الدعم أدناه.';

  @override
  String get privacySectionDeleteTitle => 'حذف الحساب';

  @override
  String get privacySectionDeleteBody =>
      'من القائمة في التطبيق اختر «حذف حسابي» وأدخل كلمة المرور للتأكيد؛ يُزال حسابك من نظام المصادقة ويُحذف جزء كبير من بياناتك المخزّنة في قاعدة بيانات التطبيق المرتبطة بحسابك.';

  @override
  String privacyContactFooter(String email) {
    return 'للاستفسارات المتعلقة بالخصوصية: $email';
  }

  @override
  String get privacyOpenFullPolicyButton =>
      'فتح سياسة الخصوصية الكاملة في المتصفح';

  @override
  String get privacyUrlNotConfiguredHint =>
      'لم يُضبط رابط الصفحة الكاملة بعد. عدّل الحقل privacyPolicyUrl في ملف AppConfig بعد نشر صفحة السياسة على موقعك.';

  @override
  String get pickupSetSnackbar => 'تم تحديد نقطة الانطلاق';

  @override
  String get nominatimRateLimit =>
      'تم طلب البحث بسرعة كبيرة. انتظر ثانية ثم أعد المحاولة.';

  @override
  String nominatimHttpError(String code) {
    return 'تعذر تحميل الأماكن (رمز $code). تحقق من الإنترنت.';
  }

  @override
  String get nominatimConnectionError =>
      'تعذر الاتصال بخدمة الأماكن. تحقق من الإنترنت.';

  @override
  String get nominatimNoResults =>
      'لا توجد نتائج. جرّب اسماً أطول أو بالإنجليزية.';

  @override
  String get searchMinCharsHint =>
      'اكتب حرفين على الأقل، ثم اضغط على أحد النتائج أسفل الحقول.';

  @override
  String get fixedPriceShort => 'سعر ثابت';

  @override
  String get dash => '—';

  @override
  String get internalDropLabel => 'رحلة داخلية (الوجهة مع السائق)';

  @override
  String get internalPickupSelectFirst =>
      'حدد نقطة الانطلاق من تبويب «رحلة داخلية» ثم اضغط متابعة.';

  @override
  String get currentLocationFallback => 'موقعي الحالي';

  @override
  String get useMyLocationTooltip => 'تحديد موقعي تلقائياً';

  @override
  String get pickupAutoDetected => 'تم تحديد موقع الانطلاق تلقائياً';

  @override
  String get homeBottomRequestTrip => 'طلب رحلة';

  @override
  String get homeBottomMainMap => 'الرئيسية';

  @override
  String get homeBottomSubscriptions => 'الاشتراكات';

  @override
  String get subscriptionTripsMapTooltip => 'رحلات بالاشتراك / متكررة';

  @override
  String get subscriptionTripsTitle => 'رحلات بالاشتراك';

  @override
  String get subscriptionFormIntro =>
      'املأ البيانات التالية؛ سيتواصل معك فريق وصلني على رقم هاتفك لتحديد قيمة الاشتراك حسب المسافة وعدد الأيام.';

  @override
  String get subscriptionFullNameLabel => 'الاسم ثلاثي';

  @override
  String get subscriptionFullNameValidation =>
      'اكتب الاسم ثلاثياً على الأقل (ثلاث كلمات) وبحد أدنى 8 أحرف.';

  @override
  String get subscriptionPhoneLabel => 'رقم التليفون';

  @override
  String get subscriptionPhoneValidation =>
      'أدخل رقماً صحيحاً (10 أرقام على الأقل).';

  @override
  String get subscriptionPickupLabel => 'مكان البداية';

  @override
  String get subscriptionPickupValidation =>
      'اذكر مكان البداية بوضوح (3 أحرف على الأقل).';

  @override
  String get subscriptionDropoffLabel => 'مكان الوصول';

  @override
  String get subscriptionDropoffValidation =>
      'اذكر مكان الوصول بوضوح (3 أحرف على الأقل).';

  @override
  String get subscriptionWaitTimeLabel => 'هل يوجد وقت انتظار؟';

  @override
  String get subscriptionWaitTimeYes => 'نعم';

  @override
  String get subscriptionWaitTimeNo => 'لا';

  @override
  String get subscriptionWaitTimeValidation => 'حدد هل يوجد وقت انتظار أم لا.';

  @override
  String get subscriptionDaysPerWeekLabel =>
      'كم يوماً في الأسبوع تحتاج الرحلة؟';

  @override
  String get subscriptionDaysPerWeekHint => 'عدد الأيام';

  @override
  String subscriptionDaysPerWeekOption(int count) {
    return '$count أيام في الأسبوع';
  }

  @override
  String get subscriptionRegisterButton => 'تسجيل طلب الاشتراك';

  @override
  String get subscriptionRegisteredMessage =>
      'تم تسجيل الاشتراك، سيتم التواصل معك في أقرب وقت ممكن.';

  @override
  String get subscriptionInquiriesCaption => 'للاستفسارات:';

  @override
  String get subscriptionDoneBack => 'رجوع';

  @override
  String get subscriptionError =>
      'تعذر الإرسال. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get feedbackMenuTitle => 'شكاوى ومقترحات';

  @override
  String get complaintsAndSuggestionsTitle => 'الشكاوى والمقترحات';

  @override
  String get postTripRatingTitle => 'قيّم رحلتك';

  @override
  String get rateTripLabel => 'تقييمك (من 1 إلى 5 نجوم)';

  @override
  String get rateDriverLabel => 'السائق';

  @override
  String get rateServiceLabel => 'الخدمة عموماً (التطبيق والرحلة)';

  @override
  String get optionalCommentHint => 'تعليق اختياري';

  @override
  String get skipRating => 'تخطّي';

  @override
  String get submitRating => 'إرسال التقييم';

  @override
  String get ratingStarsHint => 'اضغط على النجوم (من 1 إلى 5)';

  @override
  String get ratingPickStarsError => 'يرجى اختيار تقييم من 1 إلى 5 نجوم.';

  @override
  String get feedbackIntroBlurb =>
      'أرسل شكوى عن مشكلة، أو مقترحاً لتحسين وصلني. تُخزَّن الرسالة لدى فريق المشرفين.';

  @override
  String get feedbackTypeComplaint => 'شكوى';

  @override
  String get feedbackTypeSuggestion => 'مقترح';

  @override
  String get feedbackMessageHint => 'اكتب الشكوى أو المقترح (8 أحرف على الأقل)';

  @override
  String get feedbackSubmit => 'إرسال';

  @override
  String get feedbackSuccess => 'شكراً — تم إرسال رسالتك.';

  @override
  String get feedbackError => 'تعذر الإرسال. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get feedbackMessageTooShort =>
      'يرجى إضافة تفاصيل أكثر (8 أحرف على الأقل).';

  @override
  String get deleteAccountMenuTitle => 'حذف حسابي';

  @override
  String get deleteAccountDialogTitle => 'حذف الحساب والبيانات؟';

  @override
  String get deleteAccountDialogBody =>
      'سيتم حذف ملفك الشخصي، وسجل الرحلات المرتبط بك، والتقييمات، ورسائل الشكاوى/المقترحات نهائياً ولن يمكن استرجاعها. أدخل كلمة المرور للتأكيد.';

  @override
  String get deleteAccountPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get deleteAccountConfirmButton => 'حذف نهائي';

  @override
  String get deleteAccountCancelButton => 'إلغاء';

  @override
  String get deleteAccountDeleting => 'جاري حذف الحساب…';

  @override
  String get deleteAccountWrongPassword =>
      'كلمة المرور غير صحيحة. حاول مرة أخرى.';

  @override
  String get deleteAccountRequiresRecentLogin =>
      'يرجى تسجيل الخروج ثم الدخول مرة أخرى، ثم أعد محاولة حذف الحساب.';

  @override
  String get deleteAccountErrorGeneric =>
      'تعذر حذف الحساب. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get deleteAccountEmptyPassword => 'أدخل كلمة المرور للتأكيد.';
}
