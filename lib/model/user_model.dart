class UserModel {
  String? uid;
  String? userName;
  String? emailAddress;
  String? residentialAddress;
  String? phoneNumber;
  String? password;

  UserModel(
      {this.uid,
      this.userName,
      this.emailAddress,
      this.residentialAddress,
      this.phoneNumber,
      this.password});

  //receive data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      userName: map['userName'],
      emailAddress: map['emailAddress'],
      residentialAddress: map['residentialAddress'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
    );
  }

  //sending data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'emailAddress': emailAddress,
      'residentialAddress': residentialAddress,
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}
