import 'package:flutter/foundation.dart';
import 'package:users_app/models/address_model.dart';
import 'package:users_app/models/trip_booking_kind.dart';

/// إدارة معلومات الموقع (نقطة الانطلاق والوصول) عبر تطبيق الركاب
class AppInfo extends ChangeNotifier {
  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  /// يُحدَّد من تبويبات شاشة البحث (داخلية / خارجية)
  TripBookingKind tripBookingKind = TripBookingKind.externalByDistance;

  void updatePickUpLocation(AddressModel address) {
    pickUpLocation = address;
    notifyListeners();
  }

  void updateDropOffLocation(AddressModel address) {
    dropOffLocation = address;
    notifyListeners();
  }

  void setTripBookingKind(TripBookingKind kind) {
    tripBookingKind = kind;
    notifyListeners();
  }

  void clearDropOffLocation() {
    dropOffLocation = null;
    notifyListeners();
  }
}
