class UserModel {
  String? uid;
  String? username;
  String? email;
  String? profilpic;
  String? status;

  UserModel({this.uid, this.username, this.email, this.status, this.profilpic});

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    username = map["username"];
    email = map["email"];
    profilpic = map["image_url"];
    status = map["status"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "username": username,
      "email": email,
      "image_url" : profilpic,
      "status" : status
    };
  }
}