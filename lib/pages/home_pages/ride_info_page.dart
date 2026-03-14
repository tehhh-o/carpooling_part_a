import 'package:carpool_training/app_theme.dart';
import 'package:carpool_training/modules/ride.dart';
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
    final tStyle = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Ride Info')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
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

                SizedBox(height: AppTheme.s12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.ride.driver.vehicle.carModel,
                      style: tStyle.headlineSmall,
                    ),
                    Text(
                      'Car Plate : ${widget.ride.driver.vehicle.carPlate}',
                      style: tStyle.titleMedium,
                    ),
                  ],
                ),

                Text('Date And Time to Move', style: tStyle.titleMedium),
                Text(
                  DateFormat(
                    'EEEE, dd/MM/yyyy HH:mm',
                  ).format(widget.ride.dateTime),
                  style: tStyle.bodyMedium,
                ),

                SizedBox(height: AppTheme.s24),

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
                          Text('Origin', style: tStyle.titleLarge),
                          Text(
                            widget.ride.origin['name'],
                            style: tStyle.labelLarge,
                          ),
                          Text(
                            widget.ride.origin['address'],
                            style: tStyle.bodySmall,
                          ),
                          SizedBox(height: AppTheme.s24),
                          Text('Destination', style: tStyle.titleLarge),
                          Text(
                            widget.ride.destination['name'],
                            style: tStyle.labelLarge,
                          ),
                          Text(
                            widget.ride.destination['address'],
                            style: tStyle.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: AppTheme.s16),
                  child: Text('Special Features', style: tStyle.titleLarge),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.s12),
                  child: SizedBox(
                    height: AppTheme.s40,
                    width: double.infinity,
                    child: ListView.builder(
                      itemCount:
                          widget.ride.driver.vehicle.specialFeatures.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final feature =
                            widget.ride.driver.vehicle.specialFeatures[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.s8,
                          ),
                          child: Chip(
                            label: Text(feature, style: tStyle.bodyMedium),
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
