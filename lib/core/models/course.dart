import 'package:uuid/uuid.dart';

class Course {
  final String id;
  final String name;
  final String instructor;
  final int dayOfWeek; // 1=Mon, 2=Tue, ..., 6=Sat (Sunday not scheduled)
  final int period;
  final String roomId;
  final String buildingId;
  final String color;
  final String semester; // "前期" or "後期"
  final String credits;
  final String notes;

  Course({
    String? id,
    required this.name,
    required this.instructor,
    required this.dayOfWeek,
    required this.period,
    required this.roomId,
    required this.buildingId,
    this.color = '#1976D2',
    this.semester = '前期',
    this.credits = '2',
    this.notes = '',
  }) : id = id ?? const Uuid().v4();

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        name: json['name'] as String,
        instructor: json['instructor'] as String? ?? '',
        dayOfWeek: json['dayOfWeek'] as int,
        period: json['period'] as int,
        roomId: json['roomId'] as String,
        buildingId: json['buildingId'] as String,
        color: json['color'] as String? ?? '#1976D2',
        semester: json['semester'] as String? ?? '前期',
        credits: json['credits'] as String? ?? '2',
        notes: json['notes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'instructor': instructor,
        'dayOfWeek': dayOfWeek,
        'period': period,
        'roomId': roomId,
        'buildingId': buildingId,
        'color': color,
        'semester': semester,
        'credits': credits,
        'notes': notes,
      };

  Course copyWith({
    String? name,
    String? instructor,
    int? dayOfWeek,
    int? period,
    String? roomId,
    String? buildingId,
    String? color,
    String? semester,
    String? credits,
    String? notes,
  }) =>
      Course(
        id: id,
        name: name ?? this.name,
        instructor: instructor ?? this.instructor,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        period: period ?? this.period,
        roomId: roomId ?? this.roomId,
        buildingId: buildingId ?? this.buildingId,
        color: color ?? this.color,
        semester: semester ?? this.semester,
        credits: credits ?? this.credits,
        notes: notes ?? this.notes,
      );

  static String dayName(int day) {
    const names = ['', '月', '火', '水', '木', '金', '土'];
    return day >= 1 && day <= 6 ? names[day] : '';
  }
}
