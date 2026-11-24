/// نوع حجز الرحلة من شاشة البحث
enum TripBookingKind {
  /// داخلية: نقطة انطلاق فقط، سعر ثابت
  internalFixed,

  /// خارجية: انطلاق + وصول، السعر حسب المسافة
  externalByDistance,
}
