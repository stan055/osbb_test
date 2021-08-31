import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:osbb_test/models/app_user.dart';
import 'package:osbb_test/models/app_state_enum.dart';

class AppStateService extends ChangeNotifier {
  AppUser? _appUser;
  AppUser? get appUser => _appUser;

  User? _authUser;
  User? get authUser => _authUser;

  ApplicationStateEnum _loginState = ApplicationStateEnum.LOGO;
  ApplicationStateEnum get loginState => _loginState;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  AppStateService() {
    init();
  }

  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((user) async {
      _authUser = user;
      if (_authUser != null) {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await FirebaseFirestore.instance
                .doc('users/${_authUser!.uid}')
                .get();

        if (documentSnapshot.exists) {
          final document = documentSnapshot.data();

          documentSnapshot.reference.update({
            'lastOpenTime': FieldValue.serverTimestamp()
          }).catchError((e) => print(e));

          if (document != null) {
            try {
              _appUser = AppUser.fromJson(document);
              _loginState = ApplicationStateEnum.LOGGEDIN;
            } catch (e) {
              _loginState = ApplicationStateEnum.LOGGEDOUT;
            }
          } else {
            _loginState = ApplicationStateEnum.USER_INFO_FORM;
          }
        } else {
          _loginState = ApplicationStateEnum.USER_INFO_FORM;
        }
      } else {
        _loginState = ApplicationStateEnum.LOGGEDOUT;
      }
      notifyListeners();
    });
  }

  String? _verificationId;

  Future<void> verifyPhoneNumber(
      {required String phoneNumber,
      required GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
      required Function phoneState,
      required Function otpState,
      required Function userInfoState}) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await signInWithPhoneAuthCredential(credential);
        userInfoState();
      },
      verificationFailed: (FirebaseAuthException e) {
        phoneState();
        scaffoldMessengerKey.currentState!.showSnackBar(
            SnackBar(content: Text(e.message ?? 'Verification Failed!')));
      },
      codeSent: (String verificationId, int? resendToken) async {
        _verificationId = verificationId;
        otpState();
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  PhoneAuthCredential? createPhoneCredential(String smsCode) {
    if (_verificationId != null) {
      final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: smsCode);
      return credential;
    }
  }

  Future signInWithPhoneAuthCredential(PhoneAuthCredential credential) async {
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  void createUser(AppUser appUser) async {
    await FirebaseFirestore.instance
        .doc('users/${appUser.uid}')
        .set(appUser.toJson());

    _appUser = appUser;
    _loginState = ApplicationStateEnum.LOGGEDIN;
    notifyListeners();
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    _appUser = null;
  }
}
