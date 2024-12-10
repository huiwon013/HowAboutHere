import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hah/mainpage/search.dart';
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
  ]; // 국내도시 리스트
  List<String> countries = []; // 해외 데이터 저장할 리스트

  @override
  void initState() {
    super.initState();
    fetchCountries(); // 초기화 시 나라 목록 가져오기
  }

  Future<void> fetchCountries() async {
    try {
      // '해외'인 문서만 가져오기
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('type', isEqualTo: '해외')
          .get();

      // region 필드를 가져와 중복 제거 후 countries 리스트 생성
      final regions = querySnapshot.docs
          .map((doc) => doc['country'].toString())
          .toSet()
          .toList();

      setState(() {
        countries = regions;
      });
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }


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
              padding: const EdgeInsets.only(left: 20.0),
              child: GestureDetector(
                onTap: () {
                  // SearchScreen으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
                child: TextField(
                  enabled: false, // 클릭만 가능하도록 설정
                  decoration: InputDecoration(
                    hintText: "어디로 떠나시나요?",
                    hintStyle: const TextStyle(color: Colors.black54), // 힌트 텍스트 색상
                    filled: true, // 배경색 활성화
                    fillColor: Colors.white, // 배경색 설정
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black54, width: 1.5), // 비활성화 상태 테두리
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black54, width: 1.5), // 비활성화 상태 테두리
                    ),
                    suffixIcon: const Icon(Icons.search, color: Colors.black), // 검색 아이콘 색상
                    contentPadding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12.0),
                  ),
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
                ? buildDomesticGrid() // 국내 도시 그리드
                : buildCountryGrid(),  // 해외 나라 그리드
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

// 국내 도시 그리드
  Widget buildDomesticGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 2,
      ),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Color(0xFF4EA7F6), // 버튼 텍스트 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // 테두리 둥글게 조정
              side: BorderSide(
                color: Colors.grey, // 테두리 색상
                width: 1,         // 테두리 두께
              ),
            ),
            textStyle: const TextStyle(
              fontSize: 18.0, // 폰트 크기
              //fontWeight: FontWeight.bold, // (선택 사항) 글꼴 두께
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllPostsPage(city: cities[index]),

              ),
            );
          },
          child: Text(cities[index]),
        );
      },
    );
  }


  // 해외 나라 그리드
  Widget buildCountryGrid() {
    return countries.isEmpty
        ? const Center(child: CircularProgressIndicator()) // 데이터 로드 중
        : GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 2,
      ),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Color(0xFF4EA7F6), // 버튼 텍스트 색상
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // 테두리 둥글게 조정
              side: BorderSide(
                color: Colors.grey, // 테두리 색상
                width: 1,         // 테두리 두께
              ),
            ),
            textStyle: const TextStyle(
              fontSize: 18.0, // 폰트 크기
              //fontWeight: FontWeight.bold, // (선택 사항) 글꼴 두께
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllPostsPage(city: countries[index]),
              ),
            );
          },
          child: Text(countries[index]),
        );
      },
    );
  }
}


