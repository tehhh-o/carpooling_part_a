import 'package:carpool_training/modules/vehicle.dart';

class Driver {
  final String name;
  final String profilePicUrl;
  final Vehicle vehicle;

  Driver({
    required this.name,
    required this.profilePicUrl,
    required this.vehicle,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      name: json['name'],
      profilePicUrl: json['profilePicUrl'] ?? '',
      vehicle: Vehicle.fromJson(json['vehicle']),
    );
  }
}
