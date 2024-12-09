import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hah/appbar/appbar.dart';
import 'package:hah/mainpage/home.dart';
import 'screen_result.dart'; // 검색 결과 화면

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserId(); // 로그인된 사용자의 uid 가져오기
  }

  // Firebase Authentication에서 현재 사용자 uid 가져오기
  Future<void> _getUserId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  // 검색어를 Firestore에 저장
  Future<void> saveSearchQuery(String query) async {
    try {
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('recent_searches')
            .doc(userId) // 사용자 UID로 구분
            .collection('searches') // 사용자의 검색어 서브컬렉션
            .add({
          'search_query': query,
          'timestamp': FieldValue.serverTimestamp(), // 검색어 추가 시간
        });
      }
    } catch (e) {
      print("Error saving search query: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // AppBar 높이 조정
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
          flexibleSpace: Padding(
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16), // 여백 조정
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppBarWithBottomNav(), // HomeScreen으로 이동
                      ),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "검색어를 입력하세요.",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Colors.grey),
                        onPressed: () {
                          final query = _searchController.text.trim();
                          if (query.isNotEmpty) {
                            saveSearchQuery(query); // 검색어를 Firestore에 저장
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchResultsPage(
                                  searchQuery: query, // 검색어를 결과 화면에 전달
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      contentPadding:
                      const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          elevation: 0, // AppBar 아래 그림자 제거
        ),
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // 스크롤 가능하도록 추가
        child: Column(

          children: [
            // 최근 검색어 섹션
            Container(
              color: Colors.white, // 배경색 추가
              padding: const EdgeInsets.all(16.0),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "최근 검색어",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    height: 1.0, // 선의 두께
                    color: Colors.grey[300], // 선의 색상
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('recent_searches')
                    .doc(userId)
                    .collection('searches')
                    .orderBy('timestamp', descending: true) // 최신 순으로 정렬
                    .limit(5) // 최근 5개의 검색어만 가져오기
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("최근 검색어가 없습니다."));
                  }

                  var recentSearches = snapshot.data!.docs
                      .map((doc) => doc['search_query'] as String)
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // ListView가 Scroll되지 않도록 설정
                    itemCount: recentSearches.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(recentSearches[index]),
                        onTap: () {
                          // 최근 검색어 클릭 시 게시물 검색 결과로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchResultsPage(
                                searchQuery: recentSearches[index],
                              ),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            _deleteSearchQuery(recentSearches[index]);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // "요즘 뜨는 여행지" 섹션
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "요즘 뜨는 여행지",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8.0),
                  // 여행지 목록
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5, // 예시로 5개 여행지 표시
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: Icon(Icons.location_on, color: Colors.blue),
                          title: Text('여행지 ${index + 1}'),
                          subtitle: Text('위치 설명'),
                          onTap: () {
                            // 여행지 선택 시 동작 추가 (예: 세부 정보 페이지로 이동)
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 특정 검색어 삭제
  Future<void> _deleteSearchQuery(String query) async {
    if (userId != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('recent_searches')
            .doc(userId)
            .collection('searches')
            .where('search_query', isEqualTo: query)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print("Error deleting search query: $e");
      }
    }
  }
}
