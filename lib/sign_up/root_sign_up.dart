import 'package:flutter/material.dart';
import 'package:osbb_test/loggedout_screen.dart/loggedout_screen.dart';
import 'package:osbb_test/logo_screen.dart/logo_screen.dart';
import 'package:osbb_test/sign_up/phone_screen.dart';
import 'package:osbb_test/sign_up/otp_form.dart';
import 'package:osbb_test/sign_up/user_info_form.dart';
import 'package:osbb_test/models/app_state_enum.dart';

class SignUpRoot extends StatefulWidget {
  SignUpRoot({Key? key, required this.appState}) : super(key: key);
  final ApplicationStateEnum appState;

  @override
  _SignUpRootState createState() => _SignUpRootState();
}

class _SignUpRootState extends State<SignUpRoot> {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  ApplicationStateEnum? appState;

  @override
  void didUpdateWidget(covariant SignUpRoot oldWidget) {
    appState = widget.appState;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    appState = widget.appState;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
          body: Center(
        child: SingleChildScrollView(
          child: Container(
              constraints: BoxConstraints(minWidth: 100, maxWidth: 300),
              child: _currentWidget(context)),
        ),
      )),
    );
  }

  Widget? _currentWidget(BuildContext context) {
    switch (appState) {
      case (ApplicationStateEnum.MOBILE_FORM):
        return _mobileForm();

      case (ApplicationStateEnum.OTP_FORM):
        return _otpForm();

      case (ApplicationStateEnum.LOADING):
        return Center(child: CircularProgressIndicator());

      case (ApplicationStateEnum.USER_INFO_FORM):
        return UserInfoForm();

      case (ApplicationStateEnum.LOGGEDIN):
        return _mobileForm();

      case (ApplicationStateEnum.LOGGEDOUT):
        return LoggedOut(
          phoneState: () => setState(() {
            appState = ApplicationStateEnum.MOBILE_FORM;
          }),
        );

      case (ApplicationStateEnum.LOGO):
        return LogoScreen();

      default:
        return _mobileForm();
    }
  }

  Widget _mobileForm() {
    return PhoneForm(
      scaffoldMessengerKey: scaffoldMessengerKey,
      loadingState: () => setState(() {
        appState = ApplicationStateEnum.LOADING;
      }),
      phoneState: () => setState(() {
        appState = ApplicationStateEnum.MOBILE_FORM;
      }),
      otpState: () => setState(() {
        appState = ApplicationStateEnum.OTP_FORM;
      }),
      userInfoState: () => setState(() {
        appState = ApplicationStateEnum.USER_INFO_FORM;
      }),
    );
  }

  Widget _otpForm() {
    return OtpForm(
      scaffoldMessengerKey: scaffoldMessengerKey,
      loadingState: () => setState(() {
        appState = ApplicationStateEnum.LOADING;
      }),
      phoneState: () => setState(() {
        appState = ApplicationStateEnum.MOBILE_FORM;
      }),
      otpState: () => setState(() {
        appState = ApplicationStateEnum.OTP_FORM;
      }),
      userInfoState: () => setState(() {
        appState = ApplicationStateEnum.USER_INFO_FORM;
      }),
    );
  }
}
