import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hah/mainpage/search.dart';
import 'm_detail_post.dart'; // 게시물 상세 페이지 (상세 화면을 위해 필요)

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  SearchResultsPage({required this.searchQuery});

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  String sortOption = '인기순'; // 정렬 옵션

  Future<List<QueryDocumentSnapshot>> fetchPosts() async {
    final collection = FirebaseFirestore.instance.collection('posts');

    // 모든 게시물 가져오기 (조건 없이)
    var allResults = await collection.get();

    // 검색어가 title 또는 content에 포함된 게시물만 필터링
    var filteredResults = allResults.docs.where((post) {
      var title = post['title']?.toLowerCase() ?? '';
      var content = post['content']?.toLowerCase() ?? '';
      var searchQuery = widget.searchQuery.toLowerCase();

      // title 또는 content에 검색어가 포함되면 true
      return title.contains(searchQuery) || content.contains(searchQuery);
    }).toList();

    return filteredResults;
  }

  Future<void> saveSearchQuery(String query) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // 최근 검색어를 Firestore에 저장
        await FirebaseFirestore.instance
            .collection('recent_searches')
            .doc(user.uid)
            .collection('searches')
            .add({
          'search_query': query,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error saving search query: $e");
      }
    }
  }

  // 뒤로가기 버튼 클릭 시 SearchScreen으로 돌아가기
  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(), // SearchScreen으로 이동
      ),
    );
    return Future.value(false); // 기본 동작을 막고, 커스텀 동작을 처리
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // 뒤로가기 버튼 이벤트 처리
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 100,
          actions: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 46.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "검색어를 입력하세요",
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '검색 결과 - "${widget.searchQuery}"',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        sortOption = value;
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: '인기순', child: Text('인기순')),
                      PopupMenuItem(value: '최신순', child: Text('최신순')),
                      PopupMenuItem(value: '최근 3개월', child: Text('최근 3개월')),
                    ],
                    child: Row(
                      children: [
                        Text(sortOption, style: TextStyle(fontSize: 16)),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: fetchPosts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('오류 발생: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('검색 결과가 없습니다.'));
                  }

                  var posts = snapshot.data!;

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      var post = posts[index];
                      var username = post['userNickname'] ?? '사용자 없음';
                      var date = post['timestamp']?.toDate() ?? DateTime.now();
                      var title = post['title'] ?? '제목 없음';
                      var content = post['content'] ?? '내용 없음';
                      var location = post['location'] ?? '위치 없음';
                      var imageUrls = (post['imageUrls'] as List<dynamic>).cast<String>();
                      var postId = post.id;

                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.account_circle, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(username, style: TextStyle(fontSize: 14, color: Colors.grey)),
                                  Spacer(),
                                  Text(
                                    '${date.year}-${date.month}-${date.day}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Text(location, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              SizedBox(height: 4),
                              if (imageUrls.isNotEmpty)
                                SizedBox(
                                  height: 150,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imageUrls.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Image.network(
                                          imageUrls[index],
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 100,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailPage(
                                  title: title,
                                  content: content,
                                  location: location,
                                  username: username,
                                  date: date,
                                  imageUrls: imageUrls,
                                  postId: postId,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
