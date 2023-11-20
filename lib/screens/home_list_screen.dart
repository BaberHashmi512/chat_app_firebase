import 'package:chat_app/Models/FirebaseHelper.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Models/chatRoomModel.dart';
import 'package:chat_app/group_chat/group_chat_screen.dart';
import 'package:chat_app/screens/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'SearchPage.dart';
import 'account_screen.dart';
import 'chat_room.dart';

class HomeChat extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomeChat(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  _HomeChatState createState() => _HomeChatState();
}

class _HomeChatState extends State<HomeChat> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
      userMap = null;
    });

    await _firestore
        .collection('users')
        .where("email", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        isLoading = false;
      });

      if (value.docs.isNotEmpty) {
        setState(() {
          userMap = value.docs[0].data();
        });
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("No Data Found"),
              content:
                  const Text("No user with the specified email was found."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void showLogoutDialogue() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Center(
                  child: Text('Logout',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text('Are you want to Logout'),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.blue)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('No')),
                    ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.blue)),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(),
                              ));
                        },
                        child: const Text('Yes')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteChatRoom(chatroomId) async {
    // Delete all messages in the chat room
    await FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatroomId)
        .collection("messages")
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    });

    // Delete the chat room itself
    await FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatroomId)
        .delete();

    print("Chat room deleted!");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text("Home Screen", style: TextStyle(
              fontWeight: FontWeight.bold
            ),),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GroupChatHomeScreen(),
                        ));
                  },
                  icon: const Icon(Icons.group)),
              PopupMenuButton(itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: "profile",
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AccountScreen(userModel: widget.userModel),
                            ));
                      },
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.person),
                          ),
                          Text(
                            'Profile',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: "logout",
                    child: InkWell(
                      onTap: () async {
                        showLogoutDialogue();
                        // FirebaseAuth.instance.signOut();
                      },
                      child: const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.logout),
                          ),
                          Text(
                            'Logout',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              }),
            ],
            leading: const Icon(Icons.home)),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
            setState(() {});
          },
          child: SafeArea(
            child: Container(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatroom")
                    .where("participants.${widget.userModel.uid}",
                        isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot =
                          snapshot.data as QuerySnapshot;

                      return ListView.builder(
                        itemCount: chatRoomSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);

                          Map<String, dynamic> participants =
                              chatRoomModel.participants!;

                          List<String> participantKeys =
                              participants.keys.toList();
                          participantKeys.remove(widget.userModel.uid);

                          return FutureBuilder(
                            future: FirebaseHelper.getGroupUserModelById(
                                participantKeys[0]),
                            builder: (context, userData) {
                              if (userData.connectionState ==
                                  ConnectionState.done) {
                                if (userData.data != null) {
                                  UserModel targetUser =
                                      userData.data as UserModel;
                                  return ListTile(
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Column(
                                                children: [
                                                  const Center(
                                                    child: Text('Delete',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                  const SizedBox(
                                                    height: 30,
                                                  ),
                                                  const Text(
                                                      'Are you want to Delete this chat'),
                                                  const SizedBox(
                                                    height: 30,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      ElevatedButton(
                                                          style:
                                                              const ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStatePropertyAll(
                                                                    Colors.red),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text('No')),
                                         ElevatedButton(
                                             style: const ButtonStyle(
                                               backgroundColor:
                                                  MaterialStatePropertyAll(
                                                           Colors.blue)),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            deleteChatRoom(chatRoomModel.chatroomid);
                                                          },
                                                          child: const Text('Yes')),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) {
                                          return ChatRoomPage(
                                            chatroom: chatRoomModel,
                                            firebaseUser: widget.firebaseUser,
                                            userModel: widget.userModel,
                                            targetUser: targetUser,
                                          );
                                        }),
                                      );
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          // AssetImage('assets/images/person.png'),
                                          NetworkImage(
                                              targetUser.profilpic.toString()),
                                    ),
                                    trailing: const Icon(Icons.message),
                                    title: Text(targetUser.username.toString()),
                                    subtitle:
                                        (chatRoomModel.lastMessage.toString() != "")
                                            ? Text(chatRoomModel.lastMessage
                                                .toString())
                                            : Text("Say hi to your new friend!",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return const Center(
                        child: Text("No Chats"),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SearchPage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser);
              // return SearchPage(GroupUserModel: widget.GroupUserModel, firebaseUser: widget.firebaseUser);
            }));
          },
          child: const Icon(Icons.search),
        ),
      ),
    );
  }
}
