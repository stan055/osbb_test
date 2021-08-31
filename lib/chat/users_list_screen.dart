import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/chat/admin_chat_screen.dart';
import 'package:osbb_test/chat/user_info_screen.dart';
import 'package:osbb_test/chat/service/users_and_chat_service.dart';
import 'package:provider/provider.dart';

class UsersList extends StatefulWidget {
  const UsersList({Key? key, required this.appUser}) : super(key: key);
  final AppUser appUser;

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  @override
  void initState() {
    super.initState();
    if (context.read<UsersAndChatService>().isUsersSubscriptionIsNull())
      context.read<UsersAndChatService>().addUsersSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersAndChatService>(builder: (context, chatService, _) {
      return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: chatService.users.length,
          itemBuilder: (context, index) {
            final user = chatService.users[index];
            if (user.uid == widget.appUser.uid) return SizedBox();
            return Card(
              margin: EdgeInsets.all(10),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(8),
                leading: CircularProfileAvatar(
                  user.urlAvatar,
                  initialsText: Text(
                    user.firstName[0],
                    style: TextStyle(fontSize: 30),
                  ),
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  borderColor: Colors.orange.shade100,
                  cacheImage: true,
                  showInitialTextAbovePicture: false,
                ),
                title: Text('${user.firstName} ${user.lastName}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(text: 'Room '),
                      TextSpan(
                          text: '${user.roomNumber}\n',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Status: '),
                      TextSpan(
                          text: describeEnum(user.role),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: user.role == Role.NOTCONFIRMED
                                  ? Colors.red
                                  : Colors.green)),
                      unreadMessageWidget(
                          user.lastMessageTime, user.lastSeenTime)
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.person_search_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInfo(
                                user: user,
                              )),
                    );
                  },
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminChat(
                                user: user,
                                admin: widget.appUser,
                              )));
                },
              ),
            );
          });
    });
  }

  unreadMessageWidget(Timestamp? lastMessageTime, Timestamp? lastSeenTime) {
    if (lastMessageTime == null || lastSeenTime == null) return TextSpan();
    if (lastMessageTime.millisecondsSinceEpoch >
        lastSeenTime.millisecondsSinceEpoch) {
      return TextSpan(
          text: '\nThere is unread message',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent));
    } else
      return TextSpan();
  }
}
