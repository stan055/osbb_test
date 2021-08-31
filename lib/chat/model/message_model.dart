import 'package:cloud_firestore/cloud_firestore.dart';

class MessageField {
  static final String createdAt = 'createdAt';
  static final String from = 'from';
  static final String message = 'message';
}

class Message {
  final String from;
  final String message;
  final Timestamp createdAt;

  const Message({
    required this.from,
    required this.message,
    required this.createdAt,
  });

  static Message fromJson(Map<String, dynamic> json) => Message(
      from: json['from'] ?? 'from',
      message: json['message'] ?? 'message',
      createdAt: json['createdAt'] ?? Timestamp.now());

  Map<String, dynamic> toJson() => {
        'from': from,
        'message': message,
        'createdAt': Timestamp.now(),
      };
}
