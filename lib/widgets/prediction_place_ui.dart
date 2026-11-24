import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/models/address_model.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/models/prediction_model.dart';

class PredictionPlaceUI extends StatefulWidget {
  final PredictionModel? predictedPlaceData;

  /// true = تحديث نقطة الانطلاق فقط، false = تحديد الوجهة وإغلاق الشاشة
  final bool forPickup;

  /// يُستدعى بعد حفظ الانطلاق (لتحديث الحقل وتفريغ القائمة)
  final void Function(PredictionModel p)? onPickupApplied;

  /// يُستدعى بعد حفظ الوجهة دون إغلاق الشاشة (رحلة داخلية)
  final void Function(PredictionModel p)? onDropoffApplied;

  /// false = الوجهة تُحفظ وتبقى على شاشة البحث (تبويب داخلي)
  final bool popOnDropoffSelect;

  const PredictionPlaceUI({
    super.key,
    this.predictedPlaceData,
    this.forPickup = false,
    this.onPickupApplied,
    this.onDropoffApplied,
    this.popOnDropoffSelect = true,
  });

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  void applySelectedPlace() {
    final p = widget.predictedPlaceData;
    if (p == null) return;
    if (p.latitude == null || p.longitude == null) return;

    final dropOffLocation = AddressModel();
    dropOffLocation.placeName = p.main_text ?? p.secondary_text;
    dropOffLocation.humanReadableAddress =
        '${p.main_text ?? ''}, ${p.secondary_text ?? ''}'.trim();
    if (dropOffLocation.humanReadableAddress == ',') {
      dropOffLocation.humanReadableAddress = p.main_text;
    }
    dropOffLocation.latitudePosition = p.latitude;
    dropOffLocation.longitudePosition = p.longitude;
    dropOffLocation.placeID = p.place_id;

    final app = Provider.of<AppInfo>(context, listen: false);
    if (widget.forPickup) {
      app.updatePickUpLocation(dropOffLocation);
      widget.onPickupApplied?.call(p);
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.pickupSetSnackbar),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    app.updateDropOffLocation(dropOffLocation);
    if (!widget.popOnDropoffSelect) {
      widget.onDropoffApplied?.call(p);
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.dropoffSetSnackbar),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    Navigator.pop(context, "placeSelected");
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: applySelectedPlace,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
      ),
      child: SizedBox(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.share_location,
                  color: Colors.grey,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.predictedPlaceData!.main_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.predictedPlaceData!.secondary_text.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
