import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';

class VersionGateResult {
  final bool mustUpdate;
  final bool hasOptionalUpdate;
  final String currentVersion;
  final String minSupportedVersion;
  final String latestVersion;
  final String title;
  final String message;
  final String? androidStoreUrl;
  final String? iosStoreUrl;

  const VersionGateResult({
    required this.mustUpdate,
    required this.hasOptionalUpdate,
    required this.currentVersion,
    required this.minSupportedVersion,
    required this.latestVersion,
    required this.title,
    required this.message,
    this.androidStoreUrl,
    this.iosStoreUrl,
  });
}

class VersionGateService {
  VersionGateService._();

  /// Firebase path: appSettings/versionGate/users
  static const String _appKey = 'users';

  static Future<VersionGateResult> check() async {
    try {
      return await _checkInternal().timeout(
        const Duration(seconds: 12),
        onTimeout: () async => _fallbackFromPackageInfo(),
      );
    } catch (e, st) {
      debugPrint('VersionGateService.check failed: $e\n$st');
      return _fallbackFromPackageInfo();
    }
  }

  static Future<VersionGateResult> _fallbackFromPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version.trim();
    return VersionGateResult(
      mustUpdate: false,
      hasOptionalUpdate: false,
      currentVersion: currentVersion,
      minSupportedVersion: currentVersion,
      latestVersion: currentVersion,
      title: 'تحديث مطلوب',
      message: 'يرجى تحديث التطبيق للاستمرار.',
    );
  }

  static Future<VersionGateResult> _checkInternal() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version.trim();

    final snap = await FirebaseDatabase.instance
        .ref()
        .child(AppConfig.appSettingsPath)
        .child('versionGate')
        .child(_appKey)
        .get();

    final raw = (snap.value is Map)
        ? Map<String, dynamic>.from(snap.value as Map)
        : <String, dynamic>{};

    final minSupportedVersion =
        (raw['minSupportedVersion']?.toString().trim().isNotEmpty ?? false)
            ? raw['minSupportedVersion'].toString().trim()
            : currentVersion;
    final latestVersion =
        (raw['latestVersion']?.toString().trim().isNotEmpty ?? false)
            ? raw['latestVersion'].toString().trim()
            : currentVersion;
    final forceUpdate = raw['forceUpdate'] == true;

    final needsByVersion =
        _compareVersions(currentVersion, minSupportedVersion) < 0;
    final mustUpdate = forceUpdate || needsByVersion;
    final hasOptionalUpdate =
        !mustUpdate && _compareVersions(currentVersion, latestVersion) < 0;

    return VersionGateResult(
      mustUpdate: mustUpdate,
      hasOptionalUpdate: hasOptionalUpdate,
      currentVersion: currentVersion,
      minSupportedVersion: minSupportedVersion,
      latestVersion: latestVersion,
      title: (raw['title']?.toString().trim().isNotEmpty ?? false)
          ? raw['title'].toString().trim()
          : 'تحديث مطلوب',
      message: (raw['message']?.toString().trim().isNotEmpty ?? false)
          ? raw['message'].toString().trim()
          : 'يرجى تحديث التطبيق للاستمرار.',
      androidStoreUrl: raw['androidStoreUrl']?.toString().trim(),
      iosStoreUrl: raw['iosStoreUrl']?.toString().trim(),
    );
  }

  static int _compareVersions(String a, String b) {
    final aParts = _normalize(a);
    final bParts = _normalize(b);
    final maxLen = aParts.length > bParts.length ? aParts.length : bParts.length;
    for (var i = 0; i < maxLen; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }

  static List<int> _normalize(String v) {
    return v
        .split(RegExp(r'[.\-+]'))
        .map((s) => int.tryParse(s) ?? 0)
        .toList();
  }
}
