import 'package:flutter/material.dart';

class NewPollAnswersList extends StatefulWidget {
  NewPollAnswersList(
      {Key? key, required this.answers, required this.validationWithSetState})
      : super(key: key);
  final List<TextEditingController> answers;
  final Function validationWithSetState;

  @override
  _NewPollAnswersListState createState() => _NewPollAnswersListState();
}

class _NewPollAnswersListState extends State<NewPollAnswersList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.answers.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: ListTile(
                contentPadding: EdgeInsets.all(13),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      widget.answers.removeAt(index);
                    });
                    widget.validationWithSetState();
                  },
                ),
                subtitle: TextField(
                  controller: widget.answers[index],
                  onChanged: (val) => widget.validationWithSetState(),
                ),
              ),
            );
          },
        ),
        ListTile(
            contentPadding: EdgeInsets.all(13),
            trailing: ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.answers.add(TextEditingController());
                });
                widget.validationWithSetState();
              },
              child: Icon(
                Icons.add,
                color: Colors.grey,
                size: 30,
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: CircleBorder(
                    side: BorderSide(width: 2, color: Colors.grey)),
                primary: Colors.white, // <-- Button color
              ),
            )),
      ],
    );
  }
}
