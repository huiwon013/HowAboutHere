import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'kakaologin.dart';
import 'main_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart'; // register.dart 파일을 import합니다.

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
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth 인스턴스 생성

  // 사용자 입력을 위한 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 로그인 버튼 크기 조정 변수
  final double buttonWidth = 210; // 버튼의 너비
  final double buttonHeight = 55;  // 버튼의 높이

  void _handleLogin() async {
    setState(() {
      _isLoggingIn = true; // 로그인 중임을 표시
    });

    bool success = await _viewModel.login();

    if (success) {
      try {
        // 카카오 사용자 정보를 가져오기
        var user = await UserApi.instance.me();
        String email = _emailController.text; // 입력한 이메일 가져오기
        String name = user.kakaoAccount?.profile?.nickname ?? '';

        // Firebase에 사용자 등록
        UserCredential userCredential = await _auth.signInWithCredential(
          EmailAuthProvider.credential(
            email: email,
            password: _passwordController.text, // 입력한 비밀번호 가져오기
          ),
        );

        // Firestore에 사용자 정보 저장하기
        // await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        //   'name': name,
        //   'email': email,
        // });

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print('Firebase에 사용자 등록 실패: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 후 사용자 정보를 저장하는 데 실패했습니다.')),
        );
      }
    } else {
      // 로그인 실패 시 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패')),
      );
    }

    setState(() {
      _isLoggingIn = false; // 로그인 완료 후 상태 복원
    });
  }

  // 회원가입 페이지로 이동하는 메소드
  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()), // RegisterPage로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        title: Text('로그인'),
        backgroundColor: Colors.blueGrey, // 카카오톡 색상으로 설정
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // 좌우 여백 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              // 아이디 입력 필드
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  labelStyle: TextStyle(color: Colors.grey[50]),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20), // 입력 필드와 다음 필드 사이 간격 추가
              // 비밀번호 입력 필드
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  labelStyle: TextStyle(color: Colors.grey[50]),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true, // 비밀번호 숨기기
              ),
              SizedBox(height: 20), // 입력 필드와 이미지 사이 간격 추가
              // 카카오 로그인 버튼 이미지
              Container(
                height: 48,
                child: ShadowedImage(
                  image: AssetImage('lib/startpage/kakao_login.png'), // 카카오 로그인 버튼 이미지
                ),
              ),
              SizedBox(height: 20), // 이미지와 로그인 버튼 사이 간격 추가
              ElevatedButton(
                onPressed: _isLoggingIn ? null : _handleLogin, // 로그인 버튼 클릭 시 로그인 처리
                child: Text('로그인', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 배경색을 검은색으로 설정
                  minimumSize: Size(buttonWidth, buttonHeight), // 버튼의 너비와 높이 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
                  ),
                  elevation: 5, // 그림자 추가
                ),
              ),
              SizedBox(height: 20), // 로그인 버튼과 회원가입 버튼 사이 간격 추가
              TextButton(
                onPressed: _isLoggingIn ? null : _handleSignUp,
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    color: Color(0xFF007aff), // 회원가입 버튼 색상
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 그림자가 있는 이미지 위젯
class ShadowedImage extends StatelessWidget {
  final ImageProvider image;

  ShadowedImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // 그림자 색상
            blurRadius: 6.0, // 흐림 반경
            spreadRadius: 1.0, // 퍼짐 반경
            offset: Offset(0, 3), // 그림자 위치
          ),
        ],
      ),
      child: Image(image: image), // 이미지 표시
    );
  }
}
