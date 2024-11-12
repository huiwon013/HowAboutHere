import 'package:flutter/material.dart';
import 'package:hah/appbar/appbar.dart';
import 'package:hah/mainpage/home.dart';
import 'package:hah/startpage/find_Register.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao_user;
import 'kakaologin.dart';
import 'main_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// StartPage를 위한 클래스
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
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final double buttonWidth = 210;
  final double buttonHeight = 55;

  // Firebase 이메일/비밀번호 로그인
  void _handleLogin() async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppBarWithBottomNav()),
      );
    } catch (e) {
      print('Firebase 로그인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: 이메일과 비밀번호를 확인해주세요.')),
      );
    }

    setState(() {
      _isLoggingIn = false;
    });
  }

  // 카카오 로그인 처리
  void _handleKakaoLogin() async {
    try {
      bool? success = await _viewModel.login();

      // success가 null인 경우를 처리
      if (success == null) {
        throw Exception("카카오 로그인 실패");
      }

      if (success) {
        final kakao_user.User user = await kakao_user.UserApi.instance.me();
        String kakaoEmail = user.kakaoAccount?.email ?? '';

        // Firebase에서 사용자가 이미 존재하는지 확인
        firebase_auth.User? firebaseUser = _auth.currentUser;

        if (firebaseUser != null && firebaseUser.email != null) {
          // Firebase에 사용자가 존재하면 프로필이 완성되었는지 확인
          bool isProfileComplete = await checkUserProfile(firebaseUser.email!);

          if (isProfileComplete) {
            // 프로필 정보가 완성되었으면 홈 화면으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            // 프로필 정보가 없으면 프로필 설정 페이지로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileSetupPage()),
            );
          }
        } else {
          // Firebase에 사용자가 없으면 새 사용자로 간주하고 프로필 설정 페이지로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileSetupPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패')),
        );
      }
    } catch (e) {
      print('카카오 로그인 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카카오 로그인 실패: $e')),
      );
    }
  }

  // Firebase에서 사용자 프로필 정보 확인 (예시)
  Future<bool> checkUserProfile(String email) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();
    return userDoc.exists && userDoc.data() != null;
  }

  // 회원가입 페이지로 이동
  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  // 비밀번호 찾기 페이지로 이동
  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FindRegister()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('로그인'),
        backgroundColor: Colors.blue[50],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: '아이디',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoggingIn ? null : _handleLogin,
                    child: Text('로그인', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(buttonWidth, buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 5,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isLoggingIn ? null : _handleKakaoLogin,
                    child: Container(
                      height: 48,
                      child: ShadowedImage(
                        image: AssetImage('lib/startpage/kakao_login.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _isLoggingIn ? null : _handleSignUp,
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text('|', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                SizedBox(width: 8),
                TextButton(
                  onPressed: _isLoggingIn ? null : _handleForgotPassword,
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShadowedImage extends StatelessWidget {
  final ImageProvider image;

  ShadowedImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.0,
            spreadRadius: 1.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Image(image: image),
    );
  }
}

// ProfileSetupPage - 프로필 설정 페이지
class ProfileSetupPage extends StatefulWidget {
  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // 프로필 정보 저장 함수
  void _saveProfile() async {
    firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Firestore에 프로필 정보 저장
        await FirebaseFirestore.instance.collection('users').doc(user.email).set({
          'nickname': _nicknameController.text,
          'name': _nameController.text,
          'email': user.email,
        });

        // 프로필 설정 완료 후 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 저장 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('프로필 설정')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(labelText: '닉네임'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
              enabled: false, // 이메일은 변경 불가
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
