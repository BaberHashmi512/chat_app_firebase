import 'package:chat_app/group_chat/group_chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_members.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({required this.groupId, required this.groupName, Key? key})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;


  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      print(membersList);
      isLoading = false;
      setState(() {});
    });
  }
  bool isAdmin = false;

  bool checkAdmin() {

    membersList.forEach((element) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['uid'];

    setState(() {
      isLoading = true;
      membersList.removeAt(index);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      setState(() {
        isLoading = false;
      });
    });
  }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != membersList[index]['uid']) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ListTile(
                  onTap: () {
                    removeMembers(index);
                    Navigator.of(context).pop();
                  },
                  title: Text("Remove This Member"),
                ),
              );
            });
      }
    }
  }


  Future<void> onLeaveGroup() async {
    bool isAdmin = checkAdmin();

    setState(() {
      isLoading = true;
    });

    try {
      if (isAdmin) {
        // Delete the group for all users
        List memberIds = membersList.map((member) => member['uid']).toList();
        await _firestore.collection('groups').doc(widget.groupId).delete();

        // Remove the group reference from each user
        for (String memberId in memberIds) {
          await _firestore
              .collection('users')
              .doc(memberId)
              .collection('groups')
              .doc(widget.groupId)
              .delete();
        }
      } else {
        // Remove the user from the group
        List<Map<String, dynamic>> updatedMembersList = List.from(membersList);
        for (int i = 0; i < updatedMembersList.length; i++) {
          if (updatedMembersList[i]['uid'] == _auth.currentUser!.uid) {
            updatedMembersList.removeAt(i);
            break;
          }
        }
        await _firestore.collection('groups').doc(widget.groupId).update({
          "members": updatedMembersList,
        });

        // Remove the group reference from the current user
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('groups')
            .doc(widget.groupId)
            .delete();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => GroupChatHomeScreen()),
            (route) => true,
      );
    } catch (e) {
      print("Error leaving the group: $e");
      setState(() {
        isLoading = false;
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
          height: size.height,
          width: size.width,
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BackButton(),
              ),
              Container(
                height: size.height / 8,
                width: size.width / 1.1,
                child: Row(
                  children: [
                    Container(
                      height: size.height / 11,
                      width: size.height / 11,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Icon(
                        Icons.group,
                        color: Colors.white,
                        size: size.width / 10,
                      ),
                    ),
                    SizedBox(
                      width: size.width / 20,
                    ),
                    Expanded(
                      child: Container(
                        child: Text(
                          widget.groupName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: size.width / 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //

              SizedBox(
                height: size.height / 20,
              ),

              Container(
                width: size.width / 1.1,
                child: Text(
                  "${membersList.length} Members",
                  style: TextStyle(
                    fontSize: size.width / 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(
                height: size.height / 20,
              ),
              checkAdmin()
                  ? ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddMembersINGroup(
                      groupChatId: widget.groupId,
                      name: widget.groupName,
                      membersList: membersList,
                    ),
                  ),
                ),
                leading: Icon(
                  Icons.add,
                ),
                title: Text(
                  "Add Members",
                  style: TextStyle(
                    fontSize: size.width / 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : SizedBox(),

              Flexible(
                child: ListView.builder(
                  itemCount: membersList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final isAdmin = membersList[index]?['isAdmin'] ?? false; // Provide a default value if 'isAdmin' is null

                    return ListTile(
                      onTap: () => showDialogBox(index),
                      leading: Icon(Icons.account_circle),
                      title: Text(
                        membersList[index]['name'] ?? '', // Provide a default value if 'name' is null
                        style: TextStyle(
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(membersList[index]['email'] ?? ''), // Provide a default value if 'email' is null
                      trailing: Text(isAdmin ? "Admin" : ""),
                    );
                  },
                ),
              ),


              ListTile(
                onTap: onLeaveGroup,
                leading: Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                ),

                title: Text(
                  isAdmin ? "Delete Group" :
                  "Leave Group",
                  style: TextStyle(
                    fontSize: size.width / 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
