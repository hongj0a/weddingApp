import 'package:http/http.dart' as http;

class ApiConstants {
  static const String baseUrl = 'http://192.168.3.50:8888';
  static const String isExistPairingCode = '$baseUrl/api/isExistPairingCode';
  static const String authenticate = '$baseUrl/api/authenticate';
  static const String setDDay = '$baseUrl/main/setDDay';
  static const String localImagePath = '$baseUrl/uploads';
  static const String delDDay = '$baseUrl/main/delDDay';
  static const String setSchedule = '$baseUrl/calendar/setSchedule';
  static const String getScheduleMark = '$baseUrl/calendar/getScheduleMark';
  static const String getSchedules = '$baseUrl/calendar/getSchedules';
  static const String delSchedule = '$baseUrl/calendar/delSchedule';
  static const String getUserInfo = '$baseUrl/myPage/getUserInfo';
  static const String setUserInfo = '$baseUrl/myPage/setUserInfo';
  static const String getBudget = '$baseUrl/myPage/getBudget';
  static const String initBudgets = '$baseUrl/myPage/initBudgets';
  static const String setBudget = '$baseUrl/myPage/setBudget';
  static const String updateBudget = '$baseUrl/myPage/updateBudget';
  static const String delBudget = '$baseUrl/myPage/delBudget';
  static const String delUser = '$baseUrl/myPage/delUser';
  static const String delPairing = '$baseUrl/myPage/delPairing';
  static const String getAlarm = '$baseUrl/main/getAlarm';
  static const String alarmNewFlag = '$baseUrl/main/alarmNewFlag';
  static const String getYnList = '$baseUrl/main/getYnList';
  static const String updateYnSetting = '$baseUrl/main/updateYnSetting';
  static const String getCategories = '$baseUrl/cost/getCategories';
  static const String getCheckLists = '$baseUrl/cost/getCheckLists';
  static const String getCheckListDetail = '$baseUrl/cost/getCheckListDetail';
  static const String setChecklist = '$baseUrl/cost/setChecklist';
  static const String updateChecklist = '$baseUrl/cost/updateChecklist';
  static const String deleteChecklist = '$baseUrl/cost/deleteChecklist';


  static Future<http.Response> getDDay(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/main/getDDay'),
      headers: {
        'Authorization': 'Bearer $accessToken', // accessToken 추가
      },
    );
    return response; // http.Response 객체 반환
  }
  static const String refreshTokenValidation = '$baseUrl/api/refreshTokenValidation';
  static const String webSocketUrl = 'ws://192.168.3.50:8888/ws-stomp';

}