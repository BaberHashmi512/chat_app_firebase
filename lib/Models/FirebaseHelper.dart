import 'package:cloud_firestore/cloud_firestore.dart';

import 'UserModel.dart';

class FirebaseHelper {
  static Future<UserModel?> getGroupUserModelById(String uid) async {
    UserModel? GroupUserModel;
    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docSnap.data() != null) {
      GroupUserModel =
          UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }

    return GroupUserModel;
  }
}
