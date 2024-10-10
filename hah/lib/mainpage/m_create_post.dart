import 'package:flutter/material.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('여행 일지 작성'), // 앱바 제목
        backgroundColor: Colors.white, // 앱바 배경색
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 패딩 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            // 제목 입력 필드
            TextField(
              decoration: InputDecoration(
                labelText: '제목',
              ),
            ),
            const SizedBox(height: 16.0), // 간격
            // 장소 입력 필드
            TextField(
              decoration: InputDecoration(
                labelText: '장소',
              ),
            ),
            const SizedBox(height: 16.0), // 간격
            // 사진 버튼
            ElevatedButton(
              onPressed: () {
                // 사진 선택 동작 추가
              },
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(height: 16.0), // 간격
            // 글 작성 필드
            Container(
              height: 300, // 글 작성 필드의 고정 높이
              child: SingleChildScrollView(
                child: TextField(
                  maxLines: null, // 무한대로 줄 수 늘리기
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요',
                    border: InputBorder.none, // 테두리 없애기
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0), // 구분선과 완료 버튼 간격
            // 구분선
            Container(
              height: 1.0, // 구분선의 두께
              color: Colors.grey, // 구분선 색상
            ),
            const SizedBox(height: 8.0), // 구분선과 완료 버튼 간격
          ],
        ),
      ),
      // 완료 버튼
      floatingActionButton: ElevatedButton(
        onPressed: () {
          // 완료 동작 추가
        },
        child: const Text('완료'), // 텍스트 버튼으로 변경
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // 버튼 배경색
          //minimumSize: const Size(double.infinity, 10), // 버튼 너비
        ),
      ),
    );
  }
}
