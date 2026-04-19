import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_profile.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestore;

  AuthService(this._firestore);

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserProfile?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) return null;
    return _firestore.getUserProfile(cred.user!.uid);
  }

  Future<UserProfile> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(displayName);
    final profile = UserProfile(
      uid: cred.user!.uid,
      email: email,
      displayName: displayName,
    );
    await _firestore.saveUserProfile(profile);
    return profile;
  }

  Future<UserProfile?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    if (cred.user == null) return null;

    UserProfile? profile = await _firestore.getUserProfile(cred.user!.uid);
    if (profile == null) {
      profile = UserProfile(
        uid: cred.user!.uid,
        email: cred.user!.email ?? '',
        displayName: cred.user!.displayName ?? '',
      );
      await _firestore.saveUserProfile(profile);
    }
    return profile;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
