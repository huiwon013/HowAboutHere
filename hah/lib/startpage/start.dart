import 'package:flutter/material.dart';
import 'kakaologin.dart';
import 'main_view_model.dart';

abstract class Start {
  Future<bool> login();
  Future<bool> logout();
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final MainViewModel _viewModel = MainViewModel(kakaologin());
  bool _isLoggingIn = false;

  void _handleLogin() async {
    setState(() {
      _isLoggingIn = true; // 로그인 중임을 표시
    });

    bool success = await _viewModel.login();

    setState(() {
      _isLoggingIn = false; // 로그인 완료 후 상태 복원
    });

    if (success) {
      // 로그인 성공 후의 로직
      // 예를 들어, 다음 페이지로 이동할 수 있습니다.
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // 로그인 실패 시 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카카오 로그인'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _viewModel.isLogined ? '로그인 성공!' : '로그인 해주세요',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoggingIn ? null : _handleLogin,
              child: _isLoggingIn
                  ? CircularProgressIndicator()
                  : Text('카카오 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
