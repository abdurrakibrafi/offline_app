import 'package:dio/dio.dart';
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

    if (_connectivity.isOnline) {
      // Online — আগে API, success হলে local save
      await _postAndSave(id: id, name: name, phone: phone, email: email);
    } else {
      // Offline — temp local save, net আসলে upload হবে
      await LocalDb.insert({
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
        'is_uploaded': 0,
      });
    }
  }

  // Online submit — API success হলেই local save
  Future<void> _postAndSave({
    required String id,
    required String name,
    required String phone,
    required String email,
  }) async {
    try {
      await ApiClient.post(
        '/sos',
        body: {"name": name, "phone": phone, "email": email},
      );

      // API success — local এ save করো
      await LocalDb.insert({
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
        'is_uploaded': 1,
      });

      print('Success → local saved');
    } on DioException {
      // API fail — local এ save হবে না
      print('API failed → not saved');
      rethrow; // FormScreen এ snackbar দেখাবে
    }
  }

  // Offline pending গুলো net আসলে upload
// Net আসলে — সবগুলো একে একে upload
  Future<void> _uploadPending() async {
    final pending = await LocalDb.getPending();
    if (pending.isEmpty) return;

    print('Pending: ${pending.length} টা upload হবে');

    for (final row in pending) {
      try {
        await ApiClient.post(
          '/sos',
          body: {
            "name": row['name'],
            "phone": row['phone'],
            "email": row['email'],
          },
        );

        // success হলে mark করো
        await LocalDb.markUploaded(row['id'] as String);
        print('Uploaded: ${row['id']}');
      } on DioException {
        // এটা fail হলে পরেরটায় যাও
        print('Failed: ${row['id']}');
      }
    }
  }
}