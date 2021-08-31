import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  Header({Key? key, required this.text, this.color, this.headline})
      : super(key: key);
  final String text;
  final Color? color;
  final int? headline;

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    switch (headline) {
      case 4:
        style = Theme.of(context).textTheme.headline4!.copyWith(color: color);
        break;
      case 5:
        style = Theme.of(context).textTheme.headline5!.copyWith(color: color);
        break;
      case 6:
        style = Theme.of(context).textTheme.headline6!.copyWith(color: color);
        break;
      default:
        style = Theme.of(context).textTheme.headline6!.copyWith(color: color);
    }
    return Text(
      text,
      style: style,
    );
  }
}
