import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoggedOut extends StatelessWidget {
  const LoggedOut({Key? key, required this.phoneState}) : super(key: key);
  final int opasityDuration = 300;
  final Function phoneState;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.grey.shade50, BlendMode.modulate),
        child: Image.asset(
          'assets/images/house.jpg',
        ),
      ),
      SizedBox(
        width: double.maxFinite,
        child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: opasityDuration),
            child: ElevatedButton(
                onPressed: () => phoneState(),
                child: Text(AppLocalizations.of(context)!.signIn))),
      )
    ]);
  }
}
