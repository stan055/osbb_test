import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:osbb_test/poll/poll.dart';

class PollService extends ChangeNotifier {
  StreamSubscription<QuerySnapshot>? _pollsSubscription;
  List<Poll> _polls = [];

  bool isPollsSubscriptionIsNull() => _pollsSubscription == null ? true : false;
  List<Poll> get polls => _polls;

  addPollsSubscription() async {
    _pollsSubscription = FirebaseFirestore.instance
        .collection('polls')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _polls = [];
      snapshot.docs.forEach((document) {
        _polls.add(
          Poll.fromJson(document.data()),
        );
      });
      notifyListeners();
    });
  }

  void unsibscribe() {
    if (!isPollsSubscriptionIsNull()) {
      _pollsSubscription!.cancel();
      _pollsSubscription = null;
      _polls.clear();
    }
  }

  static Future<bool> checkIsUserAlreadyVotedOnThisPoll(
      String? pollId, String? userUid) {
    return FirebaseFirestore.instance
        .collection('polls/$pollId/votedUsers/')
        .where('array', arrayContains: userUid)
        .get()
        .then((value) => value.docs.isNotEmpty);
  }

  Future<Map<String, num>?> getAnswersValue(String? id) async {
    if (id == null) throw Exception('Get answers value id eaqual null');

    return FirebaseFirestore.instance
        .collection('polls/$id/answers')
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        Map<String, num> answersValue = {};
        snapshot.docs.forEach((element) {
          final data = element.data();
          if (data.isNotEmpty) {
            answersValue[element.id] = data['value'];
          }
        });
        return answersValue;
      }
      return null;
    });
  }

  static Future setNewPoll(Poll poll) {
    return FirebaseFirestore.instance.doc('polls/${poll.id}').set(poll.toMap());
  }

  static Future setVotingData(String id, Map<String, num> data) {
    return FirebaseFirestore.instance
        .doc('polls/$id/votingData/data')
        .set({'data': data});
  }

  static Future setVotedUsersData(String id, Map<String, dynamic> data) {
    return FirebaseFirestore.instance
        .doc('polls/$id/votedUsers/users')
        .set(data);
  }

  static Future deletePoll(String id) {
    return FirebaseFirestore.instance.collection('polls').doc(id).delete();
  }

  static Future deleteVotingData(String id) {
    return FirebaseFirestore.instance.doc('polls/$id/votingData/data').delete();
  }

  static Future deleteVotedUsers(String id) {
    return FirebaseFirestore.instance
        .doc('polls/$id/votedUsers/users')
        .delete();
  }

  static Future addUserToVotedUsers(pollId, userId) {
    return FirebaseFirestore.instance
        .doc('polls/$pollId/votedUsers/users')
        .update({
      'array': FieldValue.arrayUnion([userId])
    });
  }

  static Future incrementSelectedAnswerInVotingData(pollId, selectedAnswer) {
    return FirebaseFirestore.instance
        .doc('polls/$pollId/votingData/data')
        .update({'data.$selectedAnswer': FieldValue.increment(1)});
  }
}
