import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myshedule/school_schedule/sun_school_schedule.dart';
import 'package:myshedule/school_schedule/thu_school_schedule.dart';
import 'package:myshedule/school_schedule/tue_school_schedule.dart';

class WednesDayScheduleScreen extends StatefulWidget {
  const WednesDayScheduleScreen({Key? key}) : super(key: key);

  @override
  _WednesDayScheduleScreenState createState() =>
      _WednesDayScheduleScreenState();
}

class _WednesDayScheduleScreenState extends State<WednesDayScheduleScreen> {
  final _subject1 = TextEditingController();
  final _subject2 = TextEditingController();
  final _subject3 = TextEditingController();
  final _subject4 = TextEditingController();
  final _subject5 = TextEditingController();
  final _subject6 = TextEditingController();
  final _subject7 = TextEditingController();
  final _subject8 = TextEditingController();
  final _subject9 = TextEditingController();
  final _subject10 = TextEditingController();
  final _subject11 = TextEditingController();
  final _subject12 = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadWednesdayData();
  }

  void _updateSchedule() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .doc(currentUser?.uid)
        .get();
    final data = snapshot.data();

    Map<String, dynamic> scheduleData = {
      'wednesday': {
        'subject1': _subject1.text,
        'subject2': _subject2.text,
        'subject3': _subject3.text,
        'subject4': _subject4.text,
        'subject5': _subject5.text,
        'subject6': _subject6.text,
        'subject7': _subject7.text,
        'subject8': _subject8.text,
        'subject9': _subject9.text,
        'subject10': _subject10.text,
        'subject11': _subject11.text,
        'subject12': _subject12.text,
      },
    };

    try {
      if (data != null) {
        await FirebaseFirestore.instance
            .collection('schedules')
            .doc(currentUser?.uid)
            .update(scheduleData);
      } else {
        await FirebaseFirestore.instance
            .collection('schedules')
            .doc(currentUser?.uid)
            .set(scheduleData);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thời khóa biểu thứ tư thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại!')),
      );
    }
  }

  void loadWednesdayData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .doc(currentUser?.uid)
        .get();
    final data = snapshot.data();

    if (data != null && data['wednesday'] != null) {
      setState(() {
        _subject1.text = data['wednesday']['subject1'] ?? '';
        _subject2.text = data['wednesday']['subject2'] ?? '';
        _subject3.text = data['wednesday']['subject3'] ?? '';
        _subject4.text = data['wednesday']['subject4'] ?? '';
        _subject5.text = data['wednesday']['subject5'] ?? '';
        _subject6.text = data['wednesday']['subject6'] ?? '';
        _subject7.text = data['wednesday']['subject7'] ?? '';
        _subject8.text = data['wednesday']['subject8'] ?? '';
        _subject9.text = data['wednesday']['subject9'] ?? '';
        _subject10.text = data['wednesday']['subject10'] ?? '';
        _subject11.text = data['wednesday']['subject11'] ?? '';
        _subject12.text = data['wednesday']['subject12'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thời khóa biểu'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: GestureDetector(
          child: ListView(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Thứ 4',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (DateFormat('EEEE').format(DateTime.now()) == 'Wednesday')
                    Text(
                      ' (hôm nay)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 20,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 2),
              Text(
                'Sáng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 1',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject1,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 2',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject2,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 3',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject3,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 4',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject4,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 5',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Chiều',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 6',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject6,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 7',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject7,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 8',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject8,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 9',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject9,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 10',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject10,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Tối',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 11',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject11,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 80,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Tiết 12',
                          border: OutlineInputBorder(),
                          enabled: false),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: TextFormField(
                        controller: _subject12,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _updateSchedule();
        },
        child: Icon(Icons.save_as_rounded),
      ),
    );
  }
}
