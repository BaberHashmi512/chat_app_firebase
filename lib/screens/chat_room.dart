import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatelessWidget {
  final Map<String, dynamic>? userMap;
  final String? chatRoomId;

  ChatRoom({this.chatRoomId, this.userMap});

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;
    await fireStore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "id": fileName,
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });
    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpeg");
    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();
      status = 0;
    });
    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});
      print(imageUrl);
    }
  }

  ///  sending a Message
  void onSendMessage() async {
    String messageId = const Uuid().v1();
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "id": messageId,
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await fireStore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(messageId)
          .set(messages);
    } else {
      print("Enter Some Text");
    }
  }

  void deleteMessage(messageId) async {
    await FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .delete();
  }

  void editMessage(String messageId, String newText) async {
    await FirebaseFirestore.instance
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .update({
      "message": newText,
      "edited": true,
      "editedOn": DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: StreamBuilder<DocumentSnapshot>(
            stream:
                fireStore.collection("users").doc(userMap!['uid']).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Container(
                  child: Column(
                    children: [
                      Text(userMap!['username']),
                      Text(
                        snapshot.data!['status'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
        body: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          shrinkWrap: true,
          children: [
            Column(
              children: [
                SizedBox(
                  height: size.height / 1.25,
                  width: size.width,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: fireStore
                        .collection('chatroom')
                        .doc(chatRoomId)
                        .collection('chats')
                        .orderBy("time", descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.data != null) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> map =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return GestureDetector(
                              onLongPress: () {
                                showDialog(
                                  context: (context),
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
                                              child: Text(
                                                "Delete or Edit",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            const Text(
                                              'Are you want to Delete or Edit this Message',
                                            ),
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    deleteMessage(map["id"]);
                                                  },
                                                  child: const Text("Delete"),
                                                ),
                                                ElevatedButton(
                                                  style: const ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.red),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  style: const ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStatePropertyAll(
                                                            Colors.white),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        TextEditingController
                                                            editController =
                                                            TextEditingController();
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Edit Message'),
                                                          content: TextField(
                                                            controller:
                                                                editController,
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText:
                                                                  'Enter edited message',
                                                            ),
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                String
                                                                    editedText =
                                                                    editController
                                                                        .text
                                                                        .trim();
                                                                if (editedText
                                                                    .isNotEmpty) {
                                                                  editMessage(
                                                                      map['id'],
                                                                      editedText);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                }
                                                              },
                                                              child: const Text(
                                                                  'Save'),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Text('Edit'),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: messages(size, map, context),
                            );
                          },
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                Container(
                  height: size.height / 10,
                  width: size.width,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: size.height / 12,
                    width: size.width / 1.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: size.height / 17,
                          width: size.width / 1.3,
                          child: TextField(
                            keyboardAppearance: Brightness.dark,
                            controller: _message,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () => getImage(),
                                icon: const Icon(Icons.photo),
                              ),
                              hintText: 'Send Message',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onSendMessage,
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
            width: size.width,
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blue,
              ),
              child: Text(
                map['message'],
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          )
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: map['sendby'] == _auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['message'],
                  ),
                ),
              ),
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration(border: Border.all()),
                alignment: map['message'] != "" ? null : Alignment.center,
                child: map['message'] != ""
                    ? Image.network(
                        map['message'],
                        fit: BoxFit.cover,
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
