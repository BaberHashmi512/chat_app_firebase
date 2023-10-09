import 'package:flutter/material.dart';

class GroupInfo extends StatelessWidget {
  const GroupInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: BackButton()),
              Container(
                height: size.height / 8,
                width: size.width / 1.1,
                child: Row(
                  children: [
                    Container(
                      height: size.height / 11,
                      width: size.height / 11,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.grey),
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
                        child: Text("Group Name",
                        style: TextStyle(
                          fontSize: size.width /16,
                          fontWeight: FontWeight.w500
                        ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
