import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class MessagingService {
  static Future<String?> getToken() {
    return FirebaseMessaging.instance.getToken();
  }

  static Future subscribeTo(String topic) {
    return FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future unsubscribeFrom(String topic) {
    return FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  static Future<String?> getMessagingServerAddress() {
    return FirebaseFirestore.instance
        .doc('utils/messaging-server-address')
        .get()
        .then((snapshot) {
      String? address;
      if (snapshot.exists) {
        try {
          address = snapshot.get(FieldPath(['value']));
        } on StateError catch (e) {
          print('No nested field exists!');
        }
      }
      return address;
    });
  }

  static Future sendMulticast(
      {String? serverAddress,
      List<String>? tokens,
      required String title,
      required String body}) {
    var message = jsonEncode({
      'notification': {'title': title, 'body': body},
      'tokens': tokens
    });

    final address = '${serverAddress}sendMulticast';
    return sendPost(address, message);
  }

  static Future<http.Response> send(
      {required String token,
      required String serverAddress,
      required String title,
      required String body}) {
    final message = jsonEncode({
      'notification': {'title': title, 'body': body},
      'token': token,
    });

    final address = '${serverAddress}send';
    return sendPost(address, message);
  }

  static Future<http.Response> topic(
      {required String topic,
      required String serverAddress,
      required String title,
      required String body}) {
    final message = jsonEncode({
      'notification': {'title': title, 'body': body},
      'topic': topic
    });

    final address = '${serverAddress}send';
    return sendPost(address, message);
  }

  static Future<http.Response> sendToDevice(
      {required String serverAddress,
      required List<String?> tokens,
      required String title,
      required String body,
      String? ownerUid}) {
    var message = jsonEncode({
      'tokens': tokens,
      'message': {
        'notification': {'title': title, 'body': body},
        if (ownerUid != null) 'data': {'owner': ownerUid}
      }
    });

    final address = '${serverAddress}sendToDevice';
    return sendPost(address, message);
  }

  static Future<http.Response> sendPost(String address, String message) {
    return http.post(
      Uri.parse(address),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: message,
    );
  }
}
