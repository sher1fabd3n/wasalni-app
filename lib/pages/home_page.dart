import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/global/trip_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/methods/manage_drivers_methods.dart';
import 'package:users_app/models/address_model.dart';
import 'package:users_app/models/direction_details.dart';
import 'package:users_app/models/online_nearby_drivers.dart';
import 'package:users_app/models/trip_booking_kind.dart';
import 'package:users_app/pages/about_page.dart';
import 'package:users_app/pages/privacy_policy_page.dart';
import 'package:users_app/pages/complaints_suggestions_page.dart';
import 'package:users_app/pages/search_destination_page.dart';
import 'package:users_app/pages/subscription_trips_page.dart';
import 'package:users_app/pages/trips_history_page.dart';
import 'package:users_app/widgets/info_dialog.dart';
import 'package:users_app/widgets/payment_dialog.dart';
import 'package:users_app/widgets/map_widget.dart';
import 'package:users_app/widgets/ride_details_container.dart';
import 'package:users_app/widgets/trip_details_container.dart';
import 'package:users_app/widgets/request_container.dart';
import 'package:users_app/config/app_config.dart';
import 'package:users_app/utils/error_handler.dart';

import '../appInfo/app_info.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/l10n/locale_controller.dart';
import 'package:users_app/widgets/loading_dialog.dart';
import 'package:users_app/services/account_deletion_service.dart';
import 'package:users_app/services/driver_trip_push.dart';
import 'package:users_app/services/rider_notification_service.dart';
import 'package:users_app/services/rider_feedback_service.dart';
import 'package:users_app/widgets/post_trip_rating_dialog.dart';


class HomePage extends StatefulWidget
{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage>
{
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      tripStatusDisplay = AppLocalizations.of(context)!.driverArriving;
    });
  }

  final MapController mapController = MapController();
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  /// ارتفاع بانل الأزرار السفلي (أيقونة + تسمية لكل زر)
  double searchContainerHeight = 124;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetails? tripDirectionDetailsInfo;
  List<LatLng> polylineCoOrdinates = [];
  List<Polyline> mapPolylines = [];
  List<Marker> mapMarkers = [];
  List<CircleMarker> mapCircles = [];
  bool isDrawerOpened = true;
  String stateOfApp = "normal";
  bool nearbyOnlineDriversKeysLoaded = false;
  DatabaseReference? tripRequestRef;
  List<OnlineNearbyDrivers>? availableNearbyOnlineDriversList;
  StreamSubscription<DatabaseEvent>? tripStreamSubscription;
  StreamSubscription<DatabaseEvent>? _onlineDriversSubscription;
  /// انتظار رد السائق على trip عبر [newTripStatus] + إشعار FCM اختياري
  StreamSubscription<DatabaseEvent>? _driverResponseSubscription;
  Timer? _driverResponseTimer;
  /// يمنع تكرار جلب الموقع و الاستماع لمسار السائقين عند إعادة بناء الخريطة
  bool _mapBootstrapDone = false;
  bool requestingDirectionDetailsInfo = false;
  /// يمنع تكرار حوار الدفع/التقييم عند تعدد أحداث onValue لحالة ended
  bool _tripEndedFlowActive = false;
  /// آخر موقع سائق طُلب منه مسار OSRM (لتقليل الطلبات أثناء التتبع الحي).
  LatLng? _lastLiveDriverRouteOrigin;
  final PolylinePoints _liveRoutePolylineDecoder = PolylinePoints();

  @override
  void dispose() {
    _driverResponseSubscription?.cancel();
    _driverResponseTimer?.cancel();
    _onlineDriversSubscription?.cancel();
    tripStreamSubscription?.cancel();
    mapController.dispose();
    super.dispose();
  }

  Future<void> _showDeleteAccountFlow() async {
    final loc = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null || user.email!.isEmpty) {
      cMethods.displaySnackBar(loc.deleteAccountErrorGeneric, context);
      return;
    }

    final passwordCtrl = TextEditingController();
    String? password;
    try {
      password = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              loc.deleteAccountDialogTitle,
              style: const TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.deleteAccountDialogBody,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: loc.deleteAccountPasswordLabel,
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFD32F2F)),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(loc.deleteAccountCancelButton),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  final p = passwordCtrl.text.trim();
                  if (p.isEmpty) {
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      SnackBar(content: Text(loc.deleteAccountEmptyPassword)),
                    );
                    return;
                  }
                  Navigator.pop(dialogCtx, p);
                },
                child: Text(loc.deleteAccountConfirmButton),
              ),
            ],
          );
        },
      );
    } finally {
      passwordCtrl.dispose();
    }

    if (password == null || password.isEmpty || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => LoadingDialog(
        messageText: AppLocalizations.of(c)!.deleteAccountDeleting,
      ),
    );

    try {
      await AccountDeletionService.reauthenticateWithPassword(password);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await AccountDeletionService.deleteUserRealtimeData(uid);
      await AccountDeletionService.deleteUserStorageFiles(uid);
      await AccountDeletionService.deleteAuthUser();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        final String msg;
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          msg = loc.deleteAccountWrongPassword;
        } else if (e.code == 'requires-recent-login') {
          msg = loc.deleteAccountRequiresRecentLogin;
        } else {
          msg = loc.deleteAccountErrorGeneric;
        }
        cMethods.displaySnackBar(msg, context);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('_showDeleteAccountFlow: $e');
      }
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        cMethods.displaySnackBar(loc.deleteAccountErrorGeneric, context);
      }
    }
  }

  getCurrentLiveLocationOfUser() async
  {
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    final pre = await CommonMethods.ensureGeolocatorPreconditions();
    if (pre != GeolocatorPreconditionResult.ready) {
      if (!mounted) return;
      final msg = switch (pre) {
        GeolocatorPreconditionResult.serviceDisabled =>
          loc.locationServiceDisabled,
        GeolocatorPreconditionResult.permissionDenied =>
          loc.locationPermissionDenied,
        GeolocatorPreconditionResult.permissionDeniedForever =>
          loc.locationPermissionForeverDenied,
        _ => loc.locationGpsError,
      };
      cMethods.displaySnackBar(msg, context);
      if (pre == GeolocatorPreconditionResult.serviceDisabled) {
        await Geolocator.openLocationSettings();
      } else if (pre == GeolocatorPreconditionResult.permissionDeniedForever) {
        await Geolocator.openAppSettings();
      }
      return;
    }

    final positionOfUser = await CommonMethods.getCurrentPositionRobust();
    if (positionOfUser == null) {
      if (mounted) {
        cMethods.displaySnackBar(loc.locationGpsError, context);
      }
      return;
    }
    currentPositionOfUser = positionOfUser;

    final positionOfUserInLatLng = LatLng(
      currentPositionOfUser!.latitude,
      currentPositionOfUser!.longitude,
    );
    try {
      mapController.move(positionOfUserInLatLng, 15);
    } catch (e, st) {
      debugPrint('mapController.move (location): $e\n$st');
    }

    final addressFromGeocode = await CommonMethods
        .convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
            currentPositionOfUser!, context);
    if (!mounted) return;
    if (addressFromGeocode == null) {
      final loc = AppLocalizations.of(context)!;
      final lat = currentPositionOfUser!.latitude;
      final lon = currentPositionOfUser!.longitude;
      final coordsLabel =
          '${loc.currentLocationFallback} (${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)})';
      final fallback = AddressModel(
        humanReadableAddress: coordsLabel,
        placeName: coordsLabel,
        latitudePosition: lat,
        longitudePosition: lon,
      );
      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(fallback);
    }

    await getUserInfoAndCheckBlockStatus();

    await initializeGeoFireListener();
  }

  getUserInfoAndCheckBlockStatus() async
  {
    try {
      if (FirebaseAuth.instance.currentUser == null) return;
      
      DatabaseReference usersRef = FirebaseDatabase.instance.ref()
          .child(AppConfig.usersPath)
          .child(FirebaseAuth.instance.currentUser!.uid);

      await usersRef.once().then((snap)
      {
        if(!mounted) return;
        
        if(snap.snapshot.value != null)
        {
          Map userData = snap.snapshot.value as Map;
          
          if(userData["blockStatus"] == "no")
          {
            setState(() {
              userName = userData["name"] ?? "";
              userPhone = userData["phone"] ?? "";
            });
          }
          else
          {
            FirebaseAuth.instance.signOut();

            Navigator.push(context, MaterialPageRoute(builder: (c)=> const LoginScreen()));

            cMethods.displaySnackBar(
              AppLocalizations.of(context)!.blockedMessage(AppConfig.adminEmail),
              context,
            );
          }
        }
        else
        {
          FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (c)=> const LoginScreen()));
          }
        }
      }).catchError((error) {
        if (mounted) {
          ErrorHandler.handleFirebaseError(error, context);
        }
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleFirebaseError(e, context);
      }
    }
  }

  displayUserRideDetailsContainer() async
  {
    final kind =
        Provider.of<AppInfo>(context, listen: false).tripBookingKind;
    final ok = kind == TripBookingKind.internalFixed
        ? await retrieveInternalTripDetails()
        : await retrieveDirectionDetails();
    if (!ok || !mounted) return;

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final panelHeight = 220.0 + bottomInset;

    setState(() {
      searchContainerHeight = 0;
      bottomMapPadding = panelHeight;
      rideDetailsContainerHeight = panelHeight;
      isDrawerOpened = false;
    });
  }

  /// رحلة داخلية: نقطة انطلاق فقط، بدون مسار OSRM، سعر ثابت من [AppConfig.internalTabFixedFareEgp]
  Future<bool> retrieveInternalTripDetails() async {
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    final loc = AppLocalizations.of(context)!;
    var pickUp = appInfo.pickUpLocation;
    if (pickUp?.latitudePosition == null || pickUp?.longitudePosition == null) {
      final fromGps = await CommonMethods.pickupFromDeviceGps(
        preferredLabel: null,
        fallbackLabel: loc.currentLocationFallback,
      );
      if (!mounted) return false;
      if (fromGps != null) {
        appInfo.updatePickUpLocation(fromGps);
        pickUp = appInfo.pickUpLocation;
      }
    }
    if (pickUp?.latitudePosition == null || pickUp?.longitudePosition == null) {
      if (mounted) {
        cMethods.displaySnackBar(loc.internalPickupSelectFirst, context);
      }
      return false;
    }

    final pickupResolved = pickUp as AddressModel;
    var drop = appInfo.dropOffLocation;
    final destLabel = drop?.placeName?.trim() ?? '';
    if (destLabel.isEmpty) {
      if (mounted) {
        cMethods.displaySnackBar(loc.internalDestinationRequired, context);
      }
      return false;
    }

    drop ??= AddressModel();
    drop.placeName = destLabel;
    drop.humanReadableAddress =
        drop.humanReadableAddress?.trim().isNotEmpty == true
            ? drop.humanReadableAddress
            : destLabel;
    drop.latitudePosition ??= pickupResolved.latitudePosition;
    drop.longitudePosition ??= pickupResolved.longitudePosition;
    drop.placeID ??= 'internal_destination';
    final resolvedDrop = drop;
    appInfo.updateDropOffLocation(resolvedDrop);

    final pickupGeo = LatLng(
      pickupResolved.latitudePosition!,
      pickupResolved.longitudePosition!,
    );
    final dropGeo = LatLng(
      resolvedDrop.latitudePosition!,
      resolvedDrop.longitudePosition!,
    );
    final sameCoords = pickupGeo.latitude == dropGeo.latitude &&
        pickupGeo.longitude == dropGeo.longitude;

    if (!mounted) return false;
    setState(() {
      tripDirectionDetailsInfo = DirectionDetails(
        distanceTextString: resolvedDrop.placeName ?? loc.dash,
        durationTextString: loc.fixedPriceShort,
        distanceValueDigits: 0,
        durationValueDigits: 0,
        encodedPoints: '',
      );
      polylineCoOrdinates.clear();
      mapPolylines.clear();
      mapMarkers = [
        Marker(
          key: const ValueKey('pickup'),
          point: pickupGeo,
          width: 44,
          height: 44,
          alignment: Alignment.bottomCenter,
          child: Tooltip(
            message: pickupResolved.placeName ?? 'الانطلاق',
            child: const Icon(Icons.location_pin, color: Colors.green, size: 44),
          ),
        ),
        if (!sameCoords)
          Marker(
            key: const ValueKey('dropoff'),
            point: dropGeo,
            width: 44,
            height: 44,
            alignment: Alignment.bottomCenter,
            child: Tooltip(
              message: resolvedDrop.placeName ?? 'الوجهة',
              child: const Icon(Icons.location_pin, color: Colors.red, size: 44),
            ),
          ),
      ];
      mapCircles = [
        CircleMarker(
          point: pickupGeo,
          radius: 14,
          useRadiusInMeter: true,
          color: Colors.pink.withValues(alpha: 0.35),
          borderStrokeWidth: 4,
          borderColor: Colors.blue,
        ),
      ];
    });

    try {
      mapController.move(pickupGeo, AppConfig.defaultZoom);
    } catch (e, st) {
      debugPrint('mapController.move (internal trip): $e\n$st');
    }
    return true;
  }

  /// يعيد false إن فشل طلب المسار (OSRM)
  Future<bool> retrieveDirectionDetails() async
  {
    final loc = AppLocalizations.of(context)!;
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    var pickUpLocation = appInfo.pickUpLocation;
    var dropOffDestinationLocation = appInfo.dropOffLocation;

    if (pickUpLocation?.latitudePosition == null ||
        pickUpLocation?.longitudePosition == null) {
      final fromGps = await CommonMethods.pickupFromDeviceGps(
        fallbackLabel: loc.currentLocationFallback,
      );
      if (!mounted) return false;
      if (fromGps != null) {
        appInfo.updatePickUpLocation(fromGps);
        pickUpLocation = fromGps;
      }
    }

    if (pickUpLocation?.latitudePosition == null ||
        pickUpLocation?.longitudePosition == null) {
      if (mounted) {
        cMethods.displaySnackBar(loc.internalPickupRequired, context);
      }
      return false;
    }

    if (dropOffDestinationLocation?.latitudePosition == null ||
        dropOffDestinationLocation?.longitudePosition == null) {
      if (mounted) {
        cMethods.displaySnackBar(loc.tripRequestDataIncomplete, context);
      }
      return false;
    }

    final resolvedPickup = pickUpLocation!;
    final resolvedDropoff = dropOffDestinationLocation!;

    var pickupGeoGraphicCoOrdinates = LatLng(
      resolvedPickup.latitudePosition!,
      resolvedPickup.longitudePosition!,
    );
    var dropOffDestinationGeoGraphicCoOrdinates = LatLng(
      resolvedDropoff.latitudePosition!,
      resolvedDropoff.longitudePosition!,
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: loc.gettingDirection),
    );

    var detailsFromDirectionAPI = await CommonMethods.getDirectionDetailsFromAPI(pickupGeoGraphicCoOrdinates, dropOffDestinationGeoGraphicCoOrdinates);

    if (!mounted) return false;
    Navigator.pop(context);

    final encoded = detailsFromDirectionAPI?.encodedPoints;
    if (detailsFromDirectionAPI == null || encoded == null || encoded.isEmpty) {
      if (mounted) {
        cMethods.displaySnackBar(
          AppLocalizations.of(context)!.routeFetchError,
          context,
        );
      }
      return false;
    }

    setState(() {
      tripDirectionDetailsInfo = detailsFromDirectionAPI;
    });

    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPointsFromPickUpToDestination = pointsPolyline.decodePolyline(encoded);

    polylineCoOrdinates.clear();
    if(latLngPointsFromPickUpToDestination.isNotEmpty)
    {
      for (final PointLatLng latLngPoint in latLngPointsFromPickUpToDestination)
      {
        polylineCoOrdinates.add(LatLng(latLngPoint.latitude, latLngPoint.longitude));
      }
    }

    final boundsPoints = <LatLng>[
      pickupGeoGraphicCoOrdinates,
      dropOffDestinationGeoGraphicCoOrdinates,
      ...polylineCoOrdinates,
    ];

    setState(() {
      mapPolylines = [
        Polyline(
          points: List<LatLng>.from(polylineCoOrdinates),
          color: Colors.pink,
          strokeWidth: 4,
        ),
      ];

      mapMarkers = [
        Marker(
          key: const ValueKey('pickup'),
          point: pickupGeoGraphicCoOrdinates,
          width: 44,
          height: 44,
          alignment: Alignment.bottomCenter,
          child: Tooltip(
            message: resolvedPickup.placeName ?? 'Pickup',
            child: const Icon(Icons.location_pin, color: Colors.green, size: 44),
          ),
        ),
        Marker(
          key: const ValueKey('dropoff'),
          point: dropOffDestinationGeoGraphicCoOrdinates,
          width: 44,
          height: 44,
          alignment: Alignment.bottomCenter,
          child: Tooltip(
            message: resolvedDropoff.placeName ?? 'Destination',
            child: const Icon(Icons.location_pin, color: Colors.amber, size: 44),
          ),
        ),
      ];

      mapCircles = [
        CircleMarker(
          point: pickupGeoGraphicCoOrdinates,
          radius: 14,
          useRadiusInMeter: true,
          color: Colors.pink.withValues(alpha: 0.35),
          borderStrokeWidth: 4,
          borderColor: Colors.blue,
        ),
        CircleMarker(
          point: dropOffDestinationGeoGraphicCoOrdinates,
          radius: 14,
          useRadiusInMeter: true,
          color: Colors.pink.withValues(alpha: 0.35),
          borderStrokeWidth: 4,
          borderColor: Colors.blue,
        ),
      ];
    });

    if (boundsPoints.length >= 2 && mounted) {
      try {
        mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(boundsPoints),
            padding: EdgeInsets.fromLTRB(72, 72, 72, 72 + bottomMapPadding),
          ),
        );
      } catch (e, st) {
        debugPrint('mapController.fitCamera: $e\n$st');
      }
    }
    return true;
  }

  void _showLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: Text(AppLocalizations.of(ctx)!.languageSystem),
              onTap: () {
                context.read<LocaleController>().setLocale(null);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.abc),
              title: Text(AppLocalizations.of(ctx)!.languageArabic),
              onTap: () {
                context.read<LocaleController>().setLocale(const Locale('ar'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(AppLocalizations.of(ctx)!.languageEnglish),
              onTap: () {
                context.read<LocaleController>().setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  resetAppNow()
  {
    final loc = AppLocalizations.of(context)!;
    Provider.of<AppInfo>(context, listen: false)
        .setTripBookingKind(TripBookingKind.externalByDistance);
    setState(() {
      polylineCoOrdinates.clear();
      mapPolylines.clear();
      mapMarkers.clear();
      mapCircles.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchContainerHeight = 124;
      bottomMapPadding = 0;
      isDrawerOpened = true;

      status = "";
      nameDriver = "";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = loc.driverArriving;
      _lastLiveDriverRouteOrigin = null;
    });
  }

  List<LatLng> _decodeRoutePolyline(String? encoded, LatLng fallbackA, LatLng fallbackB) {
    if (encoded == null || encoded.isEmpty) {
      return [fallbackA, fallbackB];
    }
    try {
      final decoded = _liveRoutePolylineDecoder.decodePolyline(encoded);
      if (decoded.isEmpty) return [fallbackA, fallbackB];
      return decoded
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList(growable: false);
    } catch (e, st) {
      debugPrint('_decodeRoutePolyline: $e\n$st');
      return [fallbackA, fallbackB];
    }
  }

  bool _shouldRefreshLiveDriverRoute(LatLng driverPos) {
    final last = _lastLiveDriverRouteOrigin;
    if (last == null) return true;
    return Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          driverPos.latitude,
          driverPos.longitude,
        ) >=
        AppConfig.driverRouteRefreshMinDistanceMeters;
  }

  void _fitLiveTripCamera({
    required LatLng driverLatLng,
    required LatLng targetLatLng,
    required List<LatLng> routePoints,
    required bool showDropoff,
  }) {
    if (!mounted) return;

    final boundsPoints = <LatLng>[
      driverLatLng,
      targetLatLng,
      ...routePoints,
    ];
    final drop =
        Provider.of<AppInfo>(context, listen: false).dropOffLocation;
    if (showDropoff &&
        drop?.latitudePosition != null &&
        drop?.longitudePosition != null) {
      boundsPoints.add(
        LatLng(drop!.latitudePosition!, drop.longitudePosition!),
      );
    }
    if (boundsPoints.length < 2) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(boundsPoints),
            padding: EdgeInsets.fromLTRB(56, 56, 56, 56 + bottomMapPadding),
          ),
        );
      } catch (e, st) {
        debugPrint('mapController.fitCamera (live driver): $e\n$st');
      }
    });
  }

  void _applyLiveDriverMap({
    required LatLng driverLatLng,
    required LatLng targetLatLng,
    required List<LatLng> routePoints,
    required bool showDropoff,
  }) {
    final appInfo = Provider.of<AppInfo>(context, listen: false);
    final pick = appInfo.pickUpLocation;
    final drop = appInfo.dropOffLocation;

    final points = routePoints.length >= 2
        ? routePoints
        : <LatLng>[driverLatLng, targetLatLng];

    final markers = <Marker>[
      Marker(
        key: const ValueKey('active_driver'),
        point: driverLatLng,
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/tracking.png',
          fit: BoxFit.contain,
        ),
      ),
    ];

    if (pick?.latitudePosition != null && pick?.longitudePosition != null) {
      final pickLl = LatLng(pick!.latitudePosition!, pick.longitudePosition!);
      markers.add(
        Marker(
          key: const ValueKey('pickup'),
          point: pickLl,
          width: 44,
          height: 44,
          alignment: Alignment.bottomCenter,
          child: Tooltip(
            message: pick.placeName ?? 'Pickup',
            child: const Icon(Icons.location_pin, color: Colors.green, size: 44),
          ),
        ),
      );
    }

    if (showDropoff &&
        drop?.latitudePosition != null &&
        drop?.longitudePosition != null) {
      final dropLl = LatLng(drop!.latitudePosition!, drop.longitudePosition!);
      markers.add(
        Marker(
          key: const ValueKey('dropoff'),
          point: dropLl,
          width: 44,
          height: 44,
          alignment: Alignment.bottomCenter,
          child: Tooltip(
            message: drop.placeName ?? 'Destination',
            child: const Icon(Icons.location_pin, color: Colors.amber, size: 44),
          ),
        ),
      );
    }

    final circles = <CircleMarker>[];
    if (pick?.latitudePosition != null && pick?.longitudePosition != null) {
      final pickLl = LatLng(pick!.latitudePosition!, pick.longitudePosition!);
      circles.add(
        CircleMarker(
          point: pickLl,
          radius: 14,
          useRadiusInMeter: true,
          color: Colors.green.withValues(alpha: 0.25),
          borderStrokeWidth: 3,
          borderColor: Colors.green,
        ),
      );
    }
    if (showDropoff &&
        drop?.latitudePosition != null &&
        drop?.longitudePosition != null) {
      final dropLl = LatLng(drop!.latitudePosition!, drop.longitudePosition!);
      circles.add(
        CircleMarker(
          point: dropLl,
          radius: 14,
          useRadiusInMeter: true,
          color: Colors.amber.withValues(alpha: 0.25),
          borderStrokeWidth: 3,
          borderColor: Colors.amber,
        ),
      );
    }

    setState(() {
      polylineCoOrdinates = List<LatLng>.from(points);
      mapPolylines = [
        Polyline(
          points: List<LatLng>.from(points),
          color: Colors.lightBlueAccent,
          strokeWidth: 5,
        ),
      ];
      mapMarkers = markers;
      mapCircles = circles;
    });

    _fitLiveTripCamera(
      driverLatLng: driverLatLng,
      targetLatLng: targetLatLng,
      routePoints: points,
      showDropoff: showDropoff,
    );
  }

  Future<void> _refreshLiveDriverRoute({
    required LatLng driverLatLng,
    required LatLng targetLatLng,
    required bool showDropoff,
    required void Function(DirectionDetails? details) onEta,
  }) async {
    if (!mounted) return;

    final movedEnough = _shouldRefreshLiveDriverRoute(driverLatLng);
    if (!movedEnough) {
      _applyLiveDriverMap(
        driverLatLng: driverLatLng,
        targetLatLng: targetLatLng,
        routePoints: polylineCoOrdinates,
        showDropoff: showDropoff,
      );
      return;
    }

    if (requestingDirectionDetailsInfo) {
      _applyLiveDriverMap(
        driverLatLng: driverLatLng,
        targetLatLng: targetLatLng,
        routePoints: polylineCoOrdinates,
        showDropoff: showDropoff,
      );
      return;
    }

    requestingDirectionDetailsInfo = true;
    try {
      final details = await CommonMethods.getDirectionDetailsFromAPI(
        driverLatLng,
        targetLatLng,
      );
      if (!mounted) return;

      _lastLiveDriverRouteOrigin = driverLatLng;
      onEta(details);

      final routePoints = _decodeRoutePolyline(
        details?.encodedPoints,
        driverLatLng,
        targetLatLng,
      );
      _applyLiveDriverMap(
        driverLatLng: driverLatLng,
        targetLatLng: targetLatLng,
        routePoints: routePoints,
        showDropoff: showDropoff,
      );
    } finally {
      requestingDirectionDetailsInfo = false;
    }
  }

  cancelRideRequest()
  {
    final ref = tripRequestRef;
    if (ref != null) {
      unawaited(ref.onDisconnect().cancel());
      unawaited(ref.remove());
    }
    tripRequestRef = null;

    _driverResponseSubscription?.cancel();
    _driverResponseSubscription = null;
    _driverResponseTimer?.cancel();
    _driverResponseTimer = null;
    tripStreamSubscription?.cancel();
    tripStreamSubscription = null;

    setState(() {
      stateOfApp = "normal";
    });
  }

  displayRequestContainer()
  {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 220;
      bottomMapPadding = 200;
      isDrawerOpened = true;
    });

    //send ride request
    makeTripRequest();
  }

  updateAvailableNearbyOnlineDriversOnMap()
  {
    setState(() {
      mapMarkers = ManageDriversMethods.nearbyOnlineDriversList.map((eachOnlineNearbyDriver) {
        return Marker(
          key: ValueKey<String>('driver_${eachOnlineNearbyDriver.uidDriver}'),
          point: LatLng(
            eachOnlineNearbyDriver.latDriver!,
            eachOnlineNearbyDriver.lngDriver!,
          ),
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/tracking.png',
            fit: BoxFit.contain,
          ),
        );
      }).toList();
    });
  }
  
  /// مركز البحث عن سائقين متصلين: **نقطة الانطلاق** من الطلب إن وُجدت، وإلا موقع GPS للراكب.
  /// بدون ذلك، رحلة خارجية بانطلاق بعيد عن موقع الهاتف لا تجد سائقين بالقرب من الانطلاق.
  LatLng? _driverSearchAnchorLatLng() {
    if (!mounted) return null;
    final pick = Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    if (pick?.latitudePosition != null && pick?.longitudePosition != null) {
      return LatLng(pick!.latitudePosition!, pick.longitudePosition!);
    }
    final gps = currentPositionOfUser;
    if (gps != null) {
      return LatLng(gps.latitude, gps.longitude);
    }
    return null;
  }

  void _applyOnlineDriversSnapshot(DataSnapshot snapshot) {
    ManageDriversMethods.nearbyOnlineDriversList.clear();
    if (!snapshot.exists) return;
    final anchor = _driverSearchAnchorLatLng();
    if (anchor == null) return;
    const distance = Distance();
    final radiusMeters = AppConfig.geofireRadius * 1000;
    for (final child in snapshot.children) {
      final key = child.key;
      if (key == null) continue;
      final loc = ManageDriversMethods.readGeoFireLocation(child);
      if (loc == null) continue;
      if (!AppConfig.isInsideServiceGovernorate(loc.lat, loc.lng)) {
        continue;
      }
      final driverPoint = LatLng(loc.lat, loc.lng);
      final meters = distance.as(LengthUnit.Meter, anchor, driverPoint);
      if (meters <= radiusMeters) {
        final d = OnlineNearbyDrivers()
          ..uidDriver = key
          ..latDriver = loc.lat
          ..lngDriver = loc.lng;
        ManageDriversMethods.nearbyOnlineDriversList.add(d);
      }
    }
  }

  /// تحديث فوري لقائمة السائقين قبل إرسال الطلب (حتى لو لم يأتِ حدث GeoFire جديد).
  Future<void> refreshNearbyOnlineDriversNow() async {
    final snap = await FirebaseDatabase.instance.ref(AppConfig.geofirePath).get();
    if (!mounted) return;
    _applyOnlineDriversSnapshot(snap);
    nearbyOnlineDriversKeysLoaded = true;
    updateAvailableNearbyOnlineDriversOnMap();
  }

  /// أقرب السائقين عبر Realtime DB تحت [AppConfig.geofirePath] مع فلترة المسافة في Dart.
  /// لا نستخدم مكتبة GeoFire الأصلية — أي سجل بلا `l` يُتخطّى بدلاً من إنهاء العملية.
  Future<void> initializeGeoFireListener() async {
    await _onlineDriversSubscription?.cancel();
    _onlineDriversSubscription = null;

    final ref = FirebaseDatabase.instance.ref(AppConfig.geofirePath);

    try {
      _onlineDriversSubscription = ref.onValue.listen(
        (DatabaseEvent event) {
          if (!mounted) return;
          _applyOnlineDriversSnapshot(event.snapshot);
          nearbyOnlineDriversKeysLoaded = true;
          updateAvailableNearbyOnlineDriversOnMap();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (mounted) {
            ErrorHandler.handleMapError(error, context);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleMapError(e, context);
      }
    }
  }

  makeTripRequest()
  {
    try {
      final appInfo = Provider.of<AppInfo>(context, listen: false);
      final pickUpLocation = appInfo.pickUpLocation;
      final dropOffDestinationLocation = appInfo.dropOffLocation;
      final loc = AppLocalizations.of(context)!;

      if (pickUpLocation == null ||
          pickUpLocation.latitudePosition == null ||
          pickUpLocation.longitudePosition == null ||
          dropOffDestinationLocation == null ||
          dropOffDestinationLocation.latitudePosition == null ||
          dropOffDestinationLocation.longitudePosition == null) {
        cMethods.displaySnackBar(loc.tripRequestDataIncomplete, context);
        return;
      }

      final pLat = pickUpLocation.latitudePosition!;
      final pLon = pickUpLocation.longitudePosition!;
      final dLat = dropOffDestinationLocation.latitudePosition!;
      final dLon = dropOffDestinationLocation.longitudePosition!;
      if (!AppConfig.isInsideServiceGovernorate(pLat, pLon) ||
          !AppConfig.isInsideServiceGovernorate(dLat, dLon)) {
        cMethods.displaySnackBar(loc.pickupOutsideServiceArea, context);
        return;
      }

      tripRequestRef = FirebaseDatabase.instance.ref().child(AppConfig.tripRequestsPath).push();

    Map pickUpCoOrdinatesMap =
    {
      "latitude": pickUpLocation.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };

    Map dropOffDestinationCoOrdinatesMap =
    {
      "latitude": dropOffDestinationLocation.latitudePosition.toString(),
      "longitude": dropOffDestinationLocation.longitudePosition.toString(),
    };

    Map driverCoOrdinates =
    {
      "latitude": "",
      "longitude": "",
    };

    Map dataMap =
    {
      "tripID": tripRequestRef!.key,
      "publishDateTime": DateTime.now().toString(),

      "userName": userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickUpLatLng": pickUpCoOrdinatesMap,
      "dropOffLatLng": dropOffDestinationCoOrdinatesMap,
      "pickUpAddress": pickUpLocation.placeName,
      "dropOffAddress": dropOffDestinationLocation.placeName,

      "driverID": "waiting",
      "carDetails": "",
      "driverLocation": driverCoOrdinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "fareAmount": "",
      "status": "new",
      "tripKind": appInfo.tripBookingKind == TripBookingKind.internalFixed
          ? "internal"
          : "external",
    };

    tripRequestRef!.set(dataMap);
    // لا نترك رحلات معلقة لو التطبيق اتقفل فجأة أثناء الطلب.
    unawaited(tripRequestRef!.onDisconnect().remove());

    tripStreamSubscription = tripRequestRef!.onValue.listen((eventSnapshot) async
    {
      if(eventSnapshot.snapshot.value == null)
      {
        return;
      }

      final tripData = eventSnapshot.snapshot.value as Map;
      final prevTripStatus = status;

      if(tripData["driverName"] != null)
      {
        nameDriver = tripData["driverName"];
      }

      if(tripData["driverPhone"] != null)
      {
        phoneNumberDriver = tripData["driverPhone"];
      }

      if(tripData["driverPhoto"] != null)
      {
        photoDriver = tripData["driverPhoto"];
      }

      if(tripData["carDetails"] != null)
      {
        carDetailsDriver = tripData["carDetails"];
      }

      if(tripData["status"] != null)
      {
        status = tripData["status"].toString();
      }

      if (mounted &&
          prevTripStatus != "arrived" &&
          status == "arrived") {
        final loc = AppLocalizations.of(context)!;
        RiderNotificationService.showDriverArrived(
          title: loc.driverArrivedNotificationTitle,
          body: loc.driverArrivedNotificationBody,
        );
        setState(() {
          tripStatusDisplay = loc.driverHasArrived;
        });
      }

      if (prevTripStatus != status) {
        if (status == 'accepted' || status == 'ontrip') {
          _lastLiveDriverRouteOrigin = null;
          polylineCoOrdinates.clear();
        }
      }

      if(tripData["driverLocation"] != null)
      {
        double driverLatitude = double.parse(tripData["driverLocation"]["latitude"].toString());
        double driverLongitude = double.parse(tripData["driverLocation"]["longitude"].toString());
        final driverCurrentLocationLatLng = LatLng(driverLatitude, driverLongitude);

        if(status == "accepted" || status == "arrived")
        {
          updateFromDriverCurrentLocationToPickUp(driverCurrentLocationLatLng);
        }
        else if(status == "ontrip")
        {
          updateFromDriverCurrentLocationToDropOffDestination(driverCurrentLocationLatLng);
        }
      }

      if(status == "accepted")
      {
        if (mounted && prevTripStatus != "accepted") {
          setState(() {
            tripStatusDisplay =
                AppLocalizations.of(context)!.estimatingDriverEta;
          });
        }

        displayTripDetailsContainer();

        _onlineDriversSubscription?.cancel();
        _onlineDriversSubscription = null;

        //remove drivers markers
        setState(() {
          mapMarkers.removeWhere((m) {
            final k = m.key;
            if (k is ValueKey<String>) {
              return k.value.startsWith('driver_');
            }
            return false;
          });
        });
      }

      if (status == "ended") {
        if (_tripEndedFlowActive || tripData["fareAmount"] == null) {
          return;
        }
        _tripEndedFlowActive = true;

        double fareAmount =
            double.parse(tripData["fareAmount"].toString());

        if (!mounted) {
          _tripEndedFlowActive = false;
          return;
        }

        var responseFromPaymentDialog = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              PaymentDialog(fareAmount: fareAmount.toString()),
        );

        if (!mounted || responseFromPaymentDialog != "paid") {
          _tripEndedFlowActive = false;
          return;
        }

        final tripId = tripRequestRef!.key!;
        final driverId = tripData["driverID"]?.toString() ?? '';
        final driverDispName = tripData["driverName"] != null
            ? tripData["driverName"].toString()
            : nameDriver;

        if (!mounted) {
          _tripEndedFlowActive = false;
          return;
        }

        final ratingResult = await showDialog<PostTripRatingResult?>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => PostTripRatingDialog(
            driverName: driverDispName,
          ),
        );

        if (mounted && ratingResult != null) {
          try {
            await RiderFeedbackService.submitTripRating(
              tripId: tripId,
              driverId: driverId,
              driverName: driverDispName,
              driverStars: ratingResult.stars,
              serviceStars: ratingResult.stars,
              comment: ratingResult.comment,
            );
          } catch (e, st) {
            debugPrint('submitTripRating: $e\n$st');
          }
        }

        await tripRequestRef!.onDisconnect().cancel();
        tripRequestRef = null;

        tripStreamSubscription!.cancel();
        tripStreamSubscription = null;

        resetAppNow();

        Restart.restartApp();
      }
    }, onError: (error) {
      if (mounted) {
        ErrorHandler.handleFirebaseError(error, context);
      }
    });
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleFirebaseError(e, context);
      }
    }
  }

  displayTripDetailsContainer()
  {
    setState(() {
      requestContainerHeight = 0;
      tripContainerHeight = 291;
      bottomMapPadding = 281;
    });
  }

  updateFromDriverCurrentLocationToPickUp(LatLng driverCurrentLocationLatLng) async
  {
    final pick = Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    final LatLng userPickUpLocationLatLng;
    if (pick?.latitudePosition != null && pick?.longitudePosition != null) {
      userPickUpLocationLatLng = LatLng(
        pick!.latitudePosition!,
        pick.longitudePosition!,
      );
    } else if (currentPositionOfUser != null) {
      userPickUpLocationLatLng = LatLng(
        currentPositionOfUser!.latitude,
        currentPositionOfUser!.longitude,
      );
    } else {
      return;
    }

    await _refreshLiveDriverRoute(
      driverLatLng: driverCurrentLocationLatLng,
      targetLatLng: userPickUpLocationLatLng,
      showDropoff: false,
      onEta: (directionDetailsPickup) {
        if (!mounted) return;
        final loc = AppLocalizations.of(context)!;
        final eta = directionDetailsPickup?.durationTextString ?? loc.dash;
        setState(() {
          tripStatusDisplay = loc.driverComingEta(eta);
        });
      },
    );
  }

  updateFromDriverCurrentLocationToDropOffDestination(LatLng driverCurrentLocationLatLng) async
  {
    final dropOffLocation =
        Provider.of<AppInfo>(context, listen: false).dropOffLocation;
    if (dropOffLocation?.latitudePosition == null ||
        dropOffLocation?.longitudePosition == null) {
      return;
    }
    final userDropOffLocationLatLng = LatLng(
      dropOffLocation!.latitudePosition!,
      dropOffLocation.longitudePosition!,
    );

    await _refreshLiveDriverRoute(
      driverLatLng: driverCurrentLocationLatLng,
      targetLatLng: userDropOffLocationLatLng,
      showDropoff: true,
      onEta: (directionDetails) {
        if (!mounted) return;
        final loc = AppLocalizations.of(context)!;
        final eta = directionDetails?.durationTextString ?? loc.dash;
        setState(() {
          tripStatusDisplay = loc.drivingToDropoffEta(eta);
        });
      },
    );
  }

  noDriverAvailable()
  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => InfoDialog(
          title: "لا يوجد سائق متاح حالياً",
          description: "لا يوجد سائق متاح حالياً، برجاء التواصل معنا الآن.",
          imageAssetPath: "assets/waslny_contact_card.jpeg",
        )
    );
  }

  Future<bool> _isDriverBusyWithActiveTrip(String driverId) async {
    try {
      final rawStatus = await FirebaseDatabase.instance
          .ref()
          .child(AppConfig.driversPath)
          .child(driverId)
          .child('newTripStatus')
          .get();

      final statusValue = rawStatus.value?.toString().trim() ?? '';
      if (statusValue.isEmpty) return false;

      const freeMarkers = <String>{
        'idle',
        'waiting',
        'available',
        'online',
        'timeout',
        'cancelled',
        'canceled',
        'ended',
        'none',
        'null',
      };
      if (freeMarkers.contains(statusValue.toLowerCase())) {
        return false;
      }

      final tripSnap = await FirebaseDatabase.instance
          .ref()
          .child(AppConfig.tripRequestsPath)
          .child(statusValue)
          .get();
      if (!tripSnap.exists || tripSnap.value is! Map) {
        // قيمة قديمة/غير صالحة في newTripStatus، نعتبر السائق متاحاً.
        return false;
      }

      final tripMap = Map<String, dynamic>.from(tripSnap.value as Map);
      final tripStatus = (tripMap['status']?.toString() ?? '').toLowerCase();
      const closedTripStatuses = <String>{
        'ended',
        'cancelled',
        'canceled',
        'expired',
      };
      if (closedTripStatuses.contains(tripStatus)) {
        return false;
      }

      final assignedDriverId = tripMap['driverID']?.toString() ?? '';
      if (assignedDriverId.isNotEmpty &&
          assignedDriverId != 'waiting' &&
          assignedDriverId != driverId) {
        // نفس tripId موجود لكنه متحوّل لسائق آخر، إذن هذا السائق متاح لطلب جديد.
        return false;
      }

      return true;
    } catch (_) {
      // في حال فشل القراءة، لا نحجب السائق حتى لا نوقف التخصيص بالكامل.
      return false;
    }
  }

  Future<void> searchDriver() async
  {
    if (availableNearbyOnlineDriversList == null ||
        availableNearbyOnlineDriversList!.isEmpty) {
      cancelRideRequest();
      resetAppNow();
      noDriverAvailable();
      return;
    }

    while (availableNearbyOnlineDriversList!.isNotEmpty) {
      final currentDriver = availableNearbyOnlineDriversList!.removeAt(0);
      final isBusy = await _isDriverBusyWithActiveTrip(
        currentDriver.uidDriver.toString(),
      );
      if (isBusy) {
        continue;
      }

      // send notification to this currentDriver - currentDriver means selected driver
      sendNotificationToDriver(currentDriver);
      return;
    }

    cancelRideRequest();
    resetAppNow();
    noDriverAvailable();
  }

  /// يرتّب السائقين تصاعديًا حسب المسافة من نقطة الانطلاق (أو GPS إن لم تتوفر).
  void sortAvailableDriversByDistance() {
    final drivers = availableNearbyOnlineDriversList;
    if (drivers == null || drivers.length < 2) return;
    final anchor = _driverSearchAnchorLatLng();
    if (anchor == null) return;

    const distance = Distance();
    drivers.sort((a, b) {
      final aLat = a.latDriver;
      final aLng = a.lngDriver;
      final bLat = b.latDriver;
      final bLng = b.lngDriver;

      if (aLat == null || aLng == null) return 1;
      if (bLat == null || bLng == null) return -1;

      final da = distance.as(
        LengthUnit.Meter,
        anchor,
        LatLng(aLat, aLng),
      );
      final db = distance.as(
        LengthUnit.Meter,
        anchor,
        LatLng(bLat, bLng),
      );
      return da.compareTo(db);
    });
  }

  /// يخصص الطلب للسائق عبر [newTripStatus] فقط (Local-notification flow on driver app).
  sendNotificationToDriver(OnlineNearbyDrivers currentDriver) {
    try {
      final tripId = tripRequestRef!.key;
      if (tripId == null || tripId.isEmpty) {
        return;
      }

      final currentDriverRef = FirebaseDatabase.instance
          .ref()
          .child(AppConfig.driversPath)
          .child(currentDriver.uidDriver.toString())
          .child('newTripStatus');

      _driverResponseSubscription?.cancel();
      _driverResponseTimer?.cancel();

      currentDriverRef.set(tripId).then((_) {
        if (!mounted) return;
        unawaited(currentDriverRef.onDisconnect().set('timeout'));
        unawaited(
          DriverTripPush.sendNewTripAlert(
            driverUid: currentDriver.uidDriver.toString(),
            tripId: tripId,
          ),
        );

        _driverResponseSubscription = currentDriverRef.onValue.listen(
          (DatabaseEvent event) {
            if (event.snapshot.value?.toString() == 'accepted') {
              _driverResponseTimer?.cancel();
              _driverResponseSubscription?.cancel();
              _driverResponseSubscription = null;
              _driverResponseTimer = null;
              currentDriverRef.onDisconnect().cancel();
              requestTimeoutDriver = AppConfig.requestTimeoutSeconds;
            }
          },
        );

        _driverResponseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          requestTimeoutDriver = requestTimeoutDriver - 1;

          if (stateOfApp != 'requesting') {
            timer.cancel();
            _driverResponseSubscription?.cancel();
            _driverResponseSubscription = null;
            _driverResponseTimer = null;
            currentDriverRef.set('cancelled');
            currentDriverRef.onDisconnect().cancel();
            requestTimeoutDriver = AppConfig.requestTimeoutSeconds;
            return;
          }

          if (requestTimeoutDriver == 0) {
            timer.cancel();
            _driverResponseSubscription?.cancel();
            _driverResponseSubscription = null;
            _driverResponseTimer = null;
            currentDriverRef.set('timeout');
            currentDriverRef.onDisconnect().cancel();
            requestTimeoutDriver = AppConfig.requestTimeoutSeconds;
            unawaited(searchDriver());
          }
        });
      }).catchError((Object error) {
        if (mounted) {
          ErrorHandler.handleFirebaseError(error, context);
        }
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleFirebaseError(e, context);
      }
    }
  }

  Widget _buildHomeBottomAction({
    IconData? icon,
    String? imageAssetPath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: imageAssetPath != null
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            imageAssetPath,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(icon, color: const Color(0xFFD32F2F), size: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeBottomActionsPanel(AppLocalizations loc) {
    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black26,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
          child: Row(
            children: [
              _buildHomeBottomAction(
                imageAssetPath: 'assets/images/automobile.png',
                label: loc.homeBottomRequestTrip,
                onPressed: () async {
                  final responseFromSearchPage = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const SearchDestinationPage(),
                    ),
                  );

                  if (responseFromSearchPage == 'placeSelected' ||
                      responseFromSearchPage == 'internalTripReady') {
                    if (mounted) displayUserRideDetailsContainer();
                  }
                },
              ),
              _buildHomeBottomAction(
                icon: Icons.home,
                label: loc.homeBottomMainMap,
                onPressed: () {
                  final pos = currentPositionOfUser;
                  if (pos == null) {
                    cMethods.displaySnackBar(loc.locationGpsError, context);
                    return;
                  }
                  try {
                    mapController.move(
                      LatLng(pos.latitude, pos.longitude),
                      AppConfig.defaultZoom,
                    );
                  } catch (e, st) {
                    debugPrint('mapController.move (home): $e\n$st');
                  }
                },
              ),
              _buildHomeBottomAction(
                imageAssetPath: 'assets/images/uber_taxi.png',
                label: loc.homeBottomSubscriptions,
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SubscriptionTripsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context)
  {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 255,
        color: const Color(0xFFD32F2F),
        child: Drawer(
          backgroundColor: const Color(0xFFD32F2F),
          child: ListView(
            children: [

              const Divider(
                height: 1,
                color: Colors.white24,
                thickness: 1,
              ),

              //header
              Container(
                color: const Color(0xFFB71C1C),
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFFB71C1C),
                  ),
                  child: Row(
                    children: [

                      Image.asset(
                        "assets/images/avatarman.png",
                        width: 60,
                        height: 60,
                      ),

                      const SizedBox(width: 16,),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              userName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4,),

                            Text(
                              loc.profile,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              const Divider(
                height: 1,
                color: Colors.white24,
                thickness: 1,
              ),

              const SizedBox(height: 10,),

              //body
              GestureDetector(
                onTap: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> TripsHistoryPage()));
                },
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.white),
                  title: Text(loc.history, style: const TextStyle(color: Colors.white),),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const ComplaintsSuggestionsPage(),
                    ),
                  );
                },
                child: ListTile(
                  leading: const Icon(Icons.feedback_outlined, color: Colors.white),
                  title: Text(
                    loc.feedbackMenuTitle,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              GestureDetector(
                onTap: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> AboutPage()));
                },
                child: ListTile(
                  leading: const Icon(Icons.info, color: Colors.white),
                  title: Text(loc.about, style: const TextStyle(color: Colors.white),),
                ),
              ),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const PrivacyPolicyPage()),
                  );
                },
                child: ListTile(
                  leading: const Icon(Icons.policy_outlined, color: Colors.white),
                  title: Text(
                    loc.privacyPolicyTitle,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.white),
                title: Text(
                  loc.deleteAccountMenuTitle,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAccountFlow();
                },
              ),

              ListTile(
                leading: const Icon(Icons.language, color: Colors.white),
                title: Text(loc.language, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.phone_android),
                            title: Text(AppLocalizations.of(ctx)!.languageSystem),
                            onTap: () {
                              context.read<LocaleController>().setLocale(null);
                              Navigator.pop(ctx);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.abc),
                            title: Text(AppLocalizations.of(ctx)!.languageArabic),
                            onTap: () {
                              context.read<LocaleController>().setLocale(const Locale('ar'));
                              Navigator.pop(ctx);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.translate),
                            title: Text(AppLocalizations.of(ctx)!.languageEnglish),
                            onTap: () {
                              context.read<LocaleController>().setLocale(const Locale('en'));
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              GestureDetector(
                onTap: ()
                {
                  FirebaseAuth.instance.signOut();

                  Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: Text(loc.logout, style: const TextStyle(color: Colors.white),),
                ),
              ),

            ],
          ),
        ),
      ),
      body: Stack(
        children: [

          /// الخريطة لا تمتد تحت شريط الأزرار حتى لا تسرق اللمسات.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: searchContainerHeight,
            child: MapWidget(
              mapController: mapController,
              polylines: mapPolylines,
              markers: mapMarkers,
              circles: mapCircles,
              bottomPadding: bottomMapPadding,
              onMapReady: () {
                if (!mounted) return;
                setState(() {
                  bottomMapPadding = 0;
                });
                if (_mapBootstrapDone) return;
                _mapBootstrapDone = true;
                /// تأخير بسيط يقلل تعارض محرك الخريطة مع GPS وحوار الإذن عند أول فتح (OPPO/سامسونغ)
                Future.delayed(const Duration(milliseconds: 700), () {
                  if (mounted) getCurrentLiveLocationOfUser();
                });
              },
            ),
          ),

          ///drawer button
          Positioned(
            top: 36,
            left: 19,
            child: GestureDetector(
              onTap: ()
              {
                if(isDrawerOpened == true)
                {
                  sKey.currentState!.openDrawer();
                }
                else
                {
                  resetAppNow();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const
                  [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Icon(
                    isDrawerOpened == true ? Icons.menu : Icons.close,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          /// تبديل اللغة (نفس الخيارات الموجودة في الدرج)
          Positioned(
            top: 36,
            right: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              elevation: 3,
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                tooltip: loc.language,
                onPressed: _showLanguagePicker,
                icon: const Icon(Icons.language, color: Colors.black87),
              ),
            ),
          ),

          /// بانل الأزرار السفلي: طلب رحلة — الرئيسية — الاشتراكات
          if (searchContainerHeight > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: searchContainerHeight,
                child: _buildHomeBottomActionsPanel(loc),
              ),
            ),

          ///ride details container - استخدام RideDetailsContainer
          if (rideDetailsContainerHeight > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: rideDetailsContainerHeight,
                child: Consumer<AppInfo>(
                  builder: (context, appInfo, _) {
                    return RideDetailsContainer(
                      tripDirectionDetailsInfo: tripDirectionDetailsInfo,
                      tripBookingKind: appInfo.tripBookingKind,
                      onRequestRide: () async {
                        setState(() {
                          stateOfApp = "requesting";
                        });

                        displayRequestContainer();

                        await refreshNearbyOnlineDriversNow();
                        if (!mounted) return;

                        availableNearbyOnlineDriversList =
                            List<OnlineNearbyDrivers>.from(
                              ManageDriversMethods.nearbyOnlineDriversList,
                            );

                        sortAvailableDriversByDistance();

                        await searchDriver();
                      },
                    );
                  },
                ),
              ),
            ),

          ///request container - استخدام RequestContainer
          if (requestContainerHeight > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: requestContainerHeight,
                child: RequestContainer(
                  onCancel: () {
                    resetAppNow();
                    cancelRideRequest();
                  },
                ),
              ),
            ),

          ///trip details container - استخدام TripDetailsContainer
          if (tripContainerHeight > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: tripContainerHeight,
                child: const TripDetailsContainer(),
              ),
            ),
        ],
      ),
    );
  }
}
