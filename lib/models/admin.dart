

class AdminModel{
  String id;
  String email;
  String name;
  String password;
  //String role;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    // required this.role,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      password: map['password'],
      // role: map['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password,
      // 'role': role,
    };
  }

}