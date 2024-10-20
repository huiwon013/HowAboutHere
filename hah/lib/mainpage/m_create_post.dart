import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hah/mainpage/home.dart';


class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(); // 제목 필드 추가
  final TextEditingController _contentController = TextEditingController(); // 내용 필드 추가
  GoogleMapController? _mapController;
  LatLng? _currentLatLng; // 현재 위치를 저장할 변수 추가



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('여행 일지 작성'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 입력 필드
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
              ),
            ),
            const SizedBox(height: 16.0),
            // 장소 입력 필드 + 위치 아이콘
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: '장소',
                    ),
                    onTap: () {
                      _showLocationDialog(context);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: () {
                    _showLocationDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            // 사진 버튼
            ElevatedButton(
              onPressed: () {
                // 사진 선택 동작 추가
              },
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(height: 16.0),
            // 글 작성 필드
            Container(
              height: 300,
              child: SingleChildScrollView(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: '내용을 입력하세요',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              height: 1.0,
              color: Colors.grey,
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
      // 완료 버튼
      floatingActionButton: ElevatedButton(
        onPressed: () {
          _savePostToFirestore(); // Firestore에 데이터 저장 함수 호출
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()), // HomeScreen()으로 이동
                (Route<dynamic> route) => false, // 모든 이전 경로 제거
          );
        },
        child: const Text('완료'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
      ),
    );
  }


  Future<void> _savePostToFirestore() async {
    try {
      // 현재 로그인된 사용자 가져오기
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid; // 사용자의 UID 가져오기

        // Firestore에 'posts' 컬렉션 내에 'uid'별로 서브컬렉션 생성 후 데이터 저장
        await FirebaseFirestore.instance
            .collection('posts') // 'posts' 컬렉션
            .doc(uid) // 사용자별 문서 (uid 사용)
            .collection('userPosts') // 각 사용자의 게시물 서브컬렉션
            .add({
          'title': _titleController.text,
          'location': _locationController.text,
          'content': _contentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('포스트가 성공적으로 저장되었습니다!')),
        );
      } else {
        // 로그인이 되어 있지 않다면 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장에 실패했습니다: $e')),
      );
    }
  }

// 지도 다이얼로그
  Future<void> _showLocationDialog(BuildContext context) async {
    Position position = await _determinePosition();
    _currentLatLng = LatLng(position.latitude, position.longitude); // 현재 위치 저장

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('위치 입력'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '주소를 입력하세요',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _searchLocation(); // 주소 검색 함수 호출
                },
              ),
              const SizedBox(height: 16.0),
              Container(
                height: 200,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!, // 현재 위치 사용
                    zoom: 14.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller; // mapController 초기화
                  },
                  markers: {
                    if (_currentLatLng != null) // 현재 위치에 마커 표시
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: _currentLatLng!,
                      ),
                  },
                ),
              ),
              // 검색 버튼을 눌렀을 때 호출될 함수

            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

// 주소 검색 함수
  Future<void> _searchLocation() async {
    String address = _locationController.text; // 입력한 주소 가져오기
    if (address.isNotEmpty) {
      try {
        // Geocoding을 통해 주소를 위도와 경도로 변환
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          Location location = locations.first; // 첫 번째 위치 사용
          LatLng newLatLng = LatLng(location.latitude, location.longitude); // 새 위치

          // 지도 이동 및 마커 업데이트
          if (_mapController != null) { // mapController가 null이 아닐 경우
            _mapController!.animateCamera(CameraUpdate.newLatLng(newLatLng)); // 지도 이동
            setState(() {
              _currentLatLng = newLatLng; // 현재 위치 업데이트
            });
          }
        }
      } catch (e) {
        print('주소 검색 오류: $e'); // 디버그용 로그
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('주소 검색에 실패했습니다: ${e.toString()}')),
        );
      }
    } else {
      print('주소 검색 오류: $e'); // 디버그용 로그
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소를 입력해주세요')),
      );
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('위치 서비스가 비활성화되었습니다.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }

    return await Geolocator.getCurrentPosition();
  }
}


