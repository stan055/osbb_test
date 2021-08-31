import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:osbb_test/chat/service/users_and_chat_service.dart';
import 'package:osbb_test/services/messaging_service.dart';
import 'package:osbb_test/widgets/header.dart';
import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/services/app_state_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';

class UserInfoFormModel {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final numberOfRoomController = TextEditingController();
  final opasityDuration = 300;
  var buttonOpasity = .0;
  var isFieldChanged = {
    'firstName': false,
    'lastName': false,
    'roomNumber': false
  };

  UserInfoFormModel();
}

class UserInfoForm extends StatefulWidget {
  const UserInfoForm({Key? key}) : super(key: key);

  @override
  _UserInfoFormState createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  final formModel = new UserInfoFormModel();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formModel.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Header(text: AppLocalizations.of(context)!.pleaseFillThisForm),
          SizedBox(
            height: 40.0,
          ),
          _fieldFirstName(),
          SizedBox(
            height: 20.0,
          ),
          _fieldLastName(),
          SizedBox(
            height: 20.0,
          ),
          _fieldNumberOfRoom(),
          SizedBox(
            height: 30.0,
          ),
          _elevatedButton(),
        ],
      ),
    );
  }

  Widget _elevatedButton() {
    int opasityDuration = 300;

    return SizedBox(
      width: double.maxFinite,
      child: AnimatedOpacity(
          opacity: formModel.buttonOpasity,
          duration: Duration(milliseconds: opasityDuration),
          child: ElevatedButton(
              onPressed: () async {
                if (formModel.buttonOpasity != 0.0) {
                  AppUser appUser;
                  try {
                    appUser = await createUser(context, formModel);

                    final appService = context.read<AppStateService>();
                    appService.createUser(appUser);
                    final tokens = await UsersAndChatService
                        .getListByWhereIsEqualToValueAndNestedByFieldPath(
                            'users',
                            'role',
                            Role.ADMIN.index,
                            'messageToken') as List<String>;
                    final serverAddress =
                        await MessagingService.getMessagingServerAddress();
                    MessagingService.sendMulticast(
                        serverAddress: serverAddress,
                        tokens: tokens,
                        title: '++ New User Added!',
                        body: '${appUser.firstName} ${appUser.lastName}');
                  } catch (e) {
                    final snackBar = SnackBar(
                        content: Text('Error, user data has null value :('));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    print(e);
                  }
                }
              },
              child: Text('Save'))),
    );
  }

  Future<AppUser> createUser(
      BuildContext context, UserInfoFormModel formModel) async {
    User? firebaseAuthUser = context.read<AppStateService>().authUser;

    if (firebaseAuthUser == null) {
      throw Exception('Firebase current user equal null');
    }
    if (firebaseAuthUser.phoneNumber == null) {
      throw Exception('Phone number equal null');
    }

    String firstName = formModel.firstNameController.text.trim();
    String lastName = formModel.lastNameController.text.trim();
    String roomNumber = formModel.numberOfRoomController.text.trim();

    String phoneNumber = firebaseAuthUser.phoneNumber!;
    String userUid = firebaseAuthUser.uid;
    String? messageToken = await MessagingService.getToken();

    return new AppUser(
        uid: userUid,
        createdTime: Timestamp.now(),
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        roomNumber: roomNumber,
        messageToken: messageToken,
        role: Role.NOTCONFIRMED);
  }

  Widget _fieldNumberOfRoom() {
    return TextFormField(
      onChanged: (value) {
        formModel.isFieldChanged['roomNumber'] = true;
        formModel.formKey.currentState!.validate();
      },
      autovalidateMode: AutovalidateMode.disabled,
      controller: formModel.numberOfRoomController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.numberOfApartament,
      ),
      style: new TextStyle(fontWeight: FontWeight.normal, fontSize: 23),
      validator: (String? value) {
        if (formModel.isFieldChanged['roomNumber'] == true) {
          return validator(value, formModel, (value) {
            setState(() {
              formModel.buttonOpasity = value;
            });
          });
        }
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  Widget _fieldLastName() {
    return TextFormField(
      onChanged: (value) {
        formModel.isFieldChanged['lastName'] = true;
        formModel.formKey.currentState!.validate();
      },
      autovalidateMode: AutovalidateMode.disabled,
      controller: formModel.lastNameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.lastName,
      ),
      style: new TextStyle(fontWeight: FontWeight.normal, fontSize: 23),
      validator: (String? value) {
        if (formModel.isFieldChanged['lastName'] == true) {
          return validator(value, formModel, (value) {
            setState(() {
              formModel.buttonOpasity = value;
            });
          });
        }
      },
    );
  }

  Widget _fieldFirstName() {
    return TextFormField(
      onChanged: (value) {
        formModel.isFieldChanged['firstName'] = true;
        formModel.formKey.currentState!.validate();
      },
      autovalidateMode: AutovalidateMode.disabled,
      controller: formModel.firstNameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.firstName,
      ),
      style: new TextStyle(fontWeight: FontWeight.normal, fontSize: 23),
      validator: (String? value) {
        if (formModel.isFieldChanged['firstName'] == true) {
          return validator(value, formModel, (value) {
            setState(() {
              formModel.buttonOpasity = value;
            });
          });
        }
      },
    );
  }

  String? validator(
      String? value, UserInfoFormModel formModel, Function state) {
    if (value != null) {
      if (value.trim().isEmpty) {
        return AppLocalizations.of(context)!.theFieldMustNotBeEmpty;
      } else {
        if (formModel.firstNameController.text.trim().length > 0 &&
            formModel.lastNameController.text.trim().length > 0 &&
            formModel.numberOfRoomController.text.trim().length > 0) {
          if (formModel.buttonOpasity != 1.0) {
            state(1.0);
          }
        } else {
          if (formModel.buttonOpasity != 0.0) {
            state(0.0);
          }
        }
        return null;
      }
    }
    return AppLocalizations.of(context)!.theFieldMustNotBeEmpty;
  }
}
