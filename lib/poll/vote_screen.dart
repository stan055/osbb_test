import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/poll/service/poll_service.dart';
import 'package:osbb_test/poll/util.dart';
import 'package:osbb_test/poll/poll.dart';
import 'package:osbb_test/poll/widget/answer_progress_indicator.dart';
import 'package:osbb_test/root_screen.dart';
import 'package:osbb_test/widgets/header.dart';

class VoteScreen extends StatefulWidget {
  VoteScreen({
    Key? key,
    required this.poll,
    required this.appUser,
  }) : super(key: key);
  final Poll poll;
  final AppUser appUser;

  @override
  _VoteScreenState createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  var selectedAnswer;
  bool returnWithRefresh = false;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> voteDataStream;

  @override
  void initState() {
    super.initState();

    if (widget.poll.isVoted == null) checkIsUserAlreadyVotedOnThisPoll();
    initVotingDataStream();
  }

  initVotingDataStream() {
    voteDataStream = FirebaseFirestore.instance
        .doc('polls/${widget.poll.id}/votingData/data')
        .snapshots();
  }

  checkIsUserAlreadyVotedOnThisPoll() {
    PollService.checkIsUserAlreadyVotedOnThisPoll(
            widget.poll.id, widget.appUser.uid)
        .then((value) => setState(() {
              widget.poll.isVoted = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        iconTheme: IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            returnWithRefresh == true
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RootScreen(
                              title: 'Root Screen',
                              appUser: widget.appUser,
                            )),
                  )
                : Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (votePermission(widget.appUser.role) == false)
                errorCaption(widget.appUser.role),
              ListTile(
                title: Center(
                    child: Header(
                  text: '${widget.poll.question}',
                  headline: 5,
                )),
                subtitle: Center(
                  child: Text(
                    widget.poll.isVoted == true
                        ? 'You have already voted on this question'
                        : 'Choose your answer from below',
                    style:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 16.0),
                  ),
                ),
              ),
              answerCardStream(),
              widget.poll.isVoted == false ? saveButton() : SizedBox(),
            ],
          )),
    );
  }

  Widget answerCardStream() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: voteDataStream,
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasError) {
            children = <Widget>[
              Text('Error: ${snapshot.error}'),
            ];
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                children = const <Widget>[Text('Connection state none')];
                break;
              case ConnectionState.waiting:
                children = const <Widget>[Text('Awaiting bids...')];
                break;
              case ConnectionState.active:
              case ConnectionState.done:
                if (widget.poll.answers != null)
                  children = widget.poll.answers!.entries.map((answer) {
                    Map<String, dynamic> votingData = {};
                    num votingValue = 0;
                    try {
                      votingData = snapshot.data!.data()!['data'];
                      votingValue = votingData[answer.key];
                    } catch (e) {
                      print(e);
                    }
                    return AnswerProgressIndicator(
                      progressValue: progressValue(votingData, votingValue),
                      onTap: () => setState(() => selectedAnswer = answer.key),
                      isSelected: selectedAnswer == answer.key,
                      height: 80,
                      radius: 12.0,
                      child: Row(
                        children: [
                          Header(text: '${answer.value}'),
                          if (widget.poll.isVoted == true)
                            Header(text: '  [$votingValue]')
                        ],
                      ),
                    );
                  }).toList();
                break;
            }
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          );
        });
  }

  Widget saveButton() {
    final onPressedButtonIsValid =
        selectedAnswer == null || votePermission(widget.appUser.role) == false
            ? false
            : true;

    final snackBarShowMessage = (message) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));

    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: onPressedButtonIsValid
                ? () async {
                    PollService.incrementSelectedAnswerInVotingData(
                            widget.poll.id, selectedAnswer)
                        .catchError((_) => snackBarShowMessage(
                            'Error! Failed increment answer value :('));

                    PollService.addUserToVotedUsers(
                            widget.poll.id, widget.appUser.uid)
                        .catchError((_) => snackBarShowMessage(
                            'Error! Failed add user to voted users'));

                    setState(() {
                      returnWithRefresh = true;
                      widget.poll.isVoted = true;
                      selectedAnswer = null;
                    });
                  }
                : null,
            child: Text('Vote')));
  }

  Widget errorCaption(Role role) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Header(
          text: 'You don\'t have permissions to vote!',
          color: Colors.redAccent,
        ),
      ),
    );
  }
}
