import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myshedule/school_schedule/sun_school_schedule.dart';
import 'package:myshedule/school_schedule/tue_school_schedule.dart';

class MonDayScheduleScreen extends StatefulWidget {
  const MonDayScheduleScreen({Key? key}) : super(key: key);

  @override
  _MonDayScheduleScreenState createState() => _MonDayScheduleScreenState();
}

class _MonDayScheduleScreenState extends State<MonDayScheduleScreen> {
  late List<int> _periods;
  late List<int> _periodsNumber;
  final CollectionReference scheduleCollection =
      FirebaseFirestore.instance.collection('monday_schedule');

  @override
  void initState() {
    super.initState();
    _periods = List.generate(12, (index) => index + 1);
    _periodsNumber = List.generate(12, (index) => index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thời khóa biểu'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Thứ 2',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (DateFormat('EEEE').format(DateTime.now()) == 'Monday')
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
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: GestureDetector(
          child: ListView(
            children: [
              SizedBox(height: 10),
              Text(
                'Sáng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Container(
                        height: 50,
                        width: 80,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tiết ${_periodsNumber[index]}',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 50,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Tên tiết ${_periods[index]}',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Chiều',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Container(
                        height: 50,
                        width: 80,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tiết ${_periodsNumber[index] + 5}',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 50,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Tên tiết ${_periods[index + 5]}',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              Text(
                'Tối',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Container(
                        height: 50,
                        width: 80,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tiết ${_periodsNumber[index] + 10}',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 50,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Tên tiết ${_periods[index + 10]}',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.save),
      ),
    );
  }
}
