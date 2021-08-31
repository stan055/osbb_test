import 'package:flutter/material.dart';
import 'package:osbb_test/chat/widgets/input_field_message.dart';
import 'package:osbb_test/chat/widgets/message_widget.dart';
import 'package:osbb_test/chat/widgets/my_message_widget.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:provider/provider.dart';
import 'package:osbb_test/chat/service/users_and_chat_service.dart';

class UserChat extends StatefulWidget {
  const UserChat({Key? key, required this.appUser}) : super(key: key);
  final AppUser appUser;

  @override
  _UserChatState createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  ScrollController scrollController = new ScrollController();
  String? messagingServerAddress;

  @override
  void initState() {
    initChatMessagesSubscription();
    getAdminsUid();
    super.initState();
  }

  @override
  void deactivate() {
    context.read<UsersAndChatService>().blockNotificationMessageFrom.clear();
    super.deactivate();
  }

  getAdminsUid() {
    final chatService = context.read<UsersAndChatService>();

    if (chatService.adminsUid.isEmpty) {
      UsersAndChatService.getListByWhereIsEqualToValueAndNestedByFieldPath(
              'users', 'role', Role.ADMIN.index, 'uid')
          .then((adminsUid) {
        try {
          chatService.adminsUid =
              adminsUid.map((uid) => uid as String).toList();
          chatService.blockNotificationMessageFrom
              .addAll(chatService.adminsUid);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ERROR Get admins uid: $e')));
        }
      });
    } else {
      chatService.blockNotificationMessageFrom = chatService.adminsUid;
    }
  }

  initChatMessagesSubscription() async {
    final chatService = context.read<UsersAndChatService>();
    if (widget.appUser.uid != null) {
      if (chatService.isChatSubscriptionIsNull()) {
        chatService.addChatMessagesSubscription(widget.appUser.uid!);
      } else if (widget.appUser.uid != chatService.chatMessagesUid) {
        await chatService.unsibscribeChat();
        chatService.addChatMessagesSubscription(widget.appUser.uid!);
      }
    } else {
      chatService.unsibscribeChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersAndChatService>(builder: (context, chatService, _) {
      if (scrollController.positions.isNotEmpty) scrollController.jumpTo(0.0);
      return Column(
        children: [
          Expanded(
              child: ListView.builder(
            controller: scrollController,
            physics: BouncingScrollPhysics(),
            reverse: true,
            itemCount: chatService.chatMessages.length,
            itemBuilder: (context, index) {
              final message = chatService.chatMessages[index];
              final previosMessageUid =
                  index + 1 < chatService.chatMessages.length
                      ? chatService.chatMessages[index + 1].from
                      : null;
              final isMe = widget.appUser.uid == message.from ? true : false;

              return isMe == true
                  ? MyMessageWidget(message: message)
                  : MessageWidget(
                      message: message,
                      previosMessageUid: previosMessageUid,
                      avatarIcon: Icons.support_agent_outlined,
                      name: 'Admin');
            },
          )),
          InputFieldMessage(
            userUid: widget.appUser.uid,
            fromUid: widget.appUser.uid,
            fromName: widget.appUser.firstName,
          )
        ],
      );
    });
  }
}
