class ApiConstants {
  //static const String baseUrl = 'http://112.222.141.78:8888';
  static const String mlUrl = 'http://112.222.141.78:5001';
  static const String predict = '$mlUrl/predict';
  static const String feedback = '$mlUrl/feedback';
  static const String baseUrl = 'http://192.168.3.50:8888';
  static const String isExistPairingCode = '$baseUrl/api/isExistPairingCode';
  static const String authenticate = '$baseUrl/api/authenticate';
  static const String refreshTokenValidation = '$baseUrl/api/refreshTokenValidation';

  static const String setDDay = '$baseUrl/main/setDDay';
  static const String localImagePath = '$baseUrl/uploads';
  static const String delDDay = '$baseUrl/main/delDDay';
  static const String getAlarm = '$baseUrl/main/getAlarm';
  static const String alarmNewFlag = '$baseUrl/main/alarmNewFlag';
  static const String getYnList = '$baseUrl/main/getYnList';
  static const String updateYnSetting = '$baseUrl/main/updateYnSetting';
  static const String getDDay = '$baseUrl/main/getDDay';

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
  static const String inquiryMailSend = '$baseUrl/myPage/inquiryMailSend';
  static const String getNotice = '$baseUrl/myPage/getNotice';
  static const String getNoticeDetail = '$baseUrl/myPage/getNoticeDetail';
  static const String getTerms = '$baseUrl/myPage/getTerms';
  static const String getTermsDetail = '$baseUrl/myPage/getTermsDetail';
  static const String getFaqCategoryList = '$baseUrl/myPage/getFaqCategoryList';
  static const String getFaqList = '$baseUrl/myPage/getFaqList';
  static const String getFaqDetail = '$baseUrl/myPage/getFaqDetail';
  static const String checkPost = '$baseUrl/myPage/checkPost';
  static const String setEvent = '$baseUrl/myPage/setEvent';

  static const String getCategories = '$baseUrl/cost/getCategories';
  static const String getCheckLists = '$baseUrl/cost/getCheckLists';
  static const String getCheckListDetail = '$baseUrl/cost/getCheckListDetail';
  static const String setChecklist = '$baseUrl/cost/setChecklist';
  static const String updateChecklist = '$baseUrl/cost/updateChecklist';
  static const String deleteChecklist = '$baseUrl/cost/deleteChecklist';

  static const String getContract = '$baseUrl/contract/getContract';
  static const String setContract = '$baseUrl/contract/setContract';
  static const String getContractDetail = '$baseUrl/contract/getContractDetail';
  static const String delContract = '$baseUrl/contract/delContract';
  static const String setOcrCount = '$baseUrl/contract/setOcrCount';

  //static const String webSocketUrl = 'ws://112.222.141.78:8888/ws-stomp';
  static const String webSocketUrl = 'ws://192.168.3.50:8888/ws-stomp';

}