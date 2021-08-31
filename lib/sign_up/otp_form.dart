import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:osbb_test/services/messaging_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:osbb_test/services/app_state_service.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:osbb_test/widgets/header.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OtpForm extends StatefulWidget {
  final Function loadingState;
  final Function phoneState;
  final Function otpState;
  final Function userInfoState;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  OtpForm(
      {Key? key,
      required this.loadingState,
      required this.phoneState,
      required this.otpState,
      required this.userInfoState,
      required this.scaffoldMessengerKey})
      : super(key: key);

  @override
  _OtpFormState createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final _otpController = TextEditingController();
  var _buttonOpasity = 0.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Header(text: AppLocalizations.of(context)!.pleaseEnterCodeFromSms),
        SizedBox(
          height: 40.0,
        ),
        _pinCodeTextField(),
        SizedBox(
          height: 30.0,
        ),
        _elevatedButton(),
      ],
    );
  }

  Widget _pinCodeTextField() {
    return PinCodeTextField(
      appContext: context,
      length: 6,
      obscureText: false,
      animationType: AnimationType.fade,
      showCursor: false,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Colors.white,
        activeColor: Colors.grey.shade500,
        selectedColor: Colors.grey.shade700,
        inactiveColor: Colors.grey.shade400,
      ),
      controller: _otpController,
      onCompleted: (v) {
        setState(() {
          _buttonOpasity = 1.0;
        });
      },
      onChanged: (value) {
        if (_otpController.text.length < 6) {
          setState(() {
            _buttonOpasity = .0;
          });
        }
      },
    );
  }

  Widget _elevatedButton() {
    return SizedBox(
      width: double.maxFinite,
      child: AnimatedOpacity(
        opacity: _buttonOpasity,
        duration: Duration(milliseconds: 300),
        child: ElevatedButton(
            onPressed: () async {
              if (_buttonOpasity != 0) {
                PhoneAuthCredential? credential = context
                    .read<AppStateService>()
                    .createPhoneCredential(_otpController.text);
                if (credential != null) {
                  widget.loadingState();
                  try {
                    final appService = context.read<AppStateService>();

                    await appService.signInWithPhoneAuthCredential(credential);
                    MessagingService.subscribeTo('vote');
                    updateMessageToken(await MessagingService.getToken(),
                        appService.currentUser);
                    widget.userInfoState();
                  } on FirebaseAuthException catch (e) {
                    widget.phoneState();
                    _showSnackBar(e.message.toString());
                  }
                } else {
                  _showSnackBar('Credential is null!');
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.next)),
      ),
    );
  }

  void _showSnackBar(String text) {
    widget.scaffoldMessengerKey.currentState!
        .showSnackBar(SnackBar(content: Text(text)));
  }

  updateMessageToken(String? token, User? currentUser) {
    if (token == null) throw Exception('Error token equal null');
    if (currentUser != null)
      FirebaseFirestore.instance
          .doc('users/${currentUser.uid}')
          .update({'messageToken': token}).catchError((e) => print(e));
  }
}
