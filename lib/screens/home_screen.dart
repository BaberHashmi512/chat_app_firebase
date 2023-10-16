import 'package:chat_app/group_chat/group_chat_screen.dart';
import 'package:chat_app/screens/chat_room.dart';
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

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
    super.initState();
  }

  void setStatus(String status) async {
    await fireStore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus("Online");
      // online
    } else {
      setStatus("Offline");
      // offline
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
    FirebaseFirestore fireStore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await fireStore
        .collection('users')
        .where("username", isEqualTo: _searchController.text)
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
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.exit_to_app))
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
                          hintText: "user name...",
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
                          backgroundImage: NetworkImage(userMap!['image_url'],),
                        ), 
                        // CircleAvatar(
                        //   radius: 23,
                        //   child: ClipOval(
                        //     child: Image.network(
                        //       userMap!['image_url'],
                        //       fit: BoxFit.cover,
                        //     ),
                        //   ),
                        // ),
                        title: Text(
                          userMap!['username'],
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                        ),
                        subtitle: Text(userMap!['email']),
                        trailing: const Icon(Icons.chat),
                      )
                    : Container(
                        child: const ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(
                                "https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?"
                                "auto=compress&cs=tinysrgb&dpr=1&w=500"),
                          ),
                          title: Text("Baber"),
                          subtitle: Text("baberhashmi512@gmail.com"),
                          trailing: Icon(Icons.chat),
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
