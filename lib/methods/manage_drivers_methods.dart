import 'package:firebase_database/firebase_database.dart';
import 'package:users_app/models/online_nearby_drivers.dart';

class ManageDriversMethods
{
  static List<OnlineNearbyDrivers> nearbyOnlineDriversList = [];

  /// يقرأ [lat, lng] من شكل GeoFire (`l`). يرجع null إن كان السجل ناقصاً —
  /// مكتبة GeoFire الأصلية تنهار عند غياب `l`؛ هنا نتخطى السجل بدلاً من ذلك.
  static ({double lat, double lng})? readGeoFireLocation(DataSnapshot snapshot) {
    final l = snapshot.child('l');
    if (!l.exists || l.value == null) return null;
    final v = l.value;
    if (v is List) {
      if (v.length < 2) return null;
      final lat = _toDouble(v[0]);
      final lng = _toDouble(v[1]);
      if (lat == null || lng == null) return null;
      return (lat: lat, lng: lng);
    }
    if (v is Map) {
      final lat = _toDouble(v['0'] ?? v[0]);
      final lng = _toDouble(v['1'] ?? v[1]);
      if (lat == null || lng == null) return null;
      return (lat: lat, lng: lng);
    }
    return null;
  }

  static double? _toDouble(dynamic x) {
    if (x == null) return null;
    if (x is num) return x.toDouble();
    return double.tryParse(x.toString());
  }

  static void removeDriverFromList(String driverID) {
    final index = nearbyOnlineDriversList
        .indexWhere((driver) => driver.uidDriver == driverID);
    if (index < 0) return;
    nearbyOnlineDriversList.removeAt(index);
  }

  static void updateOnlineNearbyDriversLocation(
      OnlineNearbyDrivers nearbyOnlineDriverInformation) {
    final index = nearbyOnlineDriversList.indexWhere(
        (driver) => driver.uidDriver == nearbyOnlineDriverInformation.uidDriver);
    if (index < 0) {
      /// قد يصل onKeyMoved قبل onKeyEntered — لا ترمي RangeError (كان يسبب انهيار العملية)
      nearbyOnlineDriversList.add(OnlineNearbyDrivers(
        uidDriver: nearbyOnlineDriverInformation.uidDriver,
        latDriver: nearbyOnlineDriverInformation.latDriver,
        lngDriver: nearbyOnlineDriverInformation.lngDriver,
      ));
      return;
    }
    nearbyOnlineDriversList[index].latDriver =
        nearbyOnlineDriverInformation.latDriver;
    nearbyOnlineDriversList[index].lngDriver =
        nearbyOnlineDriverInformation.lngDriver;
  }
}