import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/l10n/app_localizations.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final completedTripRequestsOfCurrentUser =
      FirebaseDatabase.instance.ref().child("tripRequests");

  List<Map<String, dynamic>> _endedTripsForUser(Map dataTrips, String uid) {
    final tripsList = <Map<String, dynamic>>[];
    dataTrips.forEach((key, value) {
      if (value is! Map) return;
      final trip = Map<String, dynamic>.from(value);
      if (trip['status'] == 'ended' && trip['userID'] == uid) {
        tripsList.add({'key': key, ...trip});
      }
    });
    tripsList.sort((a, b) {
      final aTime = a['publishDateTime']?.toString() ?? '';
      final bTime = b['publishDateTime']?.toString() ?? '';
      return bTime.compareTo(aTime);
    });
    return tripsList;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(loc.tripsHistoryTitle),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: uid == null
          ? Center(
              child: Text(
                loc.errorOccurred,
                style: const TextStyle(color: Colors.black54),
              ),
            )
          : StreamBuilder<DatabaseEvent>(
              stream: completedTripRequestsOfCurrentUser.onValue,
              builder: (BuildContext context, snapshotData) {
                if (snapshotData.hasError) {
                  return Center(
                    child: Text(
                      loc.errorOccurred,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  );
                }

                if (!snapshotData.hasData ||
                    snapshotData.data?.snapshot.value == null) {
                  return Center(
                    child: Text(
                      loc.noTripsYet,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                final raw = snapshotData.data!.snapshot.value;
                if (raw is! Map) {
                  return Center(
                    child: Text(
                      loc.noTripsYet,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  );
                }

                final tripsList = _endedTripsForUser(
                  Map<dynamic, dynamic>.from(raw),
                  uid,
                );

                if (tripsList.isEmpty) {
                  return Center(
                    child: Text(
                      loc.noTripsYet,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  itemCount: tripsList.length,
                  itemBuilder: (context, index) {
                    final trip = tripsList[index];
                    return Card(
                      color: const Color(0xFFF5F5F5),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/initial.png',
                                  height: 16,
                                  width: 16,
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Text(
                                    trip['pickUpAddress']?.toString() ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${trip['fareAmount']} ${loc.currencyEgp}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFD32F2F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/final.png',
                                  height: 16,
                                  width: 16,
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Text(
                                    trip['dropOffAddress']?.toString() ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
