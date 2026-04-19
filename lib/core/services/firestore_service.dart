import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/course.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User profile
  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromJson({'uid': uid, ...doc.data()!});
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final data = profile.toJson()..remove('uid');
    await _db
        .collection('users')
        .doc(profile.uid)
        .set(data, SetOptions(merge: true));
  }

  // Timetable
  Stream<List<Course>> watchCourses(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('courses')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Course.fromJson({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<List<Course>> getCourses(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('courses')
        .get();
    return snap.docs
        .map((d) => Course.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> saveCourse(String uid, Course course) async {
    final data = course.toJson()..remove('id');
    await _db
        .collection('users')
        .doc(uid)
        .collection('courses')
        .doc(course.id)
        .set(data);
  }

  Future<void> deleteCourse(String uid, String courseId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('courses')
        .doc(courseId)
        .delete();
  }

  Future<void> updateUserSettings(
      String uid, Map<String, dynamic> settings) async {
    await _db.collection('users').doc(uid).update({'settings': settings});
  }
}
