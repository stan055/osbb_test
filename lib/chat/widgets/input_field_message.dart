import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/chat/model/message_model.dart';
import 'package:osbb_test/chat/service/users_and_chat_service.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/services/messaging_service.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InputFieldMessage extends StatefulWidget {
  InputFieldMessage(
      {Key? key,
      required this.userUid,
      required this.fromUid,
      required this.fromName,
      this.token})
      : super(key: key);
  final String? userUid;
  final String? fromUid;
  final String fromName;
  final String? token;

  @override
  _InputFieldMessageState createState() => _InputFieldMessageState();
}

class _InputFieldMessageState extends State<InputFieldMessage> {
  final controller = TextEditingController();
  List<String> tokens = [];

  @override
  void initState() {
    if (widget.token != null) {
      tokens.add(widget.token!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                labelText: 'Type your message',
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0),
                  gapPadding: 10,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (controller.text.trim().isNotEmpty && widget.fromUid != null)
                uploadMessage(controller.text, context);
              controller.clear();
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future uploadMessage(String text, BuildContext context) async {
    String message = text;
    try {
      final chatService = context.read<UsersAndChatService>();

      // Get token if tokens is empty
      if (tokens.isEmpty) {
        if (chatService.adminsToken.isEmpty) {
          List<dynamic> dynamicTokens = await UsersAndChatService
              .getListByWhereIsEqualToValueAndNestedByFieldPath(
                  'users', 'role', Role.ADMIN.index, 'messageToken');
          final convertedToStringTokens =
              dynamicTokens.map((token) => token as String).toList();
          chatService.adminsToken.addAll(convertedToStringTokens);
        }
        tokens.addAll(chatService.adminsToken);
      }

      // Get messaging server address
      if (chatService.messagingServerAddress == null)
        chatService.messagingServerAddress =
            await MessagingService.getMessagingServerAddress();
      String? messagingServerAddress = chatService.messagingServerAddress;

      UsersAndChatService.writeMessageToDatabase(
          widget.userUid,
          Message(
            from: widget.fromUid!,
            message: message,
            createdAt: Timestamp.now(),
          ).toJson());

      UsersAndChatService.updateLastMessageTimeField(widget.userUid);

      if (tokens.isNotEmpty && messagingServerAddress != null)
        MessagingService.sendToDevice(
            serverAddress: messagingServerAddress,
            tokens: tokens,
            title:
                '${AppLocalizations.of(context)!.newMessageFrom} ${widget.fromName}',
            body: message,
            ownerUid: widget.fromUid);
    } catch (e) {
      final snackBar =
          SnackBar(content: Text('ERROR INPUT FIELD: ${e.toString()}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
