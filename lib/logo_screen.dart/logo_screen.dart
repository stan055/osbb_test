import 'package:flutter/material.dart';

class LogoScreen extends StatelessWidget {
  const LogoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(Colors.grey.shade50, BlendMode.modulate),
      child: Image.asset(
        'assets/images/house.jpg',
      ),
    );
  }
}
