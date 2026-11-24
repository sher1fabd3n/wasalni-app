import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/global/trip_var.dart';

/// Container لعرض تفاصيل الرحلة الجارية
class TripDetailsContainer extends StatelessWidget {
  const TripDetailsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white24,
            blurRadius: 15.0,
            spreadRadius: 0.5,
            offset: Offset(0.7, 0.7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            // حالة الرحلة
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tripStatusDisplay,
                  style: const TextStyle(fontSize: 19, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 19),
            const Divider(
              height: 1,
              color: Colors.white70,
              thickness: 1,
            ),
            const SizedBox(height: 19),
            // معلومات السائق
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.network(
                    photoDriver.isEmpty
                        ? "https://firebasestorage.googleapis.com/v0/b/flutter-uber-clone-with-admin.appspot.com/o/avatarman.png?alt=media&token=7a04943c-a566-45d3-b820-d33da3b105c7"
                        : photoDriver,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 60, color: Colors.grey);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameDriver,
                      style: const TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    Text(
                      carDetailsDriver,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 19),
            const Divider(
              height: 1,
              color: Colors.white70,
              thickness: 1,
            ),
            const SizedBox(height: 19),
            // زر الاتصال
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (phoneNumberDriver.isNotEmpty) {
                      await launchUrl(Uri.parse("tel:$phoneNumberDriver"));
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(25)),
                          border: Border.all(
                            width: 1,
                            color: Colors.white,
                          ),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 11),
                      const Text("Call", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
