import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> singIn({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
}) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    if (currentUser != null) {
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.delete();
      await _firebaseAuth.signOut();
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(displayName);
      await currentUser!.reload();
    }
  }
}
