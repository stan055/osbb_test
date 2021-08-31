import 'package:cloud_firestore/cloud_firestore.dart';

enum Role { CONFIRMED, NOTCONFIRMED, BANED, ADMIN }

class AppUser {
  String? uid;
  String phoneNumber;
  String firstName;
  String lastName;
  String roomNumber;
  String urlAvatar;
  Role role;
  Timestamp? lastMessageTime;
  Timestamp? lastOpenTime;
  Timestamp? lastSeenTime;
  Timestamp? createdTime;
  String? messageToken;

  AppUser(
      {this.uid,
      this.phoneNumber = '',
      this.firstName = '',
      this.lastName = '',
      this.roomNumber = '',
      this.urlAvatar = '',
      this.role = Role.NOTCONFIRMED,
      this.lastMessageTime,
      this.lastOpenTime,
      this.lastSeenTime,
      this.createdTime,
      this.messageToken});

  static AppUser fromJson(Map<String, dynamic> json) => AppUser(
        uid: json['uid'] ?? null,
        phoneNumber: json['phoneNumber'] ?? '_',
        firstName: json['firstName'] ?? 'nofirstname',
        lastName: json['lastName'] ?? 'nolastname',
        roomNumber: json['roomNumber'] ?? '_',
        urlAvatar: json['urlAvatar'] ?? '',
        role: Role.values[json['role'] ?? Role.NOTCONFIRMED.index],
        lastMessageTime: json['lastMessageTime'] ?? null,
        lastOpenTime: json['lastOpenTime'] ?? null,
        lastSeenTime: json['lastSeenTime'] ?? null,
        createdTime: json['createdTime'] ?? null,
        messageToken: json['messageToken'] ?? null,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'roomNumber': roomNumber,
        'urlAvatar': urlAvatar,
        'role': role.index,
        'lastMessageTime': lastMessageTime,
        'lastOpenTime': lastOpenTime,
        'lastSeenTime': lastSeenTime,
        'createdTime': createdTime,
        'messageToken': messageToken,
      };

  static DateTime? toDateTime(Timestamp? value) {
    if (value == null) return null;

    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime? date) {
    if (date == null) return null;

    return date.toUtc();
  }

  AppUser copyWith(
          {String? uid,
          String? phoneNumber,
          String? firstName,
          String? lastName,
          String? roomNumber,
          String? urlAvatar,
          Role? role,
          Timestamp? lastMessageTime,
          Timestamp? lastOpenTime,
          Timestamp? lastSeenTime,
          Timestamp? createdTime,
          String? messageToken}) =>
      AppUser(
          uid: uid ?? this.uid,
          phoneNumber: phoneNumber ?? this.phoneNumber,
          firstName: firstName ?? this.firstName,
          lastName: lastName ?? this.lastName,
          roomNumber: roomNumber ?? this.roomNumber,
          urlAvatar: urlAvatar ?? this.urlAvatar,
          role: role ?? this.role,
          lastMessageTime: lastMessageTime ?? this.lastMessageTime,
          lastOpenTime: lastOpenTime ?? this.lastOpenTime,
          lastSeenTime: lastSeenTime ?? this.lastSeenTime,
          createdTime: createdTime ?? this.createdTime,
          messageToken: messageToken ?? this.messageToken);

  @override
  String toString() {
    return toJson().toString();
  }
}
