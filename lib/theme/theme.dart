import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
      brightness: Brightness.light,
      accentColor: Colors.grey,
      primaryColor: Colors.grey[100],
      buttonColor: Colors.grey[200],
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
          backgroundColor: Colors.blueGrey[50],
          foregroundColor: Colors.black87),
      scaffoldBackgroundColor: Colors.grey[50],
      backgroundColor: Colors.amber[700],
      textTheme: _appTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(
          // color: Colors.grey[300],
          iconTheme: base.iconTheme.copyWith(color: Colors.grey[900]),
          textTheme: _appTextTheme(base.textTheme)),
      iconTheme: base.iconTheme.copyWith(color: Colors.black87),
      buttonTheme: base.buttonTheme.copyWith(buttonColor: Colors.black38));
}

TextTheme _appTextTheme(TextTheme base) {
  var copyWith = base.headline5!.copyWith(
      fontWeight: FontWeight.w500,
      color: Colors.grey,
      backgroundColor: Colors.grey);

  return base
      .copyWith(
          headline1: copyWith,
          headline2: copyWith,
          headline3: copyWith,
          headline4: copyWith,
          headline5: copyWith,
          subtitle1: copyWith,
          subtitle2: copyWith,
          bodyText1: copyWith,
          overline: copyWith,
          headline6: base.headline5?.copyWith(
            fontSize: 18.0,
            color: Colors.black,
          ),
          caption: base.caption!.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
            color: Colors.grey,
          ),
          button: base.button?.copyWith(
              //fontSize: 23.9,
              ),
          bodyText2: base.bodyText2?.copyWith(
            fontSize: 16.9,
            fontFamily: "Lobster",
            color: Colors.black,
          ))
      .apply(
        fontFamily: "Lobster",
        displayColor: Colors.grey,
        // bodyColor: Colors.green[100]
      );
}
