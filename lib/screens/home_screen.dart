import 'package:chat_app/group_chat/group_chat_screen.dart';
import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/chat_room.dart';
import 'package:chat_app/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> membersList = [];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // setStatus("Online");
    super.initState();
  }

  void getCurrentUserChats() async {
    print("Baber");
    await fireStore.collection('users').doc(_auth.currentUser!.uid).get().then(
      (map) {
        setState(
          () {
            membersList.add(
              {
                "username": map['username'],
                "email": map['email'],
                "image": map['image_url'],
                "uid": map['uid'],
              },
            );
          },
        );
      },
    );
  }

  // void setStatus(String status) async {
  //   await fireStore.collection('users').doc(_auth.currentUser!.uid).update({
  //     "status": status,
  //   });
  // }

  @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     setStatus("Online");
  //     // online
  //   } else {
  //     setStatus("Offline");
  //     // offline
  //   }
  // }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await fireStore
        .collection('users')
        .where("email", isEqualTo: _searchController.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Home Screen",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton(itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: "profile",
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
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
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthScreen()));
                    FirebaseAuth.instance.signOut();
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
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 20,
                ),
                Container(
                  height: size.height / 14,
                  width: size.width,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: size.height / 14,
                    width: size.width / 1.15,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          hintText: "Search email here please...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                ElevatedButton(
                  onPressed: onSearch,
                  child: const Text("Search"),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? ListTile(
                        onTap: () {
                          String roomId = chatRoomId(
                              _auth.currentUser!.displayName.toString(),
                              userMap!['username']);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                userMap: userMap!,
                                chatRoomId: roomId,
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            userMap!['image_url'],
                          ),
                        ),
                        title: Text(
                          userMap!['username'],
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                        subtitle: Text(userMap!['email']),
                        trailing: const Icon(Icons.chat),
                      )
                    : Container(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Chats List",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: getCurrentUserChats,
                                child: const Text("test"),
                              ),
                              Flexible(
                                child: ListView.builder(
                                  itemCount: membersList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        radius: 24,
                                        backgroundImage: NetworkImage(
                                            membersList[index]['image']),
                                      ),
                                      title:
                                          Text(membersList[index]['username']),
                                      subtitle:
                                          Text(membersList[index]['email']),
                                      trailing: const Icon(Icons.chat),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.group),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GroupChatHomeScreen(),
          ),
        ),
      ),
    );
  }
}
