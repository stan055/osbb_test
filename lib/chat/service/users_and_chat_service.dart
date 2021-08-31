import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/chat/model/message_model.dart';

const MESSAGE_MAX_COUNT = 100;

class UsersAndChatService extends ChangeNotifier {
  StreamSubscription<QuerySnapshot>? _chatMessagesSubscription;
  String? _chatMessagesUid;
  List<Message> _chatMessages = [];

  StreamSubscription<QuerySnapshot>? _usersSubscription;
  List<AppUser> _users = [];

  bool isChatSubscriptionIsNull() =>
      _chatMessagesSubscription == null ? true : false;
  List<Message> get chatMessages => _chatMessages;
  String? get chatMessagesUid => _chatMessagesUid;

  bool isUsersSubscriptionIsNull() => _usersSubscription == null ? true : false;
  List<AppUser> get users => _users;

  List<String> blockNotificationMessageFrom = [];
  List<String> adminsUid = [];
  List<String> adminsToken = [];
  String? messagingServerAddress;

  UsersAndChatService() {
    init();
  }

  Future<void> init() async {}

  addChatMessagesSubscription(String uid) async {
    _chatMessagesUid = uid;

    maxMessagesDelete(uid);

    _chatMessagesSubscription = FirebaseFirestore.instance
        .collection('users/$uid/messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _chatMessages = [];

      snapshot.docs.forEach((document) {
        _chatMessages.add(
          Message.fromJson(document.data()),
        );
      });
      notifyListeners();
    });
  }

  maxMessagesDelete(String uid) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users/$uid/messages')
        .orderBy('createdAt', descending: true)
        .get();

    if (snapshot.size > MESSAGE_MAX_COUNT) {
      final deleteCount = snapshot.size / 3;
      for (int i = 1; i < deleteCount; i++) {
        if (snapshot.docs[snapshot.size - i].exists)
          snapshot.docs[snapshot.size - i].reference.delete();
      }
    }
  }

  Future<void>? unsibscribeChat() {
    if (!isChatSubscriptionIsNull()) {
      return _chatMessagesSubscription!.cancel().then((_) {
        _chatMessagesSubscription = null;
        _chatMessages.clear();
        _chatMessagesUid = null;
      });
    }
  }

  void unsibscribeUsers() {
    if (!isUsersSubscriptionIsNull()) {
      _usersSubscription!.cancel().then((_) => _usersSubscription = null);
      _users.clear();
    }
  }

  addUsersSubscription() {
    _usersSubscription = FirebaseFirestore.instance
        .collection('users')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen((snapshot) {
      _users = [];
      snapshot.docs.forEach((document) {
        _users.add(
          AppUser.fromJson(document.data()),
        );
      });
      notifyListeners();
    });
  }

  static updateLastMessageTimeField(userUid) {
    return FirebaseFirestore.instance
        .doc('users/$userUid')
        .update({'lastMessageTime': DateTime.now()});
  }

  static updateLastSeenTimeField(userUid) {
    return FirebaseFirestore.instance
        .doc('users/$userUid')
        .update({'lastSeenTime': DateTime.now()});
  }

  static writeMessageToDatabase(userUid, message) {
    return FirebaseFirestore.instance
        .collection('users/$userUid/messages')
        .add(message);
  }

  static Future<List<dynamic>> getListByWhereIsEqualToValueAndNestedByFieldPath(
      String collection,
      String whereField,
      dynamic whereValue,
      String fieldPath) {
    return FirebaseFirestore.instance
        .collection(collection)
        .where(whereField, isEqualTo: whereValue)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      List<dynamic> data = [];
      querySnapshot.docs.forEach((documentSnapshot) {
        if (documentSnapshot.exists) {
          try {
            dynamic nested = documentSnapshot.get(FieldPath([fieldPath]));
            data.add(nested);
          } on StateError catch (e) {
            print('No nested field exists!');
          }
        }
      });
      return data;
    });
  }
}
