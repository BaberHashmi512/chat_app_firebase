import 'dart:ui';

import 'package:chat_app/screens/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/UserModel.dart';
import 'EditProfile.dart';

class AccountScreen extends StatefulWidget {
  final UserModel userModel;

  const AccountScreen({super.key, required this.userModel});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  String name = "";
  String email = "";
  String profileImg = "";

  void _fetchUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        name = userDoc['username'];
        email = userDoc['email'];
        profileImg = userDoc['image_url'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'User Information',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        iconTheme: IconThemeData.fallback(),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    EditProfileScreen(userModel: widget.userModel),
              ));
            },
          ),
        ],
      ),
      body: Container(
        // color: Color.fromRGBO(150, 182, 197, 10),
        // color: Colors.black38,
        // decoration: new BoxDecoration(color: Colors.white.withOpacity(0.1)),
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(Duration(milliseconds: 500));
            setState(() {
              _fetchUserData();
            });
          },
          child: ListView(children: [
            Center(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(profileImg),
                        radius: 70,
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Container(
                        width: 350,
                        height: 160,
                        decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(20)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30,),
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.drive_file_rename_outline),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Name : ${name}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.email_outlined),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Email : ${email}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),

                          ],
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      GestureDetector(
                        onTap: () {
                          showLogoutDialogue();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.red,size: 30,),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Logout', style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
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
                SizedBox(
                  height: 30,
                ),
                Text('Are you want to Logout'),
                SizedBox(
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
                        child: Text('No')),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStatePropertyAll(Colors.blue)),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthScreen(),
                              ));
                        },
                        child: Text('Yes')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}