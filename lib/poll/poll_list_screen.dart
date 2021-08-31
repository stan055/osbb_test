import 'package:flutter/material.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/poll/new_poll_screen.dart';
import 'package:osbb_test/poll/poll.dart';
import 'package:osbb_test/poll/service/poll_service.dart';
import 'package:osbb_test/poll/vote_screen.dart';
import 'package:osbb_test/poll/widget/streaming_voting_chart.dart';
import 'package:osbb_test/widgets/header.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PollList extends StatefulWidget {
  const PollList({Key? key, required this.appUser}) : super(key: key);
  final AppUser? appUser;

  @override
  _PollListState createState() => _PollListState();
}

class _PollListState extends State<PollList> {
  late AppUser appUser;

  @override
  void initState() {
    super.initState();

    if (widget.appUser != null) {
      appUser = widget.appUser!;
    } else {
      appUser = AppUser();
    }
    if (context.read<PollService>().isPollsSubscriptionIsNull())
      context.read<PollService>().addPollsSubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollService>(builder: (context, pollService, _) {
      return Stack(
        children: [
          ListView.builder(
              itemCount: pollService.polls.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    title: title(pollService.polls[index].dateRange),
                    trailing: deleteButton(pollService.polls[index].id),
                    onTap:
                        isVotingDone(pollService.polls[index].dateRange) == true
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => VoteScreen(
                                            poll: pollService.polls[index],
                                            appUser: appUser,
                                          )),
                                );
                              },
                    subtitle: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Header(
                            text: '${pollService.polls[index].question}',
                            headline: 6,
                          ),
                          voteChart(pollService.polls[index])
                        ],
                      ),
                    ),
                  ),
                );
              }),
          if (appUser.role == Role.ADMIN) addNewPollButton(pollService)
        ],
      );
    });
  }

  Widget addNewPollButton(PollService pollService) {
    return Positioned(
      right: 15,
      bottom: 15,
      child: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.black87,
          ),
          backgroundColor: Colors.grey.shade100,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => NewPoll()));
          }),
    );
  }

  Widget voteChart(Poll poll) {
    if (isVotingDone(poll.dateRange)) poll.isVoted = true;

    return StreamingVotingChart(poll: poll, userUid: widget.appUser!.uid!);
  }

  Widget deleteButton(String? pollId) {
    return appUser.role == Role.ADMIN
        ? IconButton(
            onPressed: () {
              showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  context: context,
                  builder: (context) {
                    return Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Header(text: 'Delete this vote?'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('No')),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: OutlinedButton(
                                    onPressed: () async {
                                      if (pollId == null) return;
                                      await PollService.deleteVotingData(pollId)
                                          .catchError((e) => print(e));
                                      await PollService.deleteVotedUsers(pollId)
                                          .catchError((e) => print(e));
                                      await PollService.deletePoll(pollId)
                                          .catchError((e) => print(e));

                                      Navigator.pop(context);
                                    },
                                    child: Text('Yes')),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  });
            },
            icon: Icon(Icons.delete))
        : Icon(Icons.navigate_next_outlined);
  }

  Widget title(DateTimeRange? dateRange) {
    if (dateRange == null) return SizedBox();

    final start = DateFormat('dd/MM/yyyy').format(dateRange.start);
    final end = DateFormat('dd/MM/yyyy').format(dateRange.end);

    return isVotingDone(dateRange)
        ? Text('Voting is Done')
        : Text('Time of vote:  $start - $end');
  }

  bool isVotingDone(DateTimeRange? dateRange) {
    if (dateRange == null) return false;
    return DateTime.now().millisecondsSinceEpoch >
        dateRange.end.millisecondsSinceEpoch;
  }
}
