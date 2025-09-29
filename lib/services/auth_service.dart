import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void initialize() {
    // Écouter les changements d'état d'authentification
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web - Utiliser directement Firebase Auth
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential result =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
        return result.user;
      } else {
        // Android / iOS - Version 6.x compatible
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // utilisateur annulé

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential result =
            await FirebaseAuth.instance.signInWithCredential(credential);
        return result.user;
      }
    } catch (e) {
      debugPrint("Erreur Google Sign-In: $e");
      return null;
    }
  }

  String? get userEmail => _currentUser?.email;
  String? get userId => _currentUser?.uid;
}
