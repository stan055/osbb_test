import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/poll/poll.dart';
import 'package:osbb_test/poll/service/poll_service.dart';
import 'package:osbb_test/poll/util.dart';
import 'package:osbb_test/poll/widget/answer_progress_indicator.dart';

class StreamingVotingChart extends StatefulWidget {
  const StreamingVotingChart({
    Key? key,
    required this.poll,
    required this.userUid,
  }) : super(key: key);
  final Poll poll;
  final String userUid;

  @override
  _StreamingVotingChartState createState() => _StreamingVotingChartState();
}

class _StreamingVotingChartState extends State<StreamingVotingChart> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> voteDataStream;

  @override
  void initState() {
    if (widget.poll.isVoted == null) checkIsUserAlreadyVotedOnThisPoll();
    initVotingDataStream();
    super.initState();
  }

  initVotingDataStream() {
    voteDataStream = FirebaseFirestore.instance
        .doc('polls/${widget.poll.id}/votingData/data')
        .snapshots();
  }

  checkIsUserAlreadyVotedOnThisPoll() {
    PollService.checkIsUserAlreadyVotedOnThisPoll(
            widget.poll.id, widget.userUid)
        .then((value) => setState(() {
              widget.poll.isVoted = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return widget.poll.isVoted == false || widget.poll.isVoted == null
        ? SizedBox()
        : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: voteDataStream,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
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
                          height: 30,
                          radius: 3.0,
                          child: Text('${answer.value}  [$votingValue]'),
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
}
