import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realestate/models/property.dart';
//import 'package:realestate/models/user.dart';

class FirebaseProperties {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _collectionReference = FirebaseFirestore.instance
      .collection('properties');

  // property add
  // property add
  Future<String?> propertyAdd(PropertyModel property) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      return "NotLogged"; // user not
    }

    try {
      final docRef = _collectionReference.doc();

      final PropertyModel newProperty = property.copyWith(
        id: docRef.id,
        ownerId: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(newProperty.toMap());

      // also add property ID to the current user document (myProperties array)
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      await userRef.set({
        "myProperties": FieldValue.arrayUnion([docRef.id]),
      }, SetOptions(merge: true));

      return docRef.id;
    } catch (e) {
      print("Error adding property: $e");
      return e.toString();
    }
  }

  // a property get
  Future<PropertyModel?> propertyGet(String propertyId) async {
    try {
      final doc = await _collectionReference.doc(propertyId).get();

      if (doc.exists) {
        return PropertyModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } on Exception catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // List of all properties (all property)
  Future<List<PropertyModel>> getAllProperties() async {
    try {
      final snapshot = await _collectionReference
          .where("listingType", isNotEqualTo: "auction")
          .orderBy("listingType")
          .orderBy("createdAt", descending: true)
           // latest will give
          .get();
      return snapshot.docs
          .map(
            (doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } on Exception catch (e) {
      print("Error to fetch the list $e");
      return [];
    }
  }

  // List of property listed by current user (myproperties)
  Future<List<PropertyModel>> getMyProperties() async {
    final User? user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _collectionReference
          .where("ownerId", isEqualTo: user.uid)
          .get();

      return snapshot.docs
          .map(
            (doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print("Error fetching my properties: $e");
      return [];
    }
  }

  // List of saved properties by user (savedproperties)
  Future<List<PropertyModel>> getSavedProperties() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        print("User not Logged in");
        return [];
      }

      // first get the current user whole details
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        print("Not Found!");
        return [];
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      // get savedproperty list
      final savedProperties = List<String>.from(
        userData['savedProperties'] ?? [],
      );

      if (savedProperties.isEmpty) {
        return [];
      }

      // fetching all the property where document id matches

      final snapshot = await _collectionReference
          .where(FieldPath.documentId, whereIn: savedProperties)
          .get();

      return snapshot.docs
          .map(
            (doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } on Exception catch (e) {
      print("Error $e");
      return [];
    }
  }

  // list of properties for sale only
  Future<List<PropertyModel>> getSaleProperties() async {
    try {
      final snapshot = await _collectionReference
          .where("listingType",  isEqualTo: "sale")
          .orderBy("createdAt", descending: true) 
          .get();

      return snapshot.docs
          .map(
            (doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } on Exception catch (e) {
      print("Error fetching sale properties: $e");
      return [];
    }
  }

  // list of properties for rent only
  Future<List<PropertyModel>> getRentProperties() async {
    try {
      final snapshot = await _collectionReference
          .where("listingType", isEqualTo: "rent") 
          .orderBy("createdAt", descending: true) 
          .get();

      return snapshot.docs
          .map(
            (doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } on Exception catch (e) {
      print("Error fetching sale properties: $e");
      return [];
    }
  }

  // for auction
  Future<List<PropertyModel>> getAuctionProperties() async {
    try {
      final snapshot = await _collectionReference
          .orderBy("createdAt", descending: true)
          .where("listingType", isEqualTo: "auction") // latest will give
          .get();
      return snapshot.docs
          .map(
            (doc) => PropertyModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } on Exception catch (e) {
      print("Error to fetch the list $e");
      return [];
    }
  }

  // for price increase decrease (high , low )

  // home type House, appartment, plot (hometype == )

  // bed, kitchen , ( || )
}
