import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/login_viewmodel.dart';
import 'views/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: MaterialApp(
        title: 'Flutter MVVM Login',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const SplashView(),
      ),
    );
  }
}
