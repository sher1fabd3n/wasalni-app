import 'package:flutter/material.dart';
import 'package:users_app/l10n/app_localizations.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/models/direction_details.dart';
import 'package:users_app/models/trip_booking_kind.dart';
import 'package:users_app/services/remote_pricing.dart';

/// Container لعرض تفاصيل الرحلة والسعر قبل تأكيد الطلب.
class RideDetailsContainer extends StatelessWidget {
  final DirectionDetails? tripDirectionDetailsInfo;
  final TripBookingKind tripBookingKind;
  final Future<void> Function() onRequestRide;

  const RideDetailsContainer({
    super.key,
    required this.tripDirectionDetailsInfo,
    required this.tripBookingKind,
    required this.onRequestRide,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: RemotePricing.instance,
      builder: (context, _) {
        return _RideDetailsBody(
          loc: loc,
          tripDirectionDetailsInfo: tripDirectionDetailsInfo,
          tripBookingKind: tripBookingKind,
          onRequestRide: onRequestRide,
        );
      },
    );
  }
}

class _RideDetailsBody extends StatelessWidget {
  final AppLocalizations loc;
  final DirectionDetails? tripDirectionDetailsInfo;
  final TripBookingKind tripBookingKind;
  final Future<void> Function() onRequestRide;

  const _RideDetailsBody({
    required this.loc,
    required this.tripDirectionDetailsInfo,
    required this.tripBookingKind,
    required this.onRequestRide,
  });

  @override
  Widget build(BuildContext context) {
    final details = tripDirectionDetailsInfo;
    final fareText = details != null
        ? CommonMethods.calculateFareAmount(
            details,
            tripBookingKind: tripBookingKind,
          )
        : null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15.0,
            spreadRadius: 0.5,
            offset: Offset(.7, .7),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          14,
          16,
          12 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              if (details != null)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        details.distanceTextString ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        details.durationTextString ?? '',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      loc.estimatedFareLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fareText != null ? '$fareText ${loc.currencyEgp}' : '—',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: fareText != null ? () => onRequestRide() : null,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: Text(loc.confirmRequestRide),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
