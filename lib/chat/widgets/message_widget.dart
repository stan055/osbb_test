import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/chat/model/message_model.dart';
import 'package:intl/intl.dart';

class MessageWidget extends StatelessWidget {
  MessageWidget(
      {Key? key,
      required this.message,
      required this.previosMessageUid,
      this.avatarUrl = '',
      this.avatarIcon,
      required this.name})
      : super(key: key);
  final Message message;
  final String? previosMessageUid;
  final IconData? avatarIcon;
  final String avatarUrl;
  final String name;

  final radius = Radius.circular(10);
  final padding = EdgeInsets.all(10);

  @override
  Widget build(BuildContext context) {
    bool avatar = previosMessageUid != message.from;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: avatar == true
                  ? CircularProfileAvatar(
                      avatarUrl,
                      child: avatarIcon != null ? Icon(avatarIcon) : null,
                      initialsText: Text(name[0]),
                      radius: 16,
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.grey.shade200,
                      cacheImage: true,
                      showInitialTextAbovePicture: false,
                    )
                  : SizedBox(width: 32)),
          Container(
            padding: padding,
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .7),
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                    topRight: radius, bottomLeft: radius, bottomRight: radius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  message.message,
                  textAlign: TextAlign.start,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  DateFormat('HH:mm').format(message.createdAt.toDate()),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
