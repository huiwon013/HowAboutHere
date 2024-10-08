import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 추가
import 'firebase_options.dart'; // Firebase 설정 파일 추가
import 'appbar/appbar.dart'; // AppBarWithBottomNav 파일 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 바인딩 초기화
  await Firebase.initializeApp( // Firebase 초기화
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const AppBarWithBottomNav(), // AppBarWithBottomNav 사용
    );
  }
}
