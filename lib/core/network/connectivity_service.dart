// lib/core/network/connectivity_service.dart
import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onStatusChange => _controller.stream;
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    InternetConnection().onStatusChange.listen((status) {
      _isOnline = status == InternetStatus.connected;
      _controller.add(_isOnline);
    });
  }

  Future<bool> checkNow() async {
    _isOnline = await InternetConnection().hasInternetAccess;
    return _isOnline;
  }

  void dispose() => _controller.close();
}
