import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

Future<bool> checkInternetConnection() async {
  final result = await InternetConnection().hasInternetAccess;
  return result;
}

Stream<bool> checkInternetConnectivity() {
  return InternetConnection().onStatusChange.map((status) {
    switch (status) {
      case InternetStatus.connected:
        return true;
      case InternetStatus.disconnected:
        return false;
      default:
        return false;
    }
  });
}
