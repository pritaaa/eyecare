class ClinicModel {
  final String name;
  final double lat;
  final double lng;
  double? distance;
  String? address;

  ClinicModel({
    required this.name,
    required this.lat,
    required this.lng,
    this.distance,
    this.address,
  });

  String get gmapsGeo => "geo:$lat,$lng?q=$lat,$lng";

  String get gmapsWeb =>
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
}
