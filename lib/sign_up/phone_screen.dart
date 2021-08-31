import 'package:flutter/material.dart';
import 'package:osbb_test/widgets/header.dart';
import 'package:osbb_test/services/app_state_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneForm extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final Function loadingState;
  final Function phoneState;
  final Function otpState;
  final Function userInfoState;
  PhoneForm(
      {Key? key,
      required this.scaffoldMessengerKey,
      required this.loadingState,
      required this.phoneState,
      required this.otpState,
      required this.userInfoState})
      : super(key: key);

  @override
  _PhoneFormState createState() => _PhoneFormState();
}

class _PhoneFormState extends State<PhoneForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _opasityDuration = 300;
  var _buttonOpasity = 0.0;
  final _regExp = RegExp(r"^\+?3?8?(0[5-9][0-9]\d{7})$");

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Header(
              text: AppLocalizations.of(context)!.pleaseEnterYourPhoneNumber),
          SizedBox(
            height: 40.0,
          ),
          _phoneTextField(),
          SizedBox(
            height: 30.0,
          ),
          _elevatedButton()
        ],
      ),
    );
  }

  Widget _phoneTextField() {
    return TextFormField(
      onChanged: (value) {
        _validate(value);
      },
      autovalidateMode: AutovalidateMode.disabled,
      controller: _phoneController,
      autofocus: true,
      decoration: const InputDecoration(
        icon: Text(
          '+38 ',
          style: TextStyle(fontSize: 23),
        ),
      ),
      style: new TextStyle(fontWeight: FontWeight.normal, fontSize: 23),
      validator: (String? value) {
        return validator(value, _regExp);
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _elevatedButton() {
    return SizedBox(
      width: double.maxFinite,
      child: AnimatedOpacity(
        opacity: _buttonOpasity,
        duration: Duration(milliseconds: _opasityDuration),
        child: ElevatedButton(
            onPressed: () {
              if (_buttonOpasity != 0) {
                widget.loadingState();

                context.read<AppStateService>().verifyPhoneNumber(
                    phoneNumber: '+38${_phoneController.text}',
                    scaffoldMessengerKey: widget.scaffoldMessengerKey,
                    phoneState: widget.phoneState,
                    otpState: widget.otpState,
                    userInfoState: widget.userInfoState);
              }
            },
            child: Text(AppLocalizations.of(context)!.next)),
      ),
    );
  }

  void _validate(String value) {
    if (value.length >= 10) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _buttonOpasity = 1.0;
        });
      } else {
        setState(() {
          _buttonOpasity = 0.0;
        });
      }
    }
    if (value.length < 10) {
      setState(() {
        _buttonOpasity = 0.0;
      });
    }
  }

  String? validator(String? value, RegExp regExp) {
    if (value != null) {
      if (value.isEmpty) {
        return AppLocalizations.of(context)!.pleaseEnterYourPhoneNumber;
      } else {
        if (regExp.hasMatch(value.trim())) {
          return null;
        }
        return AppLocalizations.of(context)!.phoneNumberIsNotValid;
      }
    }
    return AppLocalizations.of(context)!.pleaseEnterYourPhoneNumber;
  }
}
