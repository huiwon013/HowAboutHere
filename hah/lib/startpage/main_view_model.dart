import 'package:hah/startpage/start.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class MainViewModel {
  final Start _start;
  bool isLogined = false;
  User? user;

  MainViewModel(this._start);

  Future login() async {
    isLogined = await _start.login();
    if(isLogined){
      user = await UserApi.instance.me();
    }
  }

  Future logout() async {
    await _start.logout();
    isLogined = false;
    user = null;
  }

}