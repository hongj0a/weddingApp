import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now().toLocal();
  DateTime? _selectedDay;
  List<String> scheduleDate = [];
  ApiService apiService = ApiService();


  final Map<DateTime, List<Map<String, String>>> _events = {};
  List<Map<String, dynamic>> _tmpEvents = [];


  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    initializeDateFormatting('ko_KR').then((_) {
      _fetchSchedule();
      _fetchSchedulesForDate(DateFormat('yyyy-MM-dd').format(_selectedDay!));
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
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

      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay!);
      try {
        var response = await apiService.post(
          ApiConstants.setSchedule,
          data: {
            'date': formattedDate,
            'memo': event,
            'time': time,
          },
        );

        if (response.statusCode == 200) {
          print('Schedule saved successfully');
          await _fetchSchedule();
          await _fetchSchedulesForDate(formattedDate);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event 저장 실패: $e', style: TextStyle( ))),
        );
      }

    }
  }

  Future<void> _fetchSchedule() async {
    try {
      String month = DateFormat('yyyy-MM').format(_focusedDay);

      var response = await apiService.get(
        ApiConstants.getScheduleMark,
        queryParameters: {'month': month },

      );

      if (response.statusCode == 200) {
        var responseBody = response.data;

        List<dynamic> scheduleMarks = responseBody['data']['scheduleMarks'] ?? [];

        setState(() {
          _events.clear();
          scheduleDate.clear();
          for (var schedule in scheduleMarks) {
            String date = schedule['date'];
            scheduleDate.add(date);

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
        SnackBar(content: Text('스케줄을 불러오지 못했습니다: $e', style: TextStyle( ))),
      );
    }
  }

  Future<void> _fetchSchedulesForDate(String selectedDate) async {
    try {
      print('selectedDate ... $selectedDate');
      var response = await apiService.get(
        ApiConstants.getSchedules,
        queryParameters: {'date': selectedDate}
      );

      if (response.statusCode == 200) {
        var responseBody = response.data;
        List<dynamic> schedules = responseBody['data']['schedules'] ?? [];

        setState(() {
          if (schedules.isNotEmpty) {
            _tmpEvents = schedules.map((schedule) {
              return {
                'seq': schedule['seq'] as String,
                'event': schedule['memo'] as String,
                'time': schedule['time'] as String,
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
        SnackBar(content: Text('스케줄을 불러오지 못했습니다: $e', style: TextStyle( ))),
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
                onDaySelected: _onDaySelected,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _fetchSchedule();
                },
                eventLoader: (day) {
                  return _events[day] ?? [];
                },
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  headerMargin: EdgeInsets.symmetric(vertical: 10.0),
                  titleCentered: true,
                  titleTextStyle: TextStyle(

                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primaryColor,
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
                    String currentMonth = DateFormat('yyyy-MM').format(_focusedDay);
                    String dayMonth = DateFormat('yyyy-MM').format(day);
                    String dayString = day.day.toString().padLeft(2, '0');

                    if (currentMonth == dayMonth && scheduleDate.contains(dayString)) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Icon(
                          Icons.favorite,
                          size: 16.0,
                          color: AppColors.primaryColor,
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
                style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              backgroundColor: Colors.white,
              content: Text(
                "$event를 삭제하시겠어요?",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "취소",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(AppColors.primaryColor),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    "삭제",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        try {
          var response = await apiService.post(
          ApiConstants.delSchedule,
            data: {'seq': seq},
          );

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$event가 삭제되었습니다.', style: TextStyle( ))),
            );

            /*scheduleDate = []; // 먼저 빈 배열로 초기화
            _fetchSchedule(); // 또는 _fetchSchedulesForDate(DateFormat('yyyy-MM-dd').format(_selectedDay!));
            scheduleDate = getScheduleDatesFromEvents();*/

            setState(() {
              _tmpEvents.removeAt(index);
            });

            scheduleDate.clear();

            await _fetchSchedule();
            await _fetchSchedulesForDate(DateFormat('yyyy-MM-dd').format(_selectedDay!));

            setState(() {});

          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('삭제 실패: ${response.data}', style: TextStyle( ))),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 중 오류 발생: $e', style: TextStyle( ))),
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

                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              time,
              style: TextStyle(

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
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '새로운 이벤트',
                        style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: eventController,
                        decoration: InputDecoration(
                          hintText: '일정 내용을 입력하세요.',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[500]!),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        maxLines: null,
                        minLines: 7,
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
                            child: Text('시간 선택', style: TextStyle(color: Colors.black)),
                          ),
                          Text(
                            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(  fontSize: 18, fontWeight: FontWeight.bold),
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
                            child: Text("취소", style: TextStyle(color: Colors.black)),
                          ),
                          SizedBox(width: 8.0),
                          TextButton(
                            onPressed: () {
                              final String event = eventController.text;
                              final String time = '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}';
                              if (event.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('일정 내용을 입력해주세요.', style: TextStyle(color: Colors.white)),
                                    backgroundColor: Colors.black,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              _addEvent(event, time);
                              Navigator.of(context).pop();
                            },
                            child: Text("추가", style: TextStyle(color: Colors.black)),
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
