import 'package:flutter/material.dart';
import 'package:osbb_test/chat/user_chat.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/chat/users_list_screen.dart';

class ChatRoot extends StatelessWidget {
  const ChatRoot({Key? key, required this.appUser}) : super(key: key);
  final AppUser? appUser;

  @override
  Widget build(BuildContext context) {
    return appUser == null
        ? Center(
            child: Text('User data has null'),
          )
        : appUser!.role == Role.ADMIN
            ? UsersList(
                appUser: appUser!,
              )
            : UserChat(appUser: appUser!);
  }
}
