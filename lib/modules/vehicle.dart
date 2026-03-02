class Vehicle {
  final String carModel;
  final String carPhotoUrl;
  final String carPlate;
  final int sittingCapacity;
  final List<String> specialFeatures;

  Vehicle({
    required this.carModel,
    required this.carPhotoUrl,
    required this.carPlate,
    required this.sittingCapacity,
    required this.specialFeatures,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      carModel: json['carModel'],
      carPhotoUrl: json['carPhotoUrl'],
      carPlate: json['carPlate'] ?? 'na',
      sittingCapacity: json['sittingCapacity'],
      specialFeatures: List<String>.from(json['specialFeatures']),
    );
  }
}
