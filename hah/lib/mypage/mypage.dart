import 'package:flutter/material.dart';
import '../appbar/appbar.dart';
import '../startpage/start.dart'; // 첫 페이지 파일을 import 합니다.

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('마이페이지'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              leading: const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'UserNickname', // Placeholder
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 프로필 수정 기능 구현
                    },
                    child: Text(
                      '프로필 수정',
                      style: TextStyle(
                        color: Colors.blue, // 원하는 색상으로 변경 가능
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                'Email', // Placeholder
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            Divider(),
            // 작성한 글, 좋아요, 북마크, 내가 쓴 댓글 항목 추가
            ListTile(
              leading: Icon(Icons.article),
              title: Text('작성한 글'),
              onTap: () {
                // TODO: 작성한 글 기능 구현
              },
            ),
            ListTile(
              leading: Icon(Icons.thumb_up),
              title: Text('좋아요'),
              onTap: () {
                // TODO: 좋아요 기능 구현
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('북마크'),
              onTap: () {
                // TODO: 북마크 기능 구현
              },
            ),
            ListTile(
              leading: Icon(Icons.comment),
              title: Text('내가 쓴 댓글'),
              onTap: () {
                // TODO: 내가 쓴 댓글 기능 구현
              },
            ),
            SizedBox(height: 20.0),
            Text(
              '계정 항목',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('비밀번호 변경'),
              onTap: () {
                // TODO: 비밀번호 변경 기능 구현
              },
            ),
            InkWell(
              onTap: () {
                _showLogoutDialog(context);
              },
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // 회원 탈퇴 다이얼로그 표시
              },
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text(
                  '회원 탈퇴',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('아니요'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => StartPage()), // 첫 페이지로 이동
                      (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
