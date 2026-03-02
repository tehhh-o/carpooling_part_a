import 'package:carpool_training/modules/ride.dart';
import 'package:carpool_training/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RideInfoPage extends StatefulWidget {
  final Ride ride;
  const RideInfoPage({super.key, required this.ride});

  @override
  State<RideInfoPage> createState() => _RideInfoPageState();
}

class _RideInfoPageState extends State<RideInfoPage> {
  bool isLoading = false;
  Future<void> joinRide() async {
    bool isFull = widget.ride.occupiedSeats == widget.ride.availableSeats
        ? true
        : false;
    FirebaseFirestore.instance
        .collection('rides')
        .doc(widget.ride.rideId)
        .update({
          'joinedUsers': FieldValue.arrayUnion([
            FirebaseAuth.instance.currentUser!.uid,
          ]),
          isFull ? {'status': true} : 'occupiedSeats': FieldValue.increment(1),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: uniPoolAppBar(appBarTitle: "Ride Info"),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.grey[350],
                  width: double.infinity,
                  height: 200,
                  child: Align(
                    alignment: Alignment.center,
                    child: Image.network(
                      widget.ride.driver.vehicle.carPhotoUrl,
                      height: 200,
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.ride.driver.vehicle.carModel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    Text(
                      'Car Plate : ${widget.ride.driver.vehicle.carPlate}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                Text(
                  'Date And Time to Move',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  DateFormat(
                    'EEEE, dd/MM/yyyy HH:mm',
                  ).format(widget.ride.dateTime),
                ),

                SizedBox(height: 20),

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
                            height: 120,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Origin',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.lightGreen[600],
                            ),
                          ),
                          Text(
                            widget.ride.origin['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(widget.ride.origin['address']),
                          SizedBox(height: 20),
                          Text(
                            'Destination',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.lightGreen[600],
                            ),
                          ),
                          Text(
                            widget.ride.destination['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(widget.ride.destination['address']),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    'Special Features',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.lightGreen[600],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount:
                          widget.ride.driver.vehicle.specialFeatures.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final feature =
                            widget.ride.driver.vehicle.specialFeatures[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: cardGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: BoxBorder.all(
                                color: Colors.lightGreen[200]!,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                feature,
                                style: TextStyle(color: Colors.green[900]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Spacer(flex: 2),
                Align(
                  alignment: AlignmentGeometry.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() => isLoading = true);
                      await joinRide();
                      setState(() => isLoading = false);

                      if (context.mounted) {
                        return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Ride Joined!'),
                              content: Text('You sucessfully joined the ride.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: Text('Back'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(300, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(4),
                      ),
                    ),
                    child: Text('Join the Ride'),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),

          isLoading
              ? Container(
                  color: Colors.black.withAlpha(10),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
