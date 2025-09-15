import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realestate/models/admin.dart';

class FirebaseAdmin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _adminCollection =
      FirebaseFirestore.instance.collection('admin');

  /// Sign in admin and fetch their Firestore data
  Future<AdminModel?> signInAdmin(String email, String password) async {
    try {
      // Firebase Authentication sign-in
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        print("No user found after sign-in.");
        return null;
      }

      print("Signed in as: ${user.email}, UID: ${user.uid}");

      // Fetch admin details from Firestore
      final docRef = _adminCollection.doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      print("Admin document fetched: $data");

      return AdminModel.fromMap(data);

    } on FirebaseAuthException catch (e) {
      print("Auth error: ${e.code}");
      return null;
    } catch (e) {
      print("Unknown error: $e");
      return null;
    }
  }

  /// Sign out admin
  Future<void> signOutAdmin() async {
    await _auth.signOut();
  }
}
