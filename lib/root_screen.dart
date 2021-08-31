import 'package:flutter/material.dart';
import 'package:osbb_test/fb_feed/screen/fb_feed.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/poll/poll_list_screen.dart';
import 'package:osbb_test/user_info_screen/user_info_screen.dart';
import 'package:osbb_test/chat/chat_root.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RootScreen extends StatefulWidget {
  RootScreen({Key? key, required this.title, required this.appUser})
      : super(key: key);
  final AppUser? appUser;
  final String title;

  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  var _tabController = 0;
  late List<Widget> screensTab;

  @override
  void initState() {
    screensTab = [
      FbFeed(),
      ChatRoot(
        appUser: widget.appUser,
      ),
      PollList(
        appUser: widget.appUser,
      ),
    ];
    super.initState();
  }

  void onTabTapped(int index) {
    setState(() {
      _tabController = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.grey[50],
          leading: new Icon(
            Icons.home_outlined,
            color: Colors.black87,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Person',
              color: Colors.black87,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        ),
        body: screensTab[_tabController],
        bottomNavigationBar: _bottomNavigationBar(_tabController));
  }

  Widget _bottomNavigationBar(int _index) {
    return BottomNavigationBar(
      onTap: onTabTapped,
      currentIndex: _index,
      selectedItemColor: Colors.grey[800],
      unselectedItemColor: Colors.grey[700],
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: new Icon(Icons.home_outlined),
          label: AppLocalizations.of(context)!.home,
        ),
        BottomNavigationBarItem(
          icon: new Icon(Icons.support_agent_outlined),
          label: AppLocalizations.of(context)!.support,
        ),
        BottomNavigationBarItem(
          icon: new Icon(Icons.how_to_vote_outlined),
          label: AppLocalizations.of(context)!.polls,
        ),
      ],
    );
  }
}
