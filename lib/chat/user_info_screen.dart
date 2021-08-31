import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/services/messaging_service.dart';
import 'package:osbb_test/widgets/header.dart';
import 'package:intl/intl.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key, required this.user}) : super(key: key);
  final AppUser user;
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserDocument;

  @override
  void initState() {
    super.initState();
    streamUserDocument =
        FirebaseFirestore.instance.doc('users/${widget.user.uid}').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          iconTheme: IconThemeData(color: Colors.black87),
          title: Text(
            'User Info',
            style: TextStyle(color: Colors.black87),
          ),
        ),
        body: StreamBuilder(
            stream: streamUserDocument,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              List<Widget> children;
              if (snapshot.hasError) {
                children = _hasError(snapshot);
              } else {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    children = _connectionStateNone();
                    break;
                  case ConnectionState.waiting:
                    children = _connectionStateWaiting();
                    break;
                  case ConnectionState.active:
                    children = _connectionActive(snapshot);
                    break;
                  case ConnectionState.done:
                    children = _connectionStateDone(snapshot);
                    break;
                }
              }
              return Center(
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
                  ),
                ),
              );
            }));
  }

  List<Widget> _connectionActive(AsyncSnapshot<DocumentSnapshot> snapshot) {
    final data = snapshot.data?.data() as Map<String, dynamic>?;
    if (data == null) return <Widget>[Center(child: Text('User data is null'))];

    AppUser? user;
    try {
      user = AppUser.fromJson(data);
    } catch (e) {
      return <Widget>[Center(child: Text('Error ${e.toString()}'))];
    }

    return [
      CircularProfileAvatar(
        user.urlAvatar,
        radius: 60,
        backgroundColor: Colors.transparent,
        initialsText: Text(
          "AD",
          style: TextStyle(fontSize: 40, color: Colors.white),
        ),
        borderColor: Colors.orange.shade100,
        elevation: 5.0,
        cacheImage: false,
        showInitialTextAbovePicture: false,
      ),
      SizedBox(
        height: 15,
      ),
      Header(text: user.firstName + ' ' + user.lastName),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 15,
          ),
          Text('Tel.  ${user.phoneNumber}'),
          SizedBox(
            height: 15,
          ),
          Text('Apartament  #${user.roomNumber}'),
          SizedBox(
            height: 15,
          ),
          Text('UID  ${user.uid}'),
          SizedBox(
            height: 15,
          ),
          user.lastMessageTime != null
              ? Text(
                  'Last message  ${DateFormat('dd/MM/yyyy HH:mm').format(user.lastMessageTime!.toDate())}')
              : SizedBox(),
          SizedBox(
            height: 15,
          ),
          user.createdTime != null
              ? Text(
                  'Registered date  ${DateFormat('dd/MM/yyyy HH:mm').format(user.createdTime!.toDate())}')
              : SizedBox(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Status'),
              TextButton(
                  onPressed: () => statusEditDialogWindow(context, user?.role),
                  child: Row(children: [
                    Text(
                      describeEnum(user.role),
                      style: TextStyle(
                          color: user.role == Role.NOTCONFIRMED
                              ? Colors.red
                              : null),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.edit,
                        size: 17,
                        color:
                            user.role == Role.NOTCONFIRMED ? Colors.red : null)
                  ])),
            ],
          )
        ],
      )
    ];
  }

  List<Widget> _hasError(AsyncSnapshot<DocumentSnapshot> snapshot) {
    return [
      const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 60,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text('Error: ${snapshot.error}'),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('Stack trace: ${snapshot.stackTrace}'),
      ),
    ];
  }

  List<Widget> _connectionStateNone() {
    return const [
      Icon(
        Icons.info,
        color: Colors.blue,
        size: 60,
      ),
      Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Select a lot'),
      )
    ];
  }

  List<Widget> _connectionStateWaiting() {
    return const [
      SizedBox(
        child: CircularProgressIndicator(),
        width: 60,
        height: 60,
      ),
      Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Awaiting bids...'),
      )
    ];
  }

  List<Widget> _connectionStateDone(AsyncSnapshot<DocumentSnapshot> snapshot) {
    return [
      const Icon(
        Icons.info,
        color: Colors.blue,
        size: 60,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Text(snapshot.data.toString()),
      )
    ];
  }

  Future<void> statusEditDialogWindow(
      BuildContext context, Role? status) async {
    final updateUserStatusInFirebase = (Role newStatus) => FirebaseFirestore
        .instance
        .doc('users/${widget.user.uid}')
        .update({'role': newStatus.index});

    return showDialog(
        context: context,
        builder: (context) {
          Role newStatus = status ?? Role.NOTCONFIRMED;
          return AlertDialog(
            title: Text('Choose New Status'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: Role.values
                      .map((role) => RadioListTile<Role>(
                            title: Text(describeEnum(role)),
                            value: role,
                            groupValue: newStatus,
                            onChanged: (Role? value) {
                              setState(() {
                                newStatus = value != null ? value : newStatus;
                              });
                            },
                          ))
                      .toList(),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  updateUserStatusInFirebase(newStatus)
                      .catchError((e) => print(e))
                      .then((_) => newStatusMessageToUser(newStatus));
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  newStatusMessageToUser(Role newStatus) async {
    var body = '';
    switch (newStatus) {
      case Role.CONFIRMED:
        body = 'New status is confirmed';
        break;

      case Role.ADMIN:
        body = 'New status is admin';
        break;

      case Role.NOTCONFIRMED:
        body = 'New status is not confirmed';
        break;

      default:
        body = 'New status is...';
    }

    final messagingServerAddress =
        await MessagingService.getMessagingServerAddress();

    if (widget.user.messageToken != null && messagingServerAddress != null)
      MessagingService.send(
          token: widget.user.messageToken!,
          serverAddress: messagingServerAddress,
          title: 'Your status has been changed',
          body: body);
  }
}
