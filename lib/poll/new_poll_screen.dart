import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/poll/poll.dart';
import 'package:osbb_test/poll/service/poll_service.dart';
import 'package:osbb_test/poll/widget/new_poll_answers_list.dart';
import 'package:osbb_test/services/messaging_service.dart';
import 'package:osbb_test/widgets/header.dart';
import 'package:uuid/uuid.dart';

import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewPoll extends StatefulWidget {
  const NewPoll({
    Key? key,
  }) : super(key: key);
  @override
  _NewPollState createState() => _NewPollState();
}

class _NewPollState extends State<NewPoll> {
  String? question;
  DateTimeRange? dateRange;
  bool? isValid;
  List<TextEditingController> answers = [TextEditingController()];

  @override
  void dispose() {
    answers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New poll', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.grey[50],
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...questionWidgets(),
              SizedBox(
                height: 20,
              ),
              ...setDateWidget(),
              SizedBox(
                height: 20,
              ),
              // Header(text: AppLocalizations.of(context)!.addYourAnswers),
              NewPollAnswersList(
                answers: answers,
                validationWithSetState: validationWithSetState,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValid == true
                        ? () async {
                            try {
                              final finalAnswers = createCleanAnswers();

                              final newPoll = new Poll(
                                question: question,
                                createdAt: Timestamp.now(),
                                id: Uuid().v1(),
                                dateRange: dateRange,
                                answers: finalAnswers,
                              );

                              setNewPoll(newPoll);
                              sendTopicMessage(question!);
                            } catch (e) {
                              Navigator.pop(context);
                            } finally {
                              Navigator.pop(context);
                            }
                          }
                        : null,
                    child: Text(AppLocalizations.of(context)!.save),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> questionWidgets() {
    return [
      Header(text: AppLocalizations.of(context)!.writeYourQuestion),
      Card(
          child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          onChanged: (val) {
            question = val;
            validationWithSetState();
          },
        ),
      )),
    ];
  }

  List<Widget> setDateWidget() {
    String dateRangeStr(DateTimeRange range) {
      final start = DateFormat('dd/MM/yyyy').format(range.start);
      final end = DateFormat('dd/MM/yyyy').format(range.end);
      return '$start - $end';
    }

    return [
      Header(text: AppLocalizations.of(context)!.setDateRangeOfVoting),
      SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: OutlinedButton(
              onPressed: () {
                showDateRangePicker(
                  initialEntryMode: DatePickerEntryMode.input,
                  context: context,
                  firstDate: DateTime.now().subtract(Duration(days: 30)),
                  lastDate: DateTime.now().add(Duration(days: 30)),
                  initialDateRange: DateTimeRange(
                      start: DateTime.now(),
                      end: DateTime.now().add(Duration(days: 2))),
                ).then((value) {
                  setState(() {
                    if (value != null) dateRange = value;
                    isValid = validation();
                  });
                });
              },
              child: Text(dateRange != null
                  ? dateRangeStr(dateRange!)
                  : AppLocalizations.of(context)!.tapToSetATimeRange),
            ),
          ),
        ),
      )
    ];
  }

  validation() {
    if (question == null) return false;
    if (question!.trim().isEmpty) return false;

    if (dateRange == null) return false;

    if (answers.length == 0) return false;

    final isEmpty = answers.every((element) => element.text.trim().length == 0);

    if (isEmpty) return false;

    return true;
  }

  validationWithSetState() {
    final val = validation();
    if (val != isValid) {
      setState(() {
        isValid = val;
      });
    }
  }

  sendTopicMessage(String question) async {
    var serverAddress = await MessagingService.getMessagingServerAddress();
    if (serverAddress != null)
      MessagingService.topic(
          topic: 'vote',
          serverAddress: serverAddress,
          title: 'It is starting new poll',
          body: question);
  }

  Map<String, dynamic> createCleanAnswers() {
    Map<String, dynamic> finalAnswers = {};
    answers.removeWhere((element) => element.text.trim().length == 0);

    answers.asMap().forEach((key, value) {
      finalAnswers['$key'] = value.text;
    });
    return finalAnswers;
  }

  setNewPoll(Poll newPoll) {
    if (newPoll.id != null && newPoll.answers != null) {
      Map<String, num> votingData = {};
      for (int i = 0; i < newPoll.answers!.length; i++) votingData['$i'] = 0;

      PollService.setNewPoll(newPoll);
      PollService.setVotedUsersData(newPoll.id!, {'array': []});
      PollService.setVotingData(newPoll.id!, votingData);
    }
  }
}
