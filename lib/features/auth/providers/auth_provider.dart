import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>(
  (_) => FirestoreService(),
);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(firestoreServiceProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.read(firestoreServiceProvider).getUserProfile(user.uid);
});
