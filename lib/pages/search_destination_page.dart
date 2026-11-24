import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/config/app_config.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/models/address_model.dart';
import 'package:users_app/models/prediction_model.dart';
import 'package:users_app/models/trip_booking_kind.dart';
import 'package:users_app/widgets/prediction_place_ui.dart';
import 'package:users_app/widgets/loading_dialog.dart';

import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/services/remote_pricing.dart';

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({super.key});

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController pickUpTextEditingController =
      TextEditingController();
  final TextEditingController destinationTextEditingController =
      TextEditingController();
  List<PredictionModel> pickUpPredictionsPlacesList = [];
  List<PredictionModel> dropOffPredictionsPlacesList = [];
  Timer? _searchDebounce;
  bool _searchLoading = false;
  bool _pickupResolving = false;

  bool _isGenericPickupLabel(String text, AppLocalizations loc) {
    final t = text.trim();
    if (t.isEmpty) return true;
    return t == loc.currentLocationFallback ||
        t == 'My current location' ||
        t == 'موقعي الحالي';
  }

  Future<void> _resolvePickupFromGps({bool showSnackBar = false}) async {
    if (!mounted || _pickupResolving) return;
    final loc = AppLocalizations.of(context)!;
    final app = context.read<AppInfo>();

    setState(() => _pickupResolving = true);
    final fromGps = await CommonMethods.pickupFromDeviceGps(
      preferredLabel: pickUpTextEditingController.text,
      fallbackLabel: loc.currentLocationFallback,
    );
    if (!mounted) return;
    setState(() => _pickupResolving = false);

    if (fromGps == null) {
      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.internalPickupRequired),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    app.updatePickUpLocation(fromGps);
    final label =
        fromGps.humanReadableAddress ?? fromGps.placeName ?? '';
    if (label.isNotEmpty) {
      pickUpTextEditingController.text = label;
    }
    setState(() {
      pickUpPredictionsPlacesList = [];
    });
    if (showSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.pickupAutoDetected),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _autoResolvePickupOnOpen() async {
    if (!mounted) return;
    final app = context.read<AppInfo>();
    final loc = AppLocalizations.of(context)!;
    final pickup = app.pickUpLocation;
    final existingLabel =
        pickup?.humanReadableAddress ?? pickup?.placeName ?? '';

    if (pickup?.latitudePosition != null &&
        pickup?.longitudePosition != null &&
        !_isGenericPickupLabel(existingLabel, loc)) {
      pickUpTextEditingController.text = existingLabel;
      return;
    }

    await _resolvePickupFromGps();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    RemotePricing.instance.addListener(_onRemotePricing);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final app = context.read<AppInfo>();
      app.setTripBookingKind(TripBookingKind.internalFixed);
      app.clearDropOffLocation();
      destinationTextEditingController.clear();
      _autoResolvePickupOnOpen();
    });
  }

  void _onRemotePricing() {
    if (mounted) setState(() {});
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (!mounted) return;
    final app = context.read<AppInfo>();
    if (_tabController.index == 0) {
      app.setTripBookingKind(TripBookingKind.internalFixed);
      app.clearDropOffLocation();
      destinationTextEditingController.clear();
      setState(() {
        dropOffPredictionsPlacesList = [];
      });
    } else {
      app.setTripBookingKind(TripBookingKind.externalByDistance);
    }
  }

  @override
  void dispose() {
    RemotePricing.instance.removeListener(_onRemotePricing);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchDebounce?.cancel();
    pickUpTextEditingController.dispose();
    destinationTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _continueInternalTrip() async {
    final loc = AppLocalizations.of(context)!;
    final app = context.read<AppInfo>();
    var p = app.pickUpLocation;
    if (p?.latitudePosition == null || p?.longitudePosition == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => LoadingDialog(messageText: loc.resolvingPickupGps),
      );
      final fromGps = await CommonMethods.pickupFromDeviceGps(
        preferredLabel: pickUpTextEditingController.text,
        fallbackLabel: loc.currentLocationFallback,
      );
      if (mounted) Navigator.pop(context);
      if (!mounted) return;
      if (fromGps == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.internalPickupRequired),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      app.updatePickUpLocation(fromGps);
      p = app.pickUpLocation;
    }
    if (p?.latitudePosition == null || p?.longitudePosition == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.internalPickupRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final destText = destinationTextEditingController.text.trim();
    if (destText.length < 3) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.internalDestinationRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    var drop = app.dropOffLocation;
    final resolvedLabel = (drop?.humanReadableAddress?.trim().isNotEmpty == true)
        ? drop!.humanReadableAddress!.trim()
        : (drop?.placeName?.trim().isNotEmpty == true
            ? drop!.placeName!.trim()
            : destText);

    app.updateDropOffLocation(
      AddressModel(
        placeName: resolvedLabel,
        humanReadableAddress: resolvedLabel,
        latitudePosition:
            drop?.latitudePosition ?? p?.latitudePosition,
        longitudePosition:
            drop?.longitudePosition ?? p?.longitudePosition,
        placeID: drop?.placeID ?? 'internal_destination_text',
      ),
    );

    app.setTripBookingKind(TripBookingKind.internalFixed);
    if (mounted) Navigator.pop(context, 'internalTripReady');
  }

  /// تأخير الطلبات لتقليل حظر Nominatim (سياسة الاستخدام ~طلب/ثانية)
  void scheduleSearchLocation(
    String locationName, {
    required bool forPickup,
    bool biasDesouk = false,
  }) {
    _searchDebounce?.cancel();
    if (locationName.length <= 1) {
      setState(() {
        _searchLoading = false;
        if (forPickup) {
          pickUpPredictionsPlacesList = [];
        } else {
          dropOffPredictionsPlacesList = [];
        }
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 700), () {
      _fetchPlaces(
        locationName,
        forPickup: forPickup,
        biasDesouk: biasDesouk,
      );
    });
  }

  Future<void> _fetchPlaces(
    String locationName, {
    required bool forPickup,
    bool biasDesouk = false,
  }) async {
    if (!mounted) return;
    setState(() => _searchLoading = true);

    final url = AppConfig.nominatimSearchUrl(
      locationName,
      biasDesouk: biasDesouk,
    );

    final responseFromPlacesAPI = await CommonMethods.sendRequestToAPI(
      url,
      headers: {
        'User-Agent': AppConfig.nominatimUserAgent,
        'Accept-Language': 'ar,en',
      },
    );

    if (!mounted) return;
    setState(() => _searchLoading = false);

    final loc = AppLocalizations.of(context)!;
    if (responseFromPlacesAPI is String &&
        responseFromPlacesAPI.startsWith('error_http_')) {
      final code = responseFromPlacesAPI.replaceFirst('error_http_', '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              code == '429'
                  ? loc.nominatimRateLimit
                  : loc.nominatimHttpError(code),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (responseFromPlacesAPI == 'error' || responseFromPlacesAPI is! List) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.nominatimConnectionError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    var predictionsList = responseFromPlacesAPI
        .map((e) => PredictionModel.fromNominatim(e as Map<String, dynamic>))
        .where((p) => p.latitude != null && p.longitude != null)
        .toList();

    if (!mounted) return;
    setState(() {
      if (forPickup) {
        pickUpPredictionsPlacesList = predictionsList;
        dropOffPredictionsPlacesList = [];
      } else {
        dropOffPredictionsPlacesList = predictionsList;
        pickUpPredictionsPlacesList = [];
      }
    });

    if (predictionsList.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.nominatimNoResults),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _pickupField(AppLocalizations loc) {
    return Row(
      children: [
        Image.asset(
          "assets/images/initial.png",
          height: 16,
          width: 16,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: TextField(
                controller: pickUpTextEditingController,
                textInputAction: TextInputAction.next,
                readOnly: _pickupResolving,
                onChanged: (s) => scheduleSearchLocation(s, forPickup: true),
                decoration: InputDecoration(
                  hintText: loc.fromPickupHint,
                  fillColor: Colors.white12,
                  filled: true,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.only(left: 11, top: 9, bottom: 9),
                  suffixIcon: _pickupResolving
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          tooltip: loc.useMyLocationTooltip,
                          icon: const Icon(
                            Icons.my_location,
                            color: Color(0xFFD32F2F),
                            size: 22,
                          ),
                          onPressed: () =>
                              _resolvePickupFromGps(showSnackBar: true),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _destinationField(
    AppLocalizations loc, {
    bool biasDesouk = false,
    String? hintText,
  }) {
    return Row(
      children: [
        Image.asset(
          "assets/images/final.png",
          height: 16,
          width: 16,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: TextField(
                controller: destinationTextEditingController,
                textInputAction: TextInputAction.search,
                onChanged: (s) {
                  if (biasDesouk) {
                    context.read<AppInfo>().clearDropOffLocation();
                  }
                  scheduleSearchLocation(
                    s,
                    forPickup: false,
                    biasDesouk: biasDesouk,
                  );
                },
                decoration: InputDecoration(
                  hintText: hintText ?? loc.toDestinationHint,
                  fillColor: Colors.white12,
                  filled: true,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.only(left: 11, top: 9, bottom: 9),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset + 16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 400,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 40,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          Center(
                            child: Text(
                              loc.planTripTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TabBar(
                        controller: _tabController,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: [
                          Tab(text: loc.tripTabInternal),
                          Tab(text: loc.tripTabExternal),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    loc.internalTabIntro(
                                      RemotePricing
                                          .instance.internalTabFixedFareEgp
                                          .toStringAsFixed(0),
                                    ),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _pickupField(loc),
                                  const SizedBox(height: 11),
                                  _destinationField(
                                    loc,
                                    biasDesouk: true,
                                    hintText: loc.internalDestinationHint,
                                  ),
                                  const Spacer(),
                                  FilledButton(
                                    onPressed: _continueInternalTrip,
                                    child: Text(loc.continueShowPrice),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    loc.externalTabIntro,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _pickupField(loc),
                                  const SizedBox(height: 11),
                                  _destinationField(loc),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_searchLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            if (pickUpPredictionsPlacesList.isNotEmpty)
              _buildPredictionsList(
                title: loc.pickupResults,
                list: pickUpPredictionsPlacesList,
                forPickup: true,
              ),
            if (dropOffPredictionsPlacesList.isNotEmpty)
              _buildPredictionsList(
                title: loc.dropoffResults,
                list: dropOffPredictionsPlacesList,
                forPickup: false,
                popOnDropoffSelect:
                    _tabController.index != 0,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsList({
    required String title,
    required List<PredictionModel> list,
    required bool forPickup,
    bool popOnDropoffSelect = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ListView.separated(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                child: PredictionPlaceUI(
                  predictedPlaceData: list[index],
                  forPickup: forPickup,
                  popOnDropoffSelect: popOnDropoffSelect,
                  onPickupApplied: forPickup
                      ? (p) {
                          final label =
                              '${p.main_text ?? ''}, ${p.secondary_text ?? ''}'
                                  .trim();
                          if (label.isNotEmpty) {
                            pickUpTextEditingController.text = label;
                          }
                          setState(() => pickUpPredictionsPlacesList = []);
                        }
                      : null,
                  onDropoffApplied: forPickup
                      ? null
                      : (p) {
                          final label =
                              '${p.main_text ?? ''}, ${p.secondary_text ?? ''}'
                                  .trim();
                          if (label.isNotEmpty) {
                            destinationTextEditingController.text = label;
                          }
                          setState(() => dropOffPredictionsPlacesList = []);
                        },
                ),
              );
            },
            separatorBuilder: (_, _) => const SizedBox(height: 2),
            itemCount: list.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
          ),
        ],
      ),
    );
  }
}
