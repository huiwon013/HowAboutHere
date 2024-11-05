import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'm_detail_post.dart';

class AllPostsPage extends StatefulWidget {
  final String city;

  AllPostsPage({required this.city});

  @override
  _AllPostsPageState createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  String sortOption = '인기순';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 46.0),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.city}',
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('region', isEqualTo: widget.city)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('오류 발생: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('게시물이 없습니다.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var post = snapshot.data!.docs[index];
                    var username = post['userNickname'] ?? '사용자 없음';
                    var date = post['timestamp']?.toDate() ?? DateTime.now();
                    var title = post['title'] ?? '제목 없음';
                    var content = post['content'] ?? '내용 없음';
                    var location = post['location'] ?? '위치 없음';

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
    );
  }
}
