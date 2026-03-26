import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onChanged => _controller.stream;
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final wasOnline = _isOnline;
      _isOnline = _checkResults(results);
      _controller.add(_isOnline);

      if (!wasOnline && _isOnline) {
        print('Internet connected!');
      }
    });
  }

  Future<bool> checkNow() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = _checkResults(results);
    return _isOnline;
  }

  // List<ConnectivityResult> handle করো
  bool _checkResults(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  void dispose() => _controller.close();
}
