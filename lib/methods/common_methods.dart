import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/config/app_config.dart';
import 'package:users_app/models/address_model.dart';
import 'package:users_app/models/direction_details.dart';
import 'package:users_app/models/trip_booking_kind.dart';
import 'package:users_app/services/remote_pricing.dart';

/// نتيجة التحقق قبل استدعاء [Geolocator.getCurrentPosition] (خدمة الموقع + إذن التطبيق).
enum GeolocatorPreconditionResult {
  ready,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

class CommonMethods {
  /// تم إلغاء فحص connectivity_plus لأنه:
  /// 1- يعطي نتيجة خاطئة "لا اتصال" رغم وجود WiFi
  /// 2- يتسبب بإغلاق التطبيق عند تفعيل SIM من الإعدادات
  /// إن لم يكن هناك اتصال، سيفشل Firebase/الطلب مع رسالة مناسبة
  void checkConnectivity(BuildContext context) async {}

  static Future<dynamic> sendRequestToAPI(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      var response = await http
          .get(Uri.parse(url), headers: headers ?? {})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );
      if (response.statusCode == 200) {
        return _decodeJson(response.body);
      }
      // يمكّن الواجهة من عرض رسالة (مثلاً حظر Nominatim المؤقت 429)
      return "error_http_${response.statusCode}";
    } catch (e) {
      return "error";
    }
  }

  static dynamic _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return "error";
    }
  }

  static Map<String, String> get _nominatimHeaders => {
        'User-Agent': AppConfig.nominatimUserAgent,
      };

  /// يتحقق من تشغيل خدمة الموقع على الجهاز ويطلب إذن التطبيق إن لزم.
  static Future<GeolocatorPreconditionResult> ensureGeolocatorPreconditions() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return GeolocatorPreconditionResult.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return GeolocatorPreconditionResult.permissionDenied;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return GeolocatorPreconditionResult.permissionDeniedForever;
    }
    return GeolocatorPreconditionResult.ready;
  }

  /// مؤقتًا: دقة متوسطة/منخفضة فقط (موقع تقريبي) بدون Precise location.
  static Future<Position?> getCurrentPositionRobust() async {
    for (final accuracy in [
      LocationAccuracy.medium,
      LocationAccuracy.low,
    ]) {
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: accuracy),
        ).timeout(const Duration(seconds: 20));
      } catch (_) {}
    }
    return null;
  }

  /// عنوان مقروء من استجابة Nominatim reverse (مناسب للسائق في مصر).
  static String formatAddressFromNominatimReverse(Map<String, dynamic> body) {
    final addr = body['address'];
    if (addr is Map) {
      final m = Map<String, dynamic>.from(addr);
      final segments = <String>[];

      String? pick(String key) {
        final v = m[key]?.toString().trim();
        if (v == null || v.isEmpty) return null;
        return v;
      }

      void addUnique(String? value) {
        if (value == null) return;
        if (!segments.contains(value)) segments.add(value);
      }

      final house = pick('house_number');
      final road = pick('road');
      if (road != null) {
        addUnique(house != null ? '$house $road' : road);
      } else {
        addUnique(house);
      }

      for (final key in [
        'amenity',
        'building',
        'neighbourhood',
        'suburb',
        'village',
        'town',
        'city',
        'county',
        'state',
      ]) {
        addUnique(pick(key));
      }

      if (segments.isNotEmpty) return segments.join('، ');
    }

    final display = body['display_name']?.toString().trim();
    if (display != null && display.isNotEmpty) return display;
    return '';
  }

  /// عكس إحداثيات GPS إلى عنوان نصي عبر Nominatim.
  static Future<AddressModel?> reverseGeocodeLatLng(
    double lat,
    double lon,
  ) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1&zoom=18&accept-language=ar,en';
    final response = await sendRequestToAPI(
      url,
      headers: {
        ..._nominatimHeaders,
        'Accept-Language': 'ar,en',
      },
    );
    if (response is! Map) return null;

    final body = Map<String, dynamic>.from(response);
    final formatted = formatAddressFromNominatimReverse(body);
    if (formatted.isEmpty) return null;

    return AddressModel(
      humanReadableAddress: formatted,
      placeName: formatted,
      latitudePosition: lat,
      longitudePosition: lon,
      placeID: body['place_id']?.toString(),
    );
  }

  /// إحداثيات + عنوان مقروء من GPS الجهاز (لنقطة الانطلاق).
  static Future<AddressModel?> pickupFromDeviceGps({
    String? preferredLabel,
    required String fallbackLabel,
  }) async {
    try {
      final pre = await ensureGeolocatorPreconditions();
      if (pre != GeolocatorPreconditionResult.ready) return null;
      final position = await getCurrentPositionRobust();
      if (position == null) return null;

      final reversed = await reverseGeocodeLatLng(
        position.latitude,
        position.longitude,
      );
      if (reversed != null) {
        final trimmed = preferredLabel?.trim();
        if (trimmed != null &&
            trimmed.isNotEmpty &&
            trimmed != fallbackLabel &&
            !trimmed.startsWith(fallbackLabel)) {
          reversed.humanReadableAddress = trimmed;
          reversed.placeName = trimmed;
        }
        return reversed;
      }

      final coordsLabel =
          '$fallbackLabel (${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)})';
      return AddressModel(
        humanReadableAddress: coordsLabel,
        placeName: coordsLabel,
        latitudePosition: position.latitude,
        longitudePosition: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  static double _degToRad(double deg) => deg * math.pi / 180;

  /// مسافة بين نقطتين على سطح الأرض (كم)
  static double haversineDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthKm * c;
  }

  /// هل النقطة داخل نطاق خدمة محافظة كفر الشيخ ([AppConfig.isInsideServiceGovernorate])
  static bool isPointInsideServiceCity(double lat, double lon) {
    return AppConfig.isInsideServiceGovernorate(lat, lon);
  }

  /// رحلة "داخل المدينة" فقط إذا كان الانطلاق والوصول داخل النطاق
  static bool isTripWithinCity(
    double pickLat,
    double pickLon,
    double dropLat,
    double dropLon,
  ) {
    return isPointInsideServiceCity(pickLat, pickLon) &&
        isPointInsideServiceCity(dropLat, dropLon);
  }

  static String _formatDistanceMeters(num meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String _formatDurationSeconds(num seconds) {
    final s = seconds.round();
    if (s < 60) return '$s sec';
    final m = s ~/ 60;
    if (m < 60) return '$m min';
    final h = m ~/ 60;
    final rm = m % 60;
    return '$h hr $rm min';
  }

  static Future<AddressModel?> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
    Position position,
    BuildContext context,
  ) async {
    final addressModel = await reverseGeocodeLatLng(
      position.latitude,
      position.longitude,
    );
    if (addressModel == null) return null;

    if (context.mounted) {
      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocation(addressModel);
    }
    return addressModel;
  }

  /// يقبل أي كائن فيه latitude و longitude (مثل LatLng من latlong2)
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(
    dynamic origin,
    dynamic destination,
  ) async {
    final oLat = origin.latitude as double;
    final oLon = origin.longitude as double;
    final dLat = destination.latitude as double;
    final dLon = destination.longitude as double;
    final url =
        '${AppConfig.osrmRouteBaseUrl}/$oLon,$oLat;$dLon,$dLat?overview=full&geometries=polyline';
    var response = await sendRequestToAPI(url);
    if (response is! Map) return null;

    final code = response['code']?.toString();
    if (code != null && code.toLowerCase() != 'ok') return null;

    final routes = response['routes'] as List?;
    if (routes == null || routes.isEmpty) return null;

    final route = routes.first as Map<String, dynamic>;
    final distanceM = route['distance'];
    final durationS = route['duration'];
    final geometry = route['geometry']?.toString();
    if (distanceM == null || durationS == null || geometry == null) return null;

    final dist = distanceM as num;
    final dur = durationS as num;
    return DirectionDetails(
      distanceTextString: _formatDistanceMeters(dist),
      durationTextString: _formatDurationSeconds(dur),
      distanceValueDigits: dist.round(),
      durationValueDigits: dur.round(),
      encodedPoints: geometry,
    );
  }

  /// رحلة داخلية (تبويب): سعر ثابت. رحلة خارجية: حسب المسافة من [directionDetails].
  static String calculateFareAmount(
    DirectionDetails directionDetails, {
    required TripBookingKind tripBookingKind,
  }) {
    if (tripBookingKind == TripBookingKind.internalFixed) {
      return RemotePricing.instance.internalTabFixedFareEgp.toStringAsFixed(0);
    }
    if (directionDetails.distanceValueDigits == null) {
      return "0";
    }
    final distanceKm = directionDetails.distanceValueDigits! / 1000;
    final fare = RemotePricing.instance.externalBaseFareEgp +
        distanceKm * RemotePricing.instance.externalPricePerKmEgp;
    return fare.toStringAsFixed(2);
  }

  void displaySnackBar(String messageText, BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(messageText),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          showCloseIcon: true,
        ),
      );
  }
}
