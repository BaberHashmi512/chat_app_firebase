import 'package:chat_app/group_chat/group_chat_room.dart';
import 'package:flutter/material.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({super.key});

  @override
  State<GroupChatHomeScreen> createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      body: ListView.builder(
        itemCount: 5,
          itemBuilder: (context, index){
        return ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_)=>  GroupChatRoom())
          ),
          leading: const Icon(Icons.group),
          title: Text("Group $index"),
        );
      }),
      floatingActionButton: FloatingActionButton(
        tooltip: "Create Group",
          onPressed: (){},
        child: const Icon(Icons.create)),
    );
  }
}
