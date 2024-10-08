import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 알림 버튼 클릭 시 동작 추가
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0), // 높이 조정
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // 좌우 패딩 추가
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: '검색...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 10), // 검색창과 아래 텍스트 간격
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text('국내', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    Text('해외', style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Firebase에서 데이터를 불러오는 부분 추가
          Expanded(
            child: Center(
              child: Text('여기에 Firebase 데이터 표시'),
            ),
          ),
        ],
      ),
    );
  }
}
