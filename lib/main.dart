import 'package:flutter/material.dart';

import 'core/network/connectivity_service.dart';
import 'featuers/controller/form_sending_controller.dart';
import 'featuers/form_view.dart';

// Global key — যেকোনো জায়গা থেকে snackbar দেখাবে
final GlobalKey<ScaffoldMessengerState> snackbarKey =
GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final connectivity = ConnectivityService();
  final repo = FormSendingController(connectivity);

  await connectivity.checkNow();

  runApp(MyApp(repo: repo, connectivity: connectivity));
}

class MyApp extends StatelessWidget {
  final FormSendingController repo;
  final ConnectivityService connectivity;

  const MyApp({super.key, required this.repo, required this.connectivity});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      scaffoldMessengerKey: snackbarKey, // এখানে attach করুন
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FormScreen(repo: repo, connectivity: connectivity),
    );
  }
}