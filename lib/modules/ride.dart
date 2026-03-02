import 'package:carpool_training/modules/driver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String rideId;
  final DateTime dateTime;
  final Map<String, dynamic> origin;
  final Map<String, dynamic> destination;
  final int availableSeats;
  final int occupiedSeats;
  final String driverUid;
  final Driver driver;
  final bool status;
  final double farePerKm;
  final double fare;
  List<String> joinedUser = [''];

  Ride({
    required this.rideId,
    required this.dateTime,
    required this.origin,
    required this.destination,
    required this.availableSeats,
    required this.occupiedSeats,
    required this.driverUid,
    required this.driver,
    required this.status,
    required this.farePerKm,
    required this.fare,
    required this.joinedUser,
  });

  factory Ride.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> driverJson,
    String rideId,
  ) {
    return Ride(
      rideId: rideId,
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      origin: json['origin'],
      destination: json['destination'],
      availableSeats: json['availableSeats'],
      occupiedSeats: json['occupiedSeats'],
      driverUid: json['driverUid'],
      driver: Driver.fromJson(driverJson),
      status: json['status'],
      farePerKm: json['farePerKM'],
      fare: json['fare'],
      joinedUser: List<String>.from(json['joinedUsers'] ?? ['']),
    );
  }
}
