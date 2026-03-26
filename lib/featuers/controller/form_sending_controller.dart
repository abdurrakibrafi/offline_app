import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';
import '../../core/network/api_client.dart';
import '../../core/network/connectivity_service.dart';

class FormSendingController {
  final ConnectivityService _connectivity;

  FormSendingController(this._connectivity) {
    _connectivity.onChanged.listen((isOnline) {
      if (isOnline) _uploadPending();
    });
  }

  Future<void> save({
    required String name,
    required String phone,
    required String email,
  }) async {
    final id = const Uuid().v4();

    await LocalDb.insert({
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
      'is_uploaded': 0,
    });

    if (_connectivity.isOnline) {
      await _post(id, name: name, phone: phone, email: email);
    }
  }

  Future<void> _post(
    String id, {
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      await ApiClient.post(
        '/sos',
        body: {"name": name, "phone": phone, "email": email},
      );
      await LocalDb.markUploaded(id);
    } catch (e) {
      print('Failed: $e');
    }
  }

  Future<void> _uploadPending() async {
    final pending = await LocalDb.getPending();
    for (final row in pending) {
      await _post(
        row['id'] as String,
        name: row['name'] as String,
        phone: row['phone'] as String,
        email: row['email'] as String,
      );
    }
  }

  // Future<List> getAll() async {
  //   final res = await ApiClient.get('/contacts');
  //   return res.data;
  // }
}
