import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/config/app_config.dart';
import 'package:users_app/global/global_var.dart';

/// خريطة OpenStreetMap (مجانية) — بديل عن Google Maps
class MapWidget extends StatelessWidget {
  final MapController mapController;
  final List<Polyline> polylines;
  final List<Marker> markers;
  final List<CircleMarker> circles;
  final double bottomPadding;
  final void Function(TapPosition tapPosition, LatLng point)? onTap;
  final VoidCallback? onMapReady;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.polylines,
    required this.markers,
    required this.circles,
    this.bottomPadding = 0,
    this.onTap,
    this.onMapReady,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 26, bottom: bottomPadding),
      child: FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: defaultMapCenter,
        initialZoom: AppConfig.defaultZoom,
        minZoom: 3,
        maxZoom: 19,
        onTap: onTap,
        onMapReady: onMapReady != null ? () => onMapReady!() : null,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: AppConfig.osmTileUserAgentPackage,
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        if (circles.isNotEmpty) CircleLayer(circles: circles),
        if (markers.isNotEmpty) MarkerLayer(markers: markers),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap',
              onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    ),
    );
  }
}
