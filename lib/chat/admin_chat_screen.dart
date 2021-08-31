import 'package:flutter/material.dart';
import 'package:osbb_test/chat/widgets/input_field_message.dart';
import 'package:osbb_test/chat/widgets/message_widget.dart';
import 'package:osbb_test/chat/widgets/my_message_widget.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:provider/provider.dart';
import 'package:osbb_test/chat/service/users_and_chat_service.dart';

class AdminChat extends StatefulWidget {
  const AdminChat({Key? key, required this.user, required this.admin})
      : super(key: key);
  final AppUser user;
  final AppUser admin;

  @override
  _AdminChatState createState() => _AdminChatState();
}

class _AdminChatState extends State<AdminChat> {
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    initChatMessagesSubscription();
    addBlockNotificationMessageFromThisUser();
    super.initState();
  }

  addBlockNotificationMessageFromThisUser() {
    if (widget.user.uid != null)
      context
          .read<UsersAndChatService>()
          .blockNotificationMessageFrom
          .add(widget.user.uid!);
  }

  initChatMessagesSubscription() async {
    final chatService = context.read<UsersAndChatService>();
    if (widget.user.uid != null) {
      if (chatService.isChatSubscriptionIsNull()) {
        chatService.addChatMessagesSubscription(widget.user.uid!);
      } else {
        await chatService.unsibscribeChat();
        chatService.addChatMessagesSubscription(widget.user.uid!);
      }
    }
  }

  @override
  void deactivate() {
    UsersAndChatService.updateLastSeenTimeField(widget.user.uid);
    context.read<UsersAndChatService>().unsibscribeChat();
    context.read<UsersAndChatService>().blockNotificationMessageFrom.clear();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        leading: IconButton(
          icon: new Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${widget.user.firstName} ${widget.user.lastName}',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Consumer<UsersAndChatService>(builder: (context, chatService, _) {
        if (_scrollController.positions.isNotEmpty)
          _scrollController.jumpTo(0.0);
        return Column(
          children: [
            Expanded(
                child: ListView.builder(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              reverse: true,
              itemCount: chatService.chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatService.chatMessages[index];
                final previosMessageUid =
                    index + 1 < chatService.chatMessages.length
                        ? chatService.chatMessages[index + 1].from
                        : null;
                final isMe = widget.admin.uid == message.from ? true : false;

                return isMe == true
                    ? MyMessageWidget(message: message)
                    : MessageWidget(
                        message: message,
                        previosMessageUid: previosMessageUid,
                        avatarUrl: widget.user.urlAvatar,
                        name: widget.user.firstName);
              },
            )),
            InputFieldMessage(
              userUid: widget.user.uid,
              fromUid: widget.admin.uid,
              fromName: 'Admin',
              token: widget.user.messageToken,
            )
          ],
        );
      }),
    );
  }
}
