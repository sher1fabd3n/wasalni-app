import 'package:flutter/material.dart';
import 'package:users_app/l10n/app_localizations.dart';

/// حوار عرض المبلغ المستحق للسائق
class PaymentDialog extends StatelessWidget {
  final String fareAmount;

  const PaymentDialog({super.key, required this.fareAmount});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black54,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 21),
            Text(
              loc.payCash,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 21),
            const Divider(
              height: 1.5,
              color: Colors.white70,
              thickness: 1.0,
            ),
            const SizedBox(height: 16),
            Text(
              '$fareAmount ${loc.currencyEgp}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                loc.amountDueDriver(fareAmount),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 31),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, "paid"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(loc.payCash),
            ),
            const SizedBox(height: 41),
          ],
        ),
      ),
    );
  }
}
