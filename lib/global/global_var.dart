import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:users_app/config/app_config.dart';

String userName = "";
String userPhone = "";
String get userID => FirebaseAuth.instance.currentUser?.uid ?? "";

String get serverKeyFCM => AppConfig.serverKeyFCM;

/// مركز الخريطة الابتدائي — نفس مركز المدينة في [AppConfig] (للتسعير داخل النطاق)
final LatLng defaultMapCenter = LatLng(
  AppConfig.cityCenterLatitude,
  AppConfig.cityCenterLongitude,
);
