class UserProfile {
  String? userName;
  String? residentialAddress;
  String? phoneNumber;
  String? emailAddress;
  String? password;

  UserProfile(
      {this.userName,
      this.residentialAddress,
      this.phoneNumber,
      this.emailAddress,
      this.password});

  // Convert data to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'residentialAddress': residentialAddress,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'password': password,
    };
  }

  // Create a UserProfile object from Firestore data
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userName: map['userName'],
      residentialAddress: map['residentialAddress'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
      emailAddress: map['emailAddress'],
    );
  }
}
