import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:osbb_test/fb_feed/service/fb_feed_service.dart';
import 'package:osbb_test/poll/service/poll_service.dart';
import 'package:osbb_test/services/local_notification_service.dart';
import 'package:osbb_test/sign_up/root_sign_up.dart';
import 'package:osbb_test/services/app_state_service.dart';
import 'package:osbb_test/root_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:osbb_test/models/app_state_enum.dart';
import 'package:osbb_test/chat/service/users_and_chat_service.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  LocalNotificationService.display(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AppStateService(),
      ),
      ChangeNotifierProvider(
        create: (context) => UsersAndChatService(),
      ),
      ChangeNotifierProvider(
        create: (context) => PollService(),
      ),
      Provider(
          create: (_) => FbFeedService(
                pageId: '766121410469143',
                accessToken:
                    'EAAFIKiiBhA8BAK92nJqsgOnfysqRSYy8DtS8NKucxmajZAXwHVHpmCPU4RGZAHJtZBnV1i2zCZBZAX4K15v5EEGsU1GZCp3rM0Psmt8i3i6BTxnHaf6MyUy4Pz8JTFOZAoIdTBCWdUBpSg60OmkZCDOF2pR7amG28NUZA9l6UPykq9UCAwO8416mI',
              ))
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    LocalNotificationService.initialize();

    FirebaseMessaging.instance.getInitialMessage().then((message) {});

    ///foreground
    FirebaseMessaging.onMessage.listen((message) {
      var blockNotification = context
          .read<UsersAndChatService>()
          .blockNotificationMessageFrom
          .contains(message.data['owner']);
      if (message.notification != null && blockNotification == false)
        LocalNotificationService.display(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Osbb App',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', ''), Locale('uk', ''), Locale('ru', '')],
      // theme: buildAppTheme(),
      home: Consumer<AppStateService>(builder: (context, appState, _) {
        return appState.loginState == ApplicationStateEnum.LOGGEDIN
            ? RootScreen(
                title: 'Osbb app',
                appUser: appState.appUser,
              )
            : SignUpRoot(
                appState: appState.loginState,
              );
      }),

      debugShowCheckedModeBanner: false,
    );
  }
}
