import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

import '../../shared/utils/util.dart';
import '../../shared/constants/value.dart';
import '../models/auth_model.dart';
import 'settings_svc.dart';

class AuthService {
  AuthService._() {}
  static AuthService instance = AuthService._();

  final GoogleSignIn _googleAuth = GoogleSignIn(
    clientId: clientId,
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> _getAuthDoc(String uid) =>
      _firestore.collection('auths').doc(uid);

  Stream<AuthModel?>? streamUser(String uid) {
    if (uid.isEmpty) return null;
    return _firestore.collection('auths').doc(uid).snapshots().map((authDoc) {
      if (authDoc.exists) {
        try {
          var auth = AuthModel.fromDoc(authDoc);
          return auth;
        } catch (e) {
          print("error occur auth svc:33 ::: ${e.toString()}");
        }
      }
      return null;
    });
  }

  Future<AuthModel?> getUser(String uid) async {
    if (uid.isEmpty) return null;
    var authDoc = await _getAuthDoc(uid).get();
    if (authDoc.exists) {
      try {
        var auth = AuthModel.fromDoc(authDoc);
        return auth;
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  Future<void> updateAuthLastSignIn({
    required String uid,
    String? provider,
    String? photoUrl,
    String? email,
    String? displayName,
  }) async {
    if (uid.isEmpty) return;
    var authDoc = await _getAuthDoc(uid);
    var authSnapshot = await authDoc.get();
    if (!authSnapshot.exists) {
      var auth = AuthModel(
        uid: uid,
        provider: provider,
        imageUrl: "",
        notesId: [],
        sharedNotesId: [],
        createAt: DateTime.now(),
        lastSignInTime: DateTime.now(),
        email: email ?? "",
        displayName: email ?? "Guest",
        settings: defaultSettings,
      );
      _firestore.collection('auths').doc(uid).set(auth.toMap());
      await authDoc.collection('notes');
      await authDoc.collection('sharedNotes');
      await authDoc.collection('labels');
    } else {
      await authDoc.update({'lastSignInTime': DateTime.now()});
    }
  }

  Future<void> saveAuthToHive(String uid) async {
    if (uid.isEmpty) return;
    final authDoc = await _getAuthDoc(uid).get();
    if (authDoc.exists) {
      try {
        var auth = AuthModel.fromDoc(authDoc);
        var box = await Hive.openBox<AuthModel>('authBox');
        await box.put('auth${auth.uid}', auth);
        setCurrentAuthUid(auth.uid!);
        print("saved");
        return;
      } catch (e) {
        print(e);
      }
    }
  }

  Future<AuthModel?> loadAuthFromHive() async {
    final String? uid = await getCurrentAuthUid();
    if (uid != null) {
      var box = await Hive.openBox<AuthModel>('authBox');
      AuthModel? auth = box.get('auth$uid');
      return auth;
    }
    return null;
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential authCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = authCredential.user;
      if (user != null) {
        return user;
      }
      throw Exception("User not exist");
    } catch (error) {
      throw error;
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (error) {
      throw error;
    }
  }

  Future<User?> signInAnonymously() async {
    try {
      final UserCredential authCredential = await _auth.signInAnonymously();
      final User? user = authCredential.user;
      if (user != null) {
        return user;
      }
      throw Exception("Auth not exist");
    } catch (error) {
      throw error;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleAccount = await GoogleSignIn().signIn();
      final googleAuth = await googleAccount?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (error) {
      throw error;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleAuth.signOut();
  }

  Future<void> resetPass(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
