import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:users_app/config/app_config.dart';

/// أسعار من Realtime Database (`appSettings/pricing`).
/// عند غياب البيانات تُستخدم قيم [AppConfig].
class RemotePricing extends ChangeNotifier {
  RemotePricing._();

  static final RemotePricing instance = RemotePricing._();

  double _internalTabFixedFareEgp = AppConfig.internalTabFixedFareEgp;
  double _externalBaseFareEgp = AppConfig.externalBaseFareEgp;
  double _externalPricePerKmEgp = AppConfig.externalPricePerKmEgp;

  double get internalTabFixedFareEgp => _internalTabFixedFareEgp;
  double get externalBaseFareEgp => _externalBaseFareEgp;
  double get externalPricePerKmEgp => _externalPricePerKmEgp;

  StreamSubscription<DatabaseEvent>? _sub;

  DatabaseReference get _ref => FirebaseDatabase.instance
      .ref()
      .child(AppConfig.appSettingsPath)
      .child(AppConfig.pricingPath);

  static double _readDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }

  void _applyMap(Map raw) {
    final m = Map<String, dynamic>.from(raw);
    final internal = _readDouble(
      m['internalTabFixedFareEgp'],
      AppConfig.internalTabFixedFareEgp,
    ).clamp(1.0, 1e6);
    final base = _readDouble(
      m['externalBaseFareEgp'],
      AppConfig.externalBaseFareEgp,
    ).clamp(0.0, 1e6);
    final perKm = _readDouble(
      m['externalPricePerKmEgp'],
      AppConfig.externalPricePerKmEgp,
    ).clamp(0.01, 1e6);
    _internalTabFixedFareEgp = internal;
    _externalBaseFareEgp = base;
    _externalPricePerKmEgp = perKm;
    notifyListeners();
  }

  /// استدعِها مرة بعد تهيئة Firebase بنجاح.
  void startListening() {
    _sub?.cancel();
    try {
      _ref.get().then((snap) {
        final v = snap.value;
        if (v is Map) {
          _applyMap(v);
        } else {
          notifyListeners();
        }
      }, onError: (_) {});
    } catch (_) {}

    _sub = _ref.onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is Map) {
        _applyMap(v);
      }
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    _sub = null;
    super.dispose();
  }
}
