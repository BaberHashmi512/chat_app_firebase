import 'package:chat_app/Models/UserModel.dart';
import 'package:chat_app/Models/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;

  const EditProfileScreen({Key? key, required this.userModel})
      : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _selectedImage;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.userModel.username.toString();
    _emailController.text = widget.userModel.email.toString();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      if (_selectedImage != null) {
        String fileName = Uuid().v4();

        Reference storageReference =
        FirebaseStorage.instance.ref().child('profile_images/$fileName.jpg');
        await storageReference.putFile(_selectedImage!);
        String downloadURL = await storageReference.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': _fullNameController.text,
          'email': _emailController.text,
          'profileImageUrl': downloadURL,
        });
      } else {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': _fullNameController.text,
          'email': _emailController.text,
        });
      }

      Navigator.pop(context);
    } catch (error) {
      print('Error updating profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            // Add form fields for editing.
            child: Column(
              children: [
                UserImagePickerEdit(onPickImage: (pickedImage) {
                  _selectedImage = pickedImage;
                }, userModel: widget.userModel,),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _updateProfile();
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          )
      ),
    );
  }
}