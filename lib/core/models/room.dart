class Room {
  final String id;
  final String buildingId;
  final String name;
  final int floor;
  final int capacity;
  final String type;

  const Room({
    required this.id,
    required this.buildingId,
    required this.name,
    required this.floor,
    required this.capacity,
    required this.type,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: json['id'] as String,
        buildingId: json['buildingId'] as String,
        name: json['name'] as String,
        floor: json['floor'] as int,
        capacity: json['capacity'] as int,
        type: json['type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'buildingId': buildingId,
        'name': name,
        'floor': floor,
        'capacity': capacity,
        'type': type,
      };

  String get typeLabel {
    switch (type) {
      case 'lecture':
        return '講義室';
      case 'large_lecture':
        return '大講義室';
      case 'seminar':
        return 'ゼミ室';
      case 'lab':
        return '実験室';
      case 'library':
        return '図書館';
      default:
        return '教室';
    }
  }
}
