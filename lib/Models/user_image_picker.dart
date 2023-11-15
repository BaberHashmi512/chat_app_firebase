import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'UserModel.dart';

class UserImagePickerEdit extends StatefulWidget {
  const UserImagePickerEdit({super.key, required this.onPickImage, required this.userModel});
  final void Function(File pickedImage) onPickImage;
  final UserModel userModel;
  @override
  State<UserImagePickerEdit> createState() => _UserImagePickerEditState();
}

class _UserImagePickerEditState extends State<UserImagePickerEdit> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey,
            foregroundImage: _pickedImageFile != null
                ? FileImage(_pickedImageFile!)
                : NetworkImage(widget.userModel.profilpic.toString()) as ImageProvider,
          ),
        )

      ],
    );
  }
}