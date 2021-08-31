import 'package:osbb_test/models/app_user.dart';

double progressValue(Map<String, dynamic>? data, num value) {
  if (data == null) return 0.0;
  if (data.isEmpty) return 0.0;
  final result =
      value / (data.values.reduce((value, element) => element + value)) * 1;

  if (result.isFinite) {
    return result;
  }
  return 0.0;
}

bool votePermission(Role role) {
  if (role == Role.NOTCONFIRMED || role == Role.BANED) return false;
  return true;
}
