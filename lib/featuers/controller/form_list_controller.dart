import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/network/api_client.dart';
import '../../core/network/connectivity_service.dart';
import '../model/form_list_model.dart';

class FormListController extends ChangeNotifier {
  final ConnectivityService connectivity;

  FormListController(this.connectivity) {
    loadData();
    connectivity.onChanged.listen((isOnline) {
      if (isOnline) loadData();
    });
  }

  List<Datum> items = [];
  bool isLoading = false;
  bool get isOnline => connectivity.isOnline;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      if (connectivity.isOnline) {
        // Online — API থেকে আনো, model এ parse করো
        final res = await ApiClient.get('/sos/my-sos');
        final model = FormListModel.fromJson(res.data);
        items = model.data;
      } else {
        // Offline — Local DB থেকে আনো, Datum এ convert করো
        final localData = await LocalDb.getAll();
        items = localData.map((row) => Datum(
          id: row['id'],
          name: row['name'],
          user: null,
          phone: row['phone'],
          email: row['email'],
          isActive: null,
          createdAt: DateTime.tryParse(row['created_at'] ?? ''),
          updatedAt: null,
          v: null,
        )).toList();
      }
    } catch (_) {
      // Fallback — local DB
      final localData = await LocalDb.getAll();
      items = localData.map((row) => Datum(
        id: row['id'],
        name: row['name'],
        user: null,
        phone: row['phone'],
        email: row['email'],
        isActive: null,
        createdAt: DateTime.tryParse(row['created_at'] ?? ''),
        updatedAt: null,
        v: null,
      )).toList();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}