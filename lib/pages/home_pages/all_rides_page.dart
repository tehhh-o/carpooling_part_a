import 'package:carpool_training/modules/ride.dart';
import 'package:carpool_training/pages/home_pages/ride_info_page.dart';
import 'package:carpool_training/style.dart';
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
  Future<List<Ride>>? futureRides;
  String selectedFilter = 'All Rides';

  Future<String> getProfilePicUrl(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('driver')
        .doc(userId)
        .get();

    final profilePicUrl = userDoc.data()!['profilePicUrl'];
    return profilePicUrl;
  }

  Future<List<Ride>> getRides() async {
    final rideData = await FirebaseFirestore.instance.collection('rides').get();

    final rides = await Future.wait(
      rideData.docs.map((rideDoc) async {
        final driverDoc = await FirebaseFirestore.instance
            .collection('driver')
            .doc(rideDoc.data()['driverUid'])
            .get();

        return Ride.fromJson(rideDoc.data(), driverDoc.data()!, rideDoc.id);
      }).toList(),
    );
    return rides;
  }

  @override
  void initState() {
    futureRides = getRides();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: selectedFilter,
                items: ['All Rides', 'Your Rides']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                  });
                },
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    futureRides = getRides();
                  });
                },
                icon: Icon(Icons.refresh, color: Colors.green[600], size: 20),
              ),
            ],
          ),

          FutureBuilder(
            future: futureRides,
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

              return Expanded(
                child: ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: cardGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        ride.driver.profilePicUrl,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      ride.driver.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'RM ${ride.fare.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            ride.origin['address'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 30),
                                          Text(
                                            ride.destination['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            ride.destination['address'],
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
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    DateFormat(
                                      'EEEE, dd/MM/yyyy HH:mm',
                                    ).format(ride.dateTime),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Row(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < ride.availableSeats;
                                      i++
                                    )
                                      i < ride.occupiedSeats
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                right: 5.0,
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
                                                right: 5.0,
                                              ),
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                child: Icon(
                                                  Icons.person_2_outlined,
                                                ),
                                              ),
                                            ),

                                    Spacer(),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                RideInfoPage(ride: ride),
                                          ),
                                        );
                                      },
                                      child: Text('More Info'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
