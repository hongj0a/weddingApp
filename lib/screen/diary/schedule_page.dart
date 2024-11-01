import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../config/ApiConstants.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now().toLocal(); // 현재 로컬 시간
  DateTime? _selectedDay;
  List<String> scheduleDate = [];


  final Map<DateTime, List<Map<String, String>>> _events = {};
  List<Map<String, dynamic>> _tmpEvents = [];


  @override
  void initState() {
    super.initState();
    // 현재 날짜를 기본 선택 날짜로 설정
    _selectedDay = DateTime.now();
    initializeDateFormatting('ko_KR').then((_) {
      // 로케일 초기화 완료 후 _fetchSchedule() 등을 호출
      _fetchSchedule();
      _fetchSchedulesForDate(DateFormat('yyyy-MM-dd').format(_selectedDay!));
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
    // 선택된 날짜에 맞는 스케줄 호출
    _fetchSchedulesForDate(DateFormat('yyyy-MM-dd').format(selectedDay));
  }

  void _addEvent(String event, String time) async{
    if (_selectedDay != null) {
      if (_events[_selectedDay!] == null) {
        _events[_selectedDay!] = [];
      }
      setState(() {
        _events[_selectedDay!]!.add({'event': event, 'time': time});
      });

      // 선택된 날짜, 메모(event), 시간(time)을 API에 저장
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? accessToken = prefs.getString('accessToken');

        if (accessToken == null) {
          throw Exception('No access token found');
        }

        var url = Uri.parse(ApiConstants.setSchedule);

        var response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json', // JSON 형식의 데이터 전송
          },
          body: jsonEncode({
            'date': formattedDate,
            'memo': event,
            'time': time,
          }),
        );

        if (response.statusCode == 200) {
          print('Schedule saved successfully');
          await _fetchSchedule();
          await _fetchSchedulesForDate(formattedDate);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event 저장 실패: $e', style: TextStyle(fontFamily: 'PretendardVariable'))),
        );
      }

    }
  }

  Future<void> _fetchSchedule() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      // 현재 월의 시작일과 마지막 일 계산
      //DateTime now = DateTime.now();
      String month = DateFormat('yyyy-MM').format(_focusedDay); // "2024-10" 형식으로 전달

      print('month... $month');
      var url = Uri.parse('${ApiConstants.getScheduleMark}?month=$month');


      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // 응답이 List인지 확인
        var responseBody = jsonDecode(response.body);

        // responseBody가 List인지 체크하고 null인 경우 빈 리스트로 초기화
        List<dynamic> scheduleMarks = responseBody['data']['scheduleMarks'] ?? [];

        setState(() {
          _events.clear();
          scheduleDate.clear();
          for (var schedule in scheduleMarks) {
            String date = schedule['date'];
            scheduleDate.add(date);  // scheduleDate 배열에 날짜 추가

            // 만약 _events에 특정 날짜 관련 작업을 하고 싶다면
            DateTime formattedDate = DateTime(_focusedDay.year, _focusedDay.month, int.parse(date));

            if (_events[formattedDate] == null) {
              _events[formattedDate] = [];
            }
          }
        });


        print('scheduleDate Array: $scheduleDate');

      } else {
        print('Failed to fetch schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('스케줄을 불러오지 못했습니다: $e', style: TextStyle(fontFamily: 'PretendardVariable'))),
      );
    }
  }

  // 해당 날짜에 대해 API 호출하여 데이터를 가져오는 함수
  Future<void> _fetchSchedulesForDate(String selectedDate) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      print('selectedDate ... $selectedDate');
      // API 호출
      var url = Uri.parse('${ApiConstants.getSchedules}?date=$selectedDate');
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // 응답에서 스케줄 리스트 추출
        var responseBody = jsonDecode(response.body);
        List<dynamic> schedules = responseBody['data']['schedules'] ?? [];

        setState(() {
          // 스케줄 리스트가 빈 배열이 아닌 경우에만 _events에 추가
          if (schedules.isNotEmpty) {
            _tmpEvents = schedules.map((schedule) {
              return {
                'seq': schedule['seq'] as String,
                'event': schedule['memo'] as String,  // 메모
                'time': schedule['time'] as String,   // 시간
              };
            }).toList();
          } else {
            _tmpEvents = [];
          }

        });
      } else {
        print('Failed to fetch schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('스케줄을 불러오지 못했습니다: $e', style: TextStyle(fontFamily: 'PretendardVariable'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 01, 01),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: _onDaySelected,  // 날짜 선택 시 호출
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _fetchSchedule();  // 페이지 변경 시마다 스케줄 업데이트
                },
                eventLoader: (day) {
                  return _events[day] ?? [];
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  headerMargin: EdgeInsets.symmetric(vertical: 10.0), // 헤더 여백 조정
                  titleCentered: true, // 제목을 가운데 정렬
                  titleTextStyle: TextStyle(
                    fontFamily: 'PretendardVariable',
                    fontWeight: FontWeight.bold, // 폰트 두껍게 설정
                    fontSize: 20, // 폰트 크기 설정
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color.fromRGBO(250, 15, 156, 1.0),
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                  cellMargin: EdgeInsets.all(4.0),
                  cellPadding: EdgeInsets.all(10.0),
                ),
                locale: 'ko_KR',
                startingDayOfWeek: StartingDayOfWeek.sunday,
                daysOfWeekVisible: true,
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    // 현재 선택된 월을 가져오기
                    String currentMonth = DateFormat('yyyy-MM').format(_focusedDay);
                    String dayMonth = DateFormat('yyyy-MM').format(day);
                    String dayString = day.day.toString().padLeft(2, '0');


                    // 선택된 월과 날짜가 일치하며, 해당 날짜가 scheduleDate에 포함되어 있는지 확인
                    if (currentMonth == dayMonth && scheduleDate.contains(dayString)) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Icon(
                          Icons.favorite,
                          size: 16.0,
                          color: Color.fromRGBO(250, 15, 156, 1.0),
                        ),
                      );
                    }
                    return null;
                  },
                ),



              ),
            ),
            SizedBox(height: 16),
            _selectedDay != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${DateFormat('yyyy년 MM월 dd일').format(_selectedDay!)}',
                style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox(),
            SizedBox(height: 16),
            _selectedDay != null && _tmpEvents.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _tmpEvents.length,
              itemBuilder: (context, index) {
                return _buildEventItem(
                  context,
                  _selectedDay!,
                  _tmpEvents[index]['event']!, // 메모
                  _tmpEvents[index]['time']!,
                  _tmpEvents[index]['seq'],
                  index,
                );
              },
            )
                : SizedBox.shrink(),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _showAddEventDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 10),
                    Text(
                      '새로운 이벤트',
                      style: TextStyle(
                        fontFamily: 'PretendardVariable',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, DateTime day, String event, String time, String seq, int index) {
    return Dismissible(
      key: Key(event),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("삭제 확인", style: TextStyle(fontFamily: 'PretendardVariable')),
              content: Text("$event를 삭제하시겠습니까?", style: TextStyle(fontFamily: 'PretendardVariable')),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("취소", style: TextStyle(fontFamily: 'PretendardVariable')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("삭제", style: TextStyle(fontFamily: 'PretendardVariable')),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        try {
          // API 호출
          var url = Uri.parse(ApiConstants.delSchedule);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? accessToken = prefs.getString('accessToken');

          if (accessToken == null) {
            throw Exception('No access token found');
          }

          var response = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'seq': seq}),
          );

          if (response.statusCode == 200) {
            // 삭제 성공
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$event가 삭제되었습니다.', style: TextStyle(fontFamily: 'PretendardVariable'))),
            );

            // 스케줄 새로고침
            /*scheduleDate = []; // 먼저 빈 배열로 초기화
            // 새로운 데이터를 가져와서 업데이트
            _fetchSchedule(); // 또는 _fetchSchedulesForDate(DateFormat('yyyy-MM-dd').format(_selectedDay!));
            // 업데이트된 scheduleDate를 설정
            scheduleDate = getScheduleDatesFromEvents();*/

            // 스케줄 새로고침
            // 여기서 _tmpEvents에서 현재 인덱스의 이벤트를 삭제합니다.
            setState(() {
              _tmpEvents.removeAt(index); // 현재 인덱스의 이벤트 삭제
            });

            // 스케줄 새로고침
            scheduleDate.clear();

            await _fetchSchedule(); // 스케줄을 새로고침하고
            await _fetchSchedulesForDate(DateFormat('yyyy-MM-dd').format(_selectedDay!)); // 특정 날짜의 스케줄을 다시 가져옵니다.

            // 업데이트된 scheduleDate를 가져옵니다.
            // setState로 UI를 갱신합니다.
            setState(() {}); // UI 업데이트를 위해 setState 호출

            /*final String formattedDate = DateFormat('yyyy-MM-dd').format(day);
            await _fetchSchedule();
            await _fetchSchedulesForDate(formattedDate);*/

          } else {
            // 삭제 실패 시 에러 처리
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('삭제 실패: ${response.body}', style: TextStyle(fontFamily: 'PretendardVariable'))),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 중 오류 발생: $e', style: TextStyle(fontFamily: 'PretendardVariable'))),
          );
        }
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.event, size: 24),
                SizedBox(width: 8),
                Text(
                  event,
                  style: TextStyle(
                    fontFamily: 'PretendardVariable',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              time,
              style: TextStyle(
                fontFamily: 'PretendardVariable',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final TextEditingController eventController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(25.0),
            width: 500,
            height: 450,
            child: SingleChildScrollView( // 추가된 부분
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '새로운 이벤트',
                        style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: eventController,
                        decoration: InputDecoration(
                          hintText: '일정 내용을 입력하세요',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!), // 연한 회색 테두리
                            borderRadius: BorderRadius.circular(8.0), // 테두리 모서리 둥글게
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[500]!), // 포커스된 상태의 테두리 색상
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!), // 활성화된 상태의 테두리 색상
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        maxLines: null, // 자동 높이 조정
                        minLines: 7, // 최소 3줄로 설정
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () async {
                              final TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (pickedTime != null && pickedTime != selectedTime) {
                                setState(() {
                                  selectedTime = pickedTime;
                                });
                              }
                            },
                            child: Text('시간 선택', style: TextStyle(fontFamily: 'PretendardVariable')),
                          ),
                          Text(
                            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontFamily: 'PretendardVariable', fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("취소", style: TextStyle(fontFamily: 'PretendardVariable')),
                          ),
                          SizedBox(width: 8.0),
                          TextButton(
                            onPressed: () {
                              final String event = eventController.text;
                              final String time = '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';
                              _addEvent(event, time);
                              Navigator.of(context).pop();
                            },
                            child: Text("추가", style: TextStyle(fontFamily: 'PretendardVariable')),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

  }


}
