import 'package:carpool_training/app_theme.dart';
import 'package:carpool_training/modules/ride.dart';
import 'package:carpool_training/pages/home_pages/ride_info_page.dart';
import 'package:carpool_training/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllRidesPage extends StatefulWidget {
  const AllRidesPage({super.key});

  @override
  State<AllRidesPage> createState() => _AllRidesPageState();
}

class _AllRidesPageState extends State<AllRidesPage> {
  Stream<List<Ride>>? streamRides;
  String selectedFilter = 'All Rides';

  Future<String> getProfilePicUrl(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('driver')
        .doc(userId)
        .get();

    final profilePicUrl = userDoc.data()!['profilePicUrl'];
    return profilePicUrl;
  }

  // Future<List<Ride>> getRides() async {
  //   final rideData = await FirebaseFirestore.instance.collection('rides').get();

  //   final rides = await Future.wait(
  //     rideData.docs.map((rideDoc) async {
  //       final driverDoc = await FirebaseFirestore.instance
  //           .collection('driver')
  //           .doc(rideDoc.data()['driverUid'])
  //           .get();

  //       return Ride.fromJson(rideDoc.data(), driverDoc.data()!, rideDoc.id);
  //     }).toList(),
  //   );
  //   return rides;
  // }

  Stream<List<Ride>> getStreamRides() {
    return FirebaseFirestore.instance.collection('rides').snapshots().asyncMap((
      rideSnapshot,
    ) async {
      final rides = await Future.wait(
        rideSnapshot.docs.map((rideDoc) async {
          final driverDoc = await FirebaseFirestore.instance
              .collection('driver')
              .doc(rideDoc.data()['driverUid'])
              .get();
          return Ride.fromJson(rideDoc.data(), driverDoc.data()!, rideDoc.id);
        }).toList(),
      );
      return rides;
    });
  }

  @override
  void initState() {
    streamRides = getStreamRides();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tStyle = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: selectedFilter,
                items: ['All Rides', 'Your Rides']
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: tStyle.titleLarge),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
              ),
            ],
          ),

          StreamBuilder(
            stream: streamRides,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No data found');
              }

              final rides = snapshot.data!.where((r) {
                if (selectedFilter == 'Your Rides') {
                  return r.driverUid == FirebaseAuth.instance.currentUser!.uid;
                }
                return r.status == false;
              }).toList();

              if (rides.isEmpty) {
                return Padding(
                  padding: EdgeInsetsGeometry.all(AppTheme.s8),
                  child: Text(
                    'You haven\'t created any rides yet.\nCreate one to see your rides. ',
                    style: tStyle.titleMedium,
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.s8,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.s8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      ride.driver.profilePicUrl,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.s12),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ride.driver.name,
                                        style: tStyle.titleLarge,
                                      ),
                                      Text(
                                        ride.driver.vehicle.carModel,
                                        style: tStyle.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Text(
                                    'RM ${ride.fare.toStringAsFixed(2)}',
                                    style: tStyle.titleMedium,
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(AppTheme.s8),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.circle_outlined,
                                          color: Colors.lightGreen[400],
                                        ),
                                        Container(
                                          height: 50,
                                          width: 4,
                                          color: Colors.lightGreen[400],
                                        ),
                                        Icon(
                                          Icons.radio_button_checked,
                                          color: Colors.lightGreen[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ride.origin['name'],
                                          style: tStyle.labelLarge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          ride.origin['address'],
                                          style: tStyle.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: AppTheme.s32),
                                        Text(
                                          ride.destination['name'],
                                          style: tStyle.labelLarge,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          ride.destination['address'],
                                          style: tStyle.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.s4,
                                ),
                                child: Text(
                                  DateFormat(
                                    'EEEE, dd/MM/yyyy HH:mm',
                                  ).format(ride.dateTime),
                                  style: tStyle.bodyMedium,
                                ),
                              ),

                              Divider(),

                              Row(
                                children: [
                                  for (int i = 0; i < ride.availableSeats; i++)
                                    i < ride.occupiedSeats
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              right: AppTheme.s4,
                                            ),
                                            child: FutureBuilder<String>(
                                              future: getProfilePicUrl(
                                                ride.joinedUser[i],
                                              ),
                                              builder: (context, snapshot) {
                                                return CircleAvatar(
                                                  backgroundImage:
                                                      snapshot.hasData &&
                                                          snapshot
                                                              .data!
                                                              .isNotEmpty
                                                      ? NetworkImage(
                                                          snapshot.data!,
                                                        )
                                                      : null,
                                                  child: !snapshot.hasData
                                                      ? Icon(Icons.person)
                                                      : null,
                                                );
                                              },
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                              right: AppTheme.s4,
                                            ),
                                            child: CircleAvatar(
                                              child: Icon(
                                                Icons.person_2_outlined,
                                              ),
                                            ),
                                          ),

                                  Spacer(),
                                  SizedBox(
                                    width: 110,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          SlideFadeRoute(
                                            page: RideInfoPage(ride: ride),
                                          ),
                                        );
                                      },
                                      child: Text('More Info'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
