import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/cupertino.dart';

class DDayManagementPage extends StatefulWidget {
  @override
  _DDayManagementPageState createState() => _DDayManagementPageState();
}

class _DDayManagementPageState extends State<DDayManagementPage> {
  List<DDayCard> ddayCards = [
    DDayCard(
      days: 'D-113',
      description: '본식',
      date: '2024.09.01',
      imagePath: 'asset/img/wed_01.jpg',
      cardColor: Color.fromRGBO(255, 222, 246, 1.0),
      onEditDescription: (String newDescription) {},
      onDateChanged: (String newDate) {},
      onDelete:() {},
    ),
    DDayCard(
      days: 'D+446',
      description: '처음 만난날',
      date: '2024.09.01',
      imagePath: 'asset/img/wed_01.jpg',
      cardColor: Color.fromRGBO(192, 249, 252, 1.0),
      onEditDescription: (String newDescription) {},
      onDateChanged: (String newDate) {},
      onDelete:() {},
    ),
    DDayCard(
      days: 'D-23',
      description: '촬영',
      date: '2024.09.01',
      imagePath: 'asset/img/wed_01.jpg',
      cardColor: Color.fromRGBO(255, 242, 166, 1.0),
      onEditDescription: (String newDescription) {},
      onDateChanged: (String newDate) {},
      onDelete:() {},
    ),
  ];

  void _addNewDDayCard() {
    setState(() {
      ddayCards.add(
        DDayCard(
          days: 'D-23',
          description: '촬영',
          date: '2024.09.01',
          imagePath: 'asset/img/wed_01.jpg',
          cardColor: Color.fromRGBO(255, 242, 166, 1.0),
          onEditDescription: (String newDescription) {},
          onDateChanged: (String newDate) {},
          onDelete:() {},
        ),
      );
    });
  }
  void _updateCardDate(int index, String newDate) {
    setState(() {
      ddayCards[index].date = newDate;

      // Calculate days difference
      DateTime pickedDate = DateTime.parse(newDate.replaceAll('.', '-'));
      DateTime now = DateTime.now();
      int difference = pickedDate.difference(now).inDays;
      ddayCards[index].days = difference >= 0 ? 'D+${difference.abs()}' : 'D-${difference.abs()}';
    });
  }

  void _deleteDDayCard(int index) {
    setState(() {
      ddayCards.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text('디데이 관리'),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ...ddayCards.asMap().entries.map((entry) {
            int index = entry.key;
            DDayCard card = entry.value;
            return DDayCard(
              days: card.days,
              description: card.description,
              date: card.date,
              imagePath: card.imagePath,
              cardColor: card.cardColor,
              onEditDescription: (String newDescription) {
                setState(() {
                  ddayCards[index].description = newDescription;
                });
              },
              onDateChanged: (String newDate) {
                _updateCardDate(index, newDate);
              },
              onDelete: () {
                _deleteDDayCard(index);
              },
            );
          }).toList(),
          SizedBox(height: 20),
          Center(
            child: Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text(
                  '추가하기',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _addNewDDayCard,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DDayCard extends StatefulWidget {
  String days;
  String description;
  String date;
  final String imagePath;
  Color cardColor;
  final Function(String) onEditDescription;
  final Function(String) onDateChanged;
  final VoidCallback onDelete;

  DDayCard({
    required this.days,
    required this.description,
    required this.date,
    required this.imagePath,
    required this.cardColor,
    required this.onEditDescription,
    required this.onDateChanged,
    required this.onDelete,
  });

  @override
  _DDayCardState createState() => _DDayCardState();
}

class _DDayCardState extends State<DDayCard> {
  bool _isEditingDescription = false;
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.description;
  }

  void _toggleEditing() {
    setState(() {
      _isEditingDescription = !_isEditingDescription;
    });
  }

  void _finalizeEditing() {
    setState(() {
      _isEditingDescription = false;
      widget.onEditDescription(_descriptionController.text);
    });
  }

  void showColorPicker(BuildContext context, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = Colors.white;
        return AlertDialog(
          title: Text('배경 색상 변경'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('확인'),
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery
              .of(context)
              .size
              .height / 3,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime.now(),
            minimumDate: DateTime(2000),
            maximumDate: DateTime(2101),
            onDateTimeChanged: (pickedDate) {
              if (pickedDate != null) {
                // Format the pickedDate to 'yyyy.MM.dd' format
                String formattedDate = '${pickedDate.year}.${pickedDate.month
                    .toString().padLeft(2, '0')}.${pickedDate.day.toString()
                    .padLeft(2, '0')}';
                widget.onDateChanged(formattedDate);

                // Calculate days difference
                DateTime now = DateTime.now();
                int difference = pickedDate
                    .difference(now)
                    .inDays;
                String daysLabel = difference >= 0
                    ? 'D+${difference.abs()}'
                    : 'D-${difference.abs()}';

                // Update days in the widget state
                setState(() {
                  widget.days = daysLabel;
                });
              }
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isEditingDescription) {
          _finalizeEditing();
        }
      },
      child: Card(
        color: widget.cardColor,
        child: Stack(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 60.0,
                backgroundImage: AssetImage(widget.imagePath),
              ),
              title: Text(widget.days,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      _toggleEditing();
                    },
                    child: _isEditingDescription
                        ? TextField(
                      controller: _descriptionController,
                      onSubmitted: (newDescription) {
                        setState(() {
                          _isEditingDescription = false;
                          widget.onEditDescription(newDescription);
                        });
                      },
                    )
                        : Text(widget.description,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      Text(widget.date),
                      IconButton(
                        icon: Icon(Icons.arrow_drop_down, size: 16),
                        onPressed: () {
                          _pickDate(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Colors.black),
                onPressed: () {
                  showColorPicker(context, (Color color) {
                    setState(() {
                      widget.cardColor = color;
                    });
                  });
                },
              ),
            ),
            Positioned(
              bottom: 80,
              left: 320,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black),
                onPressed: widget.onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
