import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realestate/models/user.dart';
import 'package:realestate/services/firebase_cloudinary.dart';

class FirebaseUser {
  // auth collections firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // get collection of notes from the firestore
  final CollectionReference _userCollection = FirebaseFirestore.instance
      .collection('users');

  // CRUD
  //Create - Sign Up
  Future<String?> signUp(UserModel user) async {
    try {
      // create a auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      final uid = credential.user!.uid;

      // create model with uid
      UserModel newUser = UserModel(
        uid: uid,
        email: user.email,
        name: user.name,
        password: user.password,
        address: user.address,
        phoneNumber: user.phoneNumber,
        isPremium: user.isPremium,
        isDeleted: user.isDeleted,
        savedProperties: user.savedProperties,
        myProperties: user.myProperties,
        transactions: user.transactions,
        bankingInfo: user.bankingInfo,
        profilePicture: user.profilePicture,
      );

      await _userCollection.doc(uid).set(newUser.toMap());
      print("User stored in firestore! ");
      return uid;
    } on FirebaseAuthException catch (e) {
      print("SignUp Error: ${e.message}");
      return null;
    }
  }

  //Get User - SignIn
  // Future<String?> signIn(String email, String password) async {
  //   try {
  //     final credential = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     final user = credential.user!;

  //     // firestore data
  //     final document = await _userCollection.doc(user.uid).get();
      
  //     if(document.exists){
  //       final data = document.data() as Map<String, dynamic>;
  //       final isDeleted = data['isDeleted'] as bool? ?? false;

  //       if(isDeleted == true){
  //         // user marks its account delete
  //         return "-1";
  //       }
  //       return user.uid;
  //     }else{
  //       return null;
  //     }

  //   } on FirebaseAuthException catch (e) {
  //     print(e.toString());
  //     return e.toString();
  //   }
  // }

  Future<String?> signIn(String email, String password) async {
  try {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;

    // Firestore data
    final document = await _userCollection.doc(user.uid).get();

    if (document.exists) {
      final data = document.data() as Map<String, dynamic>;
      final isDeleted = data['isDeleted'] as bool? ?? false;

      if (isDeleted == true) {
        return "-1"; // account deleted
      }
      return user.uid; //  success
    } else {
      return null; // user not in firestore
    }

  } on FirebaseAuthException catch (e) {
    print("FirebaseAuthException: ${e.code}"); // e.g. wrong-password, user-not-found
    return e.code; // return the error code only
  }
}

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _userCollection.doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<String?> updateUserProfile({
    String? name,
    String? password,
    String? address,
    String? phoneNumber,
    bool? isPremium,
    bool? isDeleted, // actice or not active
    List<String>? savedProperties, // property id
    List<String>? myProperties, // property id
    List<String>? transactions, // payment id
    // structure banking information list
    List<Map<String, String>>? bankingInfo,
    // image url
    String? profilePicture,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return "User Not Log In";

      final updateUser = <String, dynamic>{};
      
      // fire base authetication
      // if(email != null) {
      //   FirebaseUser user = await _auth.currentUser!();
      //   if( user != null){
      //     awai
      //   }
      // }
      if (password != null) {
        await _auth.currentUser?.updatePassword(password);
      }

      // Firestore data-updation
      if (name != null) updateUser['name'] = name;
      if (address != null) updateUser['address'] = address;
      if (phoneNumber != null) updateUser['phoneNumber'] = phoneNumber;
      if (isPremium != null) updateUser['isPremium'] = isPremium;
      if (isDeleted != null) updateUser['isDeleted'] = isDeleted;
      if (savedProperties != null) updateUser['savedProperties'] = savedProperties;
      if (myProperties != null) updateUser['myProperties'] = myProperties;
      if (transactions != null) updateUser['transactions'] = transactions;
      if (bankingInfo != null) updateUser['bankingInfo'] = bankingInfo;
      if (profilePicture != null) updateUser['profilePicture'] = profilePicture;

      if (updateUser.isNotEmpty) {
        await _userCollection.doc(uid).update(updateUser);
      }
      return "Profile Updated Succesfully";
    } catch (e) {
      return "error: $e";
    }
  }

  Future<String?> deleteUser() async {
    try {
      final uid = _auth.currentUser?.uid;
      final updateUser = <String, dynamic>{};

      if (uid != null) {
        updateUser['isDeleted'] = true;
        await _userCollection.doc(uid).update(updateUser);
      }
      return "Account Succefully Deleted";
    } on Exception catch (e) {
      return "Error Deleting User: $e";
    }
  }


  Stream<List<UserModel>> getUserList({String orderBy = 'uid'}) {
    // query
    return _userCollection
      .orderBy(orderBy)
      .snapshots()
      .map((snapshot){
        return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      });
  }

  Future<void> uploadProfilePicAndSave(FilePickerResult? result) async {
  // 1. upload to Cloudinary
  String? imageUrl = await uploadToCloudinary(result);

  if (imageUrl != null) {
    // 2. save to Firestore
    final firebaseUser = FirebaseUser();
    String? res = await firebaseUser.updateUserProfile(profilePicture: imageUrl);
    print("Firestore update: $res");
  }
}
  // get the particular user
   Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _userCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }
  
}
