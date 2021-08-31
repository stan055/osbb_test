import 'dart:io';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/chat/service/users_and_chat_service.dart';
import 'package:osbb_test/poll/service/poll_service.dart';
import 'package:osbb_test/services/messaging_service.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:intl/intl.dart';
import 'package:osbb_test/widgets/header.dart';
import 'package:osbb_test/services/app_state_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late AppUser _appUser;
  XFile? _image;
  late ImagePicker _picker;

  @override
  void initState() {
    _appUser = context.read<AppStateService>().appUser != null
        ? context.read<AppStateService>().appUser!
        : new AppUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          'Login',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5.0,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProfileAvatar(
                  _appUser.urlAvatar,
                  radius: 60,
                  backgroundColor: Colors.transparent,
                  initialsText: Text(
                    "AD",
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                  borderColor: Colors.orange.shade100,
                  elevation: 5.0,
                  cacheImage: true,
                  onTap: () async {
                    await _uploadImage();
                  },
                  showInitialTextAbovePicture: false,
                ),
                SizedBox(
                  height: 15,
                ),
                Header(text: _appUser.firstName + ' ' + _appUser.lastName),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    Text('Tel. ' + _appUser.phoneNumber),
                    SizedBox(
                      height: 15,
                    ),
                    Text('Apartament №' + _appUser.roomNumber),
                    SizedBox(
                      height: 15,
                    ),
                    _appUser.lastMessageTime != null
                        ? Text(
                            'Last message  ${DateFormat('dd/MM/yyyy HH:mm').format(_appUser.lastMessageTime!.toDate())}')
                        : SizedBox(),
                    SizedBox(
                      height: 15,
                    ),
                    _appUser.createdTime != null
                        ? Text(
                            'Registered date  ${DateFormat('dd/MM/yyyy HH:mm').format(_appUser.createdTime!.toDate())}')
                        : SizedBox(),
                    SizedBox(
                      height: 15,
                    ),
                    Text('Status ' + describeEnum(_appUser.role)),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                ElevatedButton.icon(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      try {
                        context.read<PollService>().unsibscribe();
                        context.read<UsersAndChatService>().unsibscribeChat();
                        context.read<UsersAndChatService>().unsibscribeUsers();
                        MessagingService.unsubscribeFrom('vote');
                        context.read<AppStateService>().signOut();
                        Navigator.pop(context);
                      } catch (e) {
                        _showError('Error, to Exit was been failed:(');
                        print(e);
                      }
                    },
                    label: Text('Exit'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  _uploadImage() async {
    _picker = new ImagePicker();
    _image = await _pickImage(_picker);
    if (_image != null) {
      try {
        Reference ref = FirebaseStorage.instance.ref('avatars/${_appUser.uid}');
        if (_image != null) {
          await ref.putFile(File(_image!.path)).catchError((e) => print(e));
          final url = await ref.getDownloadURL();
          FirebaseFirestore.instance
              .doc('users/${_appUser.uid}')
              .update({'urlAvatar': url})
              .catchError((e) => print('Update image has been failed:('))
              .then((value) => this.setState(() {
                    _appUser.urlAvatar = url;
                  }));
        }
      } catch (e) {
        _showError(e.toString());
      }
    } else
      print('Image picker canceled');
  }

  Future<XFile?> _pickImage(ImagePicker picker) async {
    try {
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        image = await _getLostData(picker);
        return image;
      }
      return image;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<XFile?> _getLostData(ImagePicker picker) async {
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return null;
    }
    if (response.file != null) {
      return response.file;
    } else {
      return null;
    }
  }

  _showError(String e) {
    final snackBar = SnackBar(content: Text(e));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
