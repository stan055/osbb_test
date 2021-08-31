import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Poll {
  String? id;
  Timestamp? createdAt;
  String? question;
  DateTimeRange? dateRange;
  Map<String, dynamic>? answers;
  bool? isVoted;
  Stream<Map<String, dynamic>?>? votingDataStream;

  Poll({this.question, this.dateRange, this.answers, this.id, this.createdAt});

  String toString() {
    if (this.isVailid()) {
      return 'Id: ${id.toString()} \n Question: ${this.question} \n DateRange: ${this.dateRange.toString()} \n Answers: ${this.answers.toString()}';
    }
    return 'Object is not valid';
  }

  bool isVailid() {
    if (question != null && dateRange != null && answers != null) {
      if (question!.isNotEmpty && answers!.isNotEmpty) return true;
    }
    return false;
  }

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
        id: json['id'],
        createdAt: json['createdAt'] ?? null,
        question: json['question'],
        dateRange: DateTimeRange(
            start:
                DateTime.fromMillisecondsSinceEpoch(json['dateRange']['start']),
            end: DateTime.fromMillisecondsSinceEpoch(
                (json['dateRange']['end']))),
        answers: json['answers']);
  }

  Map<String, dynamic> toMap() {
    var pollMapped = {
      'id': id,
      'question': question,
      'dateRange': {
        'start': dateRange!.start.millisecondsSinceEpoch,
        'end': dateRange!.end.millisecondsSinceEpoch
      },
      'answers': answers,
      'createdAt': createdAt,
    };

    return pollMapped;
  }

  String dateRangeShortString() {
    String result = '././.';
    if (dateRange != null) {
      try {
        result =
            '${dateRange!.start.day}.${dateRange!.start.month}.${dateRange!.start.year}' +
                ' - ' +
                '${dateRange!.end.day}.${dateRange!.end.month}.${dateRange!.end.year}';
      } catch (error) {
        print(error);
      }
    }
    return result;
  }
}
