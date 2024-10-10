import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hah/community/c_create_post.dart';
import '../firebase_options.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int selectedTabIndex = 0; // 0: 전체, 1: 인기글, 2: 국내, 3: 해외

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.white, // 배경색 흰색으로 설정
        toolbarHeight: 100, // AppBar 높이 조정
        actions: [
          // 검색창을 Action에 추가
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0), // 왼쪽 패딩만 16.0으로 설정
              child: TextField(
                decoration: InputDecoration(
                  hintText: "검색어를 입력하세요. ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 알림 버튼 클릭 시 동작 추가
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0), // 왼쪽 패딩 추가
              child: Text(
                '커뮤니티',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(
            thickness: 1, // 구분선 두께
            color: Colors.black, // 구분선 색상
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTab('전체', 0),
              _buildTab('인기글', 1),
              _buildTab('국내', 2),
              _buildTab('해외', 3),
            ],
          ),
          // Firebase에서 데이터를 불러오는 부분
          Expanded(
            child: Center(
              child: Text(
                selectedTabIndex == 0
                    ? '전체 데이터 표시' // 전체 데이터 표시
                    : selectedTabIndex == 1
                    ? '인기글 데이터 표시' // 인기글 데이터 표시
                    : selectedTabIndex == 2
                    ? '국내 데이터 표시' // 국내 데이터 표시
                    : '해외 데이터 표시', // 해외 데이터 표시
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CMCreatePostPage()), // 커뮤니티 글 생성 페이지로 이동
          );
        },
        child: Container(
          width: 95, // 버튼의 너비 (아이콘과 텍스트를 고려하여 조정)
          height: 30, // 버튼의 높이
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            //shape: BoxShape.rectangle, // 사각형
            color: Colors.white, // 배경색
            border: Border.all(
              color: Colors.black54, // 테두리 색
              width: 2, // 테두리 두께
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            children: [
              const Icon(Icons.add, size: 20), // + 아이콘
              const SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
              const Text(
                '글쓰기', // 텍스트 추가
                style: TextStyle(
                  fontSize: 15, // 글씨 크기
                  color: Colors.black, // 글씨 색
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 전체, 인기글, 국내, 해외 탭
  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index; // 선택된 탭 인덱스 변경
        });
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: selectedTabIndex == index ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
