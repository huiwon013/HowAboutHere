import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'm_all_posts.dart';
import 'm_create_post.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDomesticSelected = true; // 기본 선택 상태를 국내로 설정
  final List<String> cities = [
    '서울특별시', '부산광역시', '제주특별자치도', '인천광역시', '경기도', '강원도', '충청남도', '충청북도',
    '경상북도', '경상남도', '전라북도', '전라남도',
    '대전광역시', '광주광역시', '대구광역시', '울산광역시', '기타'
  ]; // 도시 리스트

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
                  hintText: "어디로 떠나시나요? ",
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
          //const SizedBox(height: 0), // 검색창과 아래 텍스트 간격
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDomesticSelected = true; // 국내 선택
                  });
                },
                child: Text(
                  '국내',
                  style: TextStyle(
                    fontSize: 25,
                    color: isDomesticSelected ? Colors.black : Colors.grey,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isDomesticSelected = false; // 해외 선택
                  });
                },
                child: Text(
                  '해외',
                  style: TextStyle(
                    fontSize: 25,
                    color: isDomesticSelected ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          // Firebase에서 데이터를 불러오는 부분
          // 국내 도시 버튼 목록
          Expanded(
            child: isDomesticSelected
                ? GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2열로 배치
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 3, // 버튼의 가로:세로 비율 조정
              ),
              itemCount: cities.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    // 도시 버튼을 클릭하면 m_all_posts.dart 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllPostsPage(city: cities[index]), // 선택된 도시로 이동
                      ),
                    );
                  },
                  child: Text(cities[index]),
                );
              },
            )
                : const Center(child: Text('해외 데이터 표시')), // 해외 선택 시 처리
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 60, // 버튼의 너비
        height: 60, // 버튼의 높이
        decoration: BoxDecoration(
          shape: BoxShape.circle, // 원형
          color: Colors.white, // 배경색
          border: Border.all(
            color: Colors.black54, // 테두리 색
            width: 2, // 테두리 두께
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.add, size: 30), // + 아이콘
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreatePostPage()), // CreatePostPage로 이동
            );
          },
        ),
      ),
    );
  }
}

class _buildCityGrid {
}
