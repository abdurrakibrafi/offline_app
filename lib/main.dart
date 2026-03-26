import 'package:flutter/material.dart';

import 'featuers/form_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  WidgetsFlutterBinding.ensureInitialized();

  final connectivity = ConnectivityService();
  final dio = Dio(BaseOptions(
    baseUrl: 'https://your-api.com',  // আপনার base URL
    headers: {'Content-Type': 'application/json'},
  ));
  final repo = ContactRepository(connectivity, dio);

  await connectivity.checkNow();


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FormScreen(repo: null, connectivity: null,),
    );
  }
}

