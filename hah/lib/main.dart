import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 추가
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'firebase_options.dart'; // Firebase 설정 파일 추가
import 'appbar/appbar.dart'; // AppBarWithBottomNav 파일 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 바인딩 초기화

  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '98d90e742966ef791921f6f56b6f4993',
    javaScriptAppKey: '7d7a23809e1af172ab8c2ea56d73c921',
  );

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 앱 실행
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
