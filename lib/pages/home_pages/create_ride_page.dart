import 'package:carpool_training/app_theme.dart';
import 'package:carpool_training/modules/place.dart';
import 'package:carpool_training/pages/widgets/pick_location_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haversine_distance/haversine_distance.dart';
import 'package:intl/intl.dart';

class CreateRidePage extends StatefulWidget {
  const CreateRidePage({super.key});

  @override
  State<CreateRidePage> createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<CreateRidePage> {
  bool isLoading = false;
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  final fareKmController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  late Place selectedOrigin;
  late Place selectedDestination;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  Future<void> createNewRide() async {
    final currentDriver = await FirebaseFirestore.instance
        .collection('driver')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final startCoordinate = Location(
      selectedOrigin.latitude,
      selectedOrigin.longitude,
    );
    final endCoordinate = Location(
      selectedDestination.latitude,
      selectedDestination.longitude,
    );
    final haversineDistance = HaversineDistance();
    final totalFare =
        haversineDistance.haversine(startCoordinate, endCoordinate, Unit.KM) *
        double.parse(fareKmController.text.trim());

    await FirebaseFirestore.instance.collection('rides').add({
      'availableSeats': currentDriver['vehicle']['sittingCapacity'],
      'dateTime': Timestamp.fromDate(
        DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        ),
      ),
      'origin': {
        'latitude': selectedOrigin.latitude,
        'longitude': selectedOrigin.longitude,
        'name': selectedOrigin.displayName,
        'address': selectedOrigin.formattedAddress,
      },
      'destination': {
        'latitude': selectedDestination.latitude,
        'longitude': selectedDestination.longitude,
        'name': selectedDestination.displayName,
        'address': selectedDestination.formattedAddress,
      },
      'occupiedSeats': 0,
      'driverUid': FirebaseAuth.instance.currentUser!.uid,
      'status': false,
      'farePerKM': double.parse(fareKmController.text.trim()),
      'fare': totalFare,
    });
  }

  @override
  Widget build(BuildContext context) {
    final tStyle = Theme.of(context).textTheme;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.s24),
            child: Column(
              children: [
                Form(
                  key: formKey,
                  child: Container(
                    padding: EdgeInsets.all(AppTheme.s12),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(AppTheme.r8),
                      gradient: LinearGradient(
                        colors: AppTheme.gradient(context),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Create A Ride',
                            style: tStyle.headlineSmall,
                          ),
                        ),
                        SizedBox(height: AppTheme.s20),
                        Text('Origin Location', style: tStyle.titleMedium),
                        TextFormField(
                          controller: originController,
                          readOnly: true,
                          canRequestFocus: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on),
                            hintText: 'eg: KLIA',
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => PickLocationDialog(
                                onSelectLocation: (place) {
                                  setState(() {
                                    selectedOrigin = place;
                                    originController.text = place.displayName;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        Text('Destination Location', style: tStyle.titleMedium),
                        TextFormField(
                          controller: destinationController,
                          readOnly: true,
                          canRequestFocus: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on),
                            hintText: 'eg: KLCC',
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => PickLocationDialog(
                                onSelectLocation: (place) {
                                  setState(() {
                                    selectedDestination = place;
                                    destinationController.text =
                                        place.displayName;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        Text('Fare Per KM', style: tStyle.titleMedium),
                        TextFormField(
                          controller: fareKmController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.monetization_on),
                            hintText: 'RM',
                          ),
                        ),
                        Text('Date to Move', style: tStyle.titleMedium),
                        TextFormField(
                          controller: dateController,
                          canRequestFocus: false,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.calendar_month),
                            hintText: 'e.g. Monday, March 12 2026',
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                                dateController.text = DateFormat.yMMMMEEEEd()
                                    .format(date);
                              });
                            }
                          },
                        ),
                        Text('Time to Move', style: tStyle.titleMedium),
                        TextFormField(
                          controller: timeController,
                          canRequestFocus: false,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.timer),
                            hintText: '--:--',
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                                timeController.text = time.format(context);
                              });
                            }
                          },
                        ),
                        SizedBox(height: 100),

                        ElevatedButton(
                          onPressed: () async {
                            setState(() => isLoading = true);
                            await createNewRide();
                            setState(() => isLoading = false);
                            if (context.mounted) {
                              return showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('All Information Submitted'),
                                    content: Text('Ride Created successfully.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Text('Create'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                color: Colors.black.withAlpha(10),
                child: Center(child: CircularProgressIndicator()),
              )
            : SizedBox(),
      ],
    );
  }
}
