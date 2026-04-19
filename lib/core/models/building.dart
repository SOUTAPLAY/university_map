class Building {
  final String id;
  final String name;
  final String nameEn;
  final double lat;
  final double lng;
  final String plateauBuildingId;
  final String description;

  const Building({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.lat,
    required this.lng,
    required this.plateauBuildingId,
    required this.description,
  });

  factory Building.fromJson(Map<String, dynamic> json) => Building(
        id: json['id'] as String,
        name: json['name'] as String,
        nameEn: json['nameEn'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        plateauBuildingId: json['plateauBuildingId'] as String,
        description: json['description'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameEn': nameEn,
        'lat': lat,
        'lng': lng,
        'plateauBuildingId': plateauBuildingId,
        'description': description,
      };
}
