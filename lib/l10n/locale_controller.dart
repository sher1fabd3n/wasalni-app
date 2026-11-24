import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocalePref = 'app_locale_code';

/// يحفظ اختيار اللغة (عربي / إنجليزي / افتراضي النظام)
class LocaleController extends ChangeNotifier {
  /// null يعني اتباع لغة الجهاز
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocalePref);
    if (code == 'ar' || code == 'en') {
      _locale = Locale(code!);
    } else {
      _locale = null;
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? value) async {
    _locale = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_kLocalePref);
    } else {
      await prefs.setString(_kLocalePref, value.languageCode);
    }
    notifyListeners();
  }
}
