import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hah/appbar/appbar.dart';
import 'package:hah/mainpage/home.dart';
import 'package:image_picker/image_picker.dart';


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
  List<Widget> _contentItems = []; // 텍스트와 이미지를 저장할 리스트

  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = []; // 이미지 파일들을 저장하는 리스트
  List<String> imageUrls = []; // 업로드된 이미지 URL들을 저장하는 리스트


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
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text("사진 추가"),
              onPressed: _addImage,
            ),
            const SizedBox(height: 16.0),
            // 글 작성 입력 필드
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _contentItems,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // 글 작성 입력 필드
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '글 작성...',
                //border: OutlineInputBorder()
              ),
              onSubmitted: (text) {
                _addText(text);
                _contentController.clear(); // 입력 필드 비우기
              },
            ),
            const SizedBox(height: 16.0),
/*            // 사진 추가 버튼
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text("사진 추가"),
              onPressed: _addImage,
            ),*/
          ],
        ),
      ),
      // 완료 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _savePostToFirestore(); // Firestore에 데이터 저장 함수 호출
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AppBarWithBottomNav()), // HomeScreen()으로 이동
                (Route<dynamic> route) => false, // 모든 이전 경로 제거
          );
        },
        child: const Text('완료'),
        backgroundColor: Colors.white,
      ),
    );
  }

  // 이미지 추가 함수
  Future<void> _addImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Firebase Storage에 이미지 업로드
      String filePath = 'images/${DateTime.now()}.png';
      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(File(pickedFile.path));

      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        // Firestore에 저장할 imageUrls 리스트에 업로드된 이미지 URL 추가
        imageUrls.add(imageUrl);

        // _contentItems에 이미지 위젯 추가
        _contentItems.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                Image.file(
                  File(pickedFile.path),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        );
      });
    }
  }


  void _addText(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _contentItems.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(text),
        ));
      });
    }
  }

/*
  void _addTextBelowImage(String text) {
    setState(() {
      if (text.isNotEmpty) {
        _contentItems.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(text),
        ));
      }
    });
  }
*/

  Future<Map<String, String>> _getAdministrativeArea(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String country = place.country ?? 'Unknown'; // 국가 정보
        String region = place.locality ?? place.subAdministrativeArea ?? 'Unknown'; // 도시 정보 (locality 우선, 없으면 subAdministrativeArea 사용)

        //서울 위도경도
        if (latLng.latitude >= 37.0 && latLng.latitude <= 37.8 &&
            latLng.longitude >= 126.5 && latLng.longitude <= 127.2) {
          region = '서울특별시';
        }
        // 부산의 위도, 경도 범위
        else if (latLng.latitude >= 35.1 && latLng.latitude <= 35.3 &&
            latLng.longitude >= 129.0 && latLng.longitude <= 129.4) {
          region = '부산광역시';
        }
        // 제주도 위도, 경도 범위
        else if (latLng.latitude >= 33.0 && latLng.latitude <= 33.5 &&
            latLng.longitude >= 126.0 && latLng.longitude <= 126.5) {
          region = '제주특별자치도';
        }
        // 인천 위도, 경도 범위
        else if (latLng.latitude >= 37.3 && latLng.latitude <= 37.7 &&
            latLng.longitude >= 126.4 && latLng.longitude <= 126.7) {
          region = '인천광역시';
        }

        // 경기도
        else if (latLng.latitude >= 37.0 && latLng.latitude <= 38.0 &&
            latLng.longitude >= 126.5 && latLng.longitude <= 127.7) {
          region = '경기도';
        }

        // 강원도
        else if (latLng.latitude >= 37.3 && latLng.latitude <= 38.6 &&
            latLng.longitude >= 127.0 && latLng.longitude <= 129.0) {
          region = '강원도';
        }

        // 충청남도
        else if (latLng.latitude >= 36.0 && latLng.latitude <= 37.2 &&
            latLng.longitude >= 126.0 && latLng.longitude <= 127.5) {
          region = '충청남도';
        }

        // 충청북도
        else if (latLng.latitude >= 36.3 && latLng.latitude <= 37.5 &&
            latLng.longitude >= 127.0 && latLng.longitude <= 128.5) {
          region = '충청북도';
        }

        // 경상북도
        else if (latLng.latitude >= 35.5 && latLng.latitude <= 36.5 &&
            latLng.longitude >= 128.5 && latLng.longitude <= 130.0) {
          region = '경상북도';
        }

        // 경상남도
        else if (latLng.latitude >= 34.5 && latLng.latitude <= 35.5 &&
            latLng.longitude >= 128.0 && latLng.longitude <= 129.5) {
          region = '경상남도';
        }

        // 전라북도
        else if (latLng.latitude >= 35.0 && latLng.latitude <= 36.5 &&
            latLng.longitude >= 126.5 && latLng.longitude <= 128.0) {
          region = '전라북도';
        }

        // 전라남도
        else if (latLng.latitude >= 34.5 && latLng.latitude <= 35.6 &&
            latLng.longitude >= 126.0 && latLng.longitude <= 127.5) {
          region = '전라남도';
        }

        // 대전광역시
        else if (latLng.latitude >= 36.3 && latLng.latitude <= 36.5 &&
            latLng.longitude >= 127.2 && latLng.longitude <= 127.6) {
          region = '대전광역시';
        }

        // 광주광역시
        else if (latLng.latitude >= 35.1 && latLng.latitude <= 35.3 &&
            latLng.longitude >= 126.7 && latLng.longitude <= 127.1) {
          region = '광주광역시';
        }

        // 대구광역시
        else if (latLng.latitude >= 35.8 && latLng.latitude <= 35.9 &&
            latLng.longitude >= 128.5 && latLng.longitude <= 129.1) {
          region = '대구광역시';
        }

        // 울산광역시
        else if (latLng.latitude >= 35.4 && latLng.latitude <= 35.7 &&
            latLng.longitude >= 129.0 && latLng.longitude <= 129.4) {
          region = '울산광역시';
        }

        else {
          region = '기타';
        }
        //국내 해외 판별
        String type = (country == '대한민국') ? '국내' : '해외';
        

        return {'country': country, 'region': region, 'type':type};
      }
    } catch (e) {
      print('Reverse Geocoding 오류: $e');
      return {'country': 'Unknown', 'region': 'Unknown'};
    }
    return {'country': 'Unknown', 'region': 'Unknown'};
  }

  Future<void> _savePostToFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        // 현재 위치의 지역 정보와 타입 얻기
        String administrativeArea = 'Unknown';
        String type = 'Unknown';
        String country = 'Unknown';
        if (_currentLatLng != null) {
          Map<String, String> locationData = await _getAdministrativeArea(_currentLatLng!);

          administrativeArea = locationData['region'] ??'Unknown'!;
          country = locationData['country'] ?? 'Unknown';
          type = locationData['type']?? 'Unknown';
        }

        // Firestore에서 사용자 닉네임 가져오기
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        String userNickname = userDoc['userNickname'];

        // Firestore에 새 게시물 추가
        await FirebaseFirestore.instance.collection('posts').add({
          'userNickname': userNickname,
          'uid': uid,
          'title': _titleController.text,
          'location': _locationController.text,
          'country': country, // 나라 저장
          'region': administrativeArea, // 도시 저장
          'type': type, // 국내/해외 정보 추가
          'imageUrls': imageUrls,
          'content': _contentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('포스트가 성공적으로 저장되었습니다!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다.')),
        );
      }
    } catch (e) {
      print('저장 실패: $e');  // 콘솔에 오류 출력
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

          //12/8 추가
          // Reverse Geocoding을 통해 해당 좌표가 어느 지역에 속하는지 판단
          Map<String, String> addressInfo = await _getAdministrativeArea(newLatLng);
          String region = addressInfo['region'] ?? 'Unknown'; // region 정보 가져오기

          // 지도 이동 및 마커 업데이트
          if (_mapController != null) { // mapController가 null이 아닐 경우
            _mapController!.animateCamera(CameraUpdate.newLatLng(newLatLng)); // 지도 이동
            setState(() {
              _currentLatLng = newLatLng; // 현재 위치 업데이트

            });

            print('지역: $region');
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


