
class UserModel{
  final String uid;
  // -- necessary info
  final String email;
  final String name;
  final String password;
  final String? address;
  final String? phoneNumber;
  final bool isPremium; 
  final bool isDeleted; // actice or not active
  final List<String> savedProperties; // property id // add to card 
  final List<String> myProperties; // property id // buy products
  final List<String> transactions; // payment id 
  // structure banking information list
  final List<Map<String, String>> bankingInfo;
  // image url
  final String? profilePicture;

  UserModel({
    required this.uid,
    required this.email, // update account setting
    required this.name, // update account setting
    required this.password, // update account setting
    this.address, // update account setting
    this.phoneNumber, // update account setting 
    this.isPremium = false, // go to premium option
    this.isDeleted = false, // go to deleted section
    this.savedProperties = const [],
    this.myProperties = const [],
    this.transactions = const [],
    this.bankingInfo = const[],
    this.profilePicture, // update account setting
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'password': password,
      'address': address,
      'phoneNumber': phoneNumber,
      'isPremium': isPremium,
      'isDeleted': isDeleted, 
      'savedProperties': savedProperties,
      'myProperties': myProperties,
      'transactions': transactions,
      'bankingInfo': bankingInfo,
      'profilePicture':profilePicture,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      address: map['address'],
      phoneNumber: map['phoneNumber'],
      isPremium: map['isPremium'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      savedProperties: List<String>.from(map['savedProperties'] ?? []),
      myProperties: List<String>.from(map['myProperties'] ?? []),
      transactions: List<String>.from(map['transactions'] ?? []),
      bankingInfo: List<Map<String, String>>.from(map['bankingInfo'] ?? []),
      profilePicture: map['profilePicture'],
    );
  }

}


