class Place {
  final String placeId;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String displayName;

  Place({
    required this.placeId,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['id'],
      formattedAddress: json['formattedAddress'],
      latitude: json['location']['latitude'],
      longitude: json['location']['longitude'],
      displayName: json['displayName']['text'],
    );
  }
}
