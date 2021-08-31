import 'package:flutter/material.dart';
import 'package:osbb_test/chat/model/message_model.dart';
import 'package:intl/intl.dart';

class MyMessageWidget extends StatelessWidget {
  MyMessageWidget({Key? key, required this.message}) : super(key: key);
  final Message message;

  final radius = Radius.circular(10);
  final padding = EdgeInsets.all(10);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: padding,
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .7),
            decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.only(
                    topLeft: radius, bottomLeft: radius, bottomRight: radius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  message.message,
                  textAlign: TextAlign.end,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  DateFormat('HH:mm').format(message.createdAt.toDate()),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
