class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String studentId;
  final String faculty;
  final String grade;
  final Map<String, dynamic> settings;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.studentId = '',
    this.faculty = '',
    this.grade = '',
    this.settings = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'] as String,
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        studentId: json['studentId'] as String? ?? '',
        faculty: json['faculty'] as String? ?? '',
        grade: json['grade'] as String? ?? '',
        settings: (json['settings'] as Map<String, dynamic>?) ?? {},
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'studentId': studentId,
        'faculty': faculty,
        'grade': grade,
        'settings': settings,
      };

  UserProfile copyWith({
    String? displayName,
    String? studentId,
    String? faculty,
    String? grade,
    Map<String, dynamic>? settings,
  }) =>
      UserProfile(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        studentId: studentId ?? this.studentId,
        faculty: faculty ?? this.faculty,
        grade: grade ?? this.grade,
        settings: settings ?? this.settings,
      );
}
