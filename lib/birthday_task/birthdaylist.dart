import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'birthday_widget.dart';
import 'create_birthday_taks.dart';

//Hàm hiển thị thông báo khi bấm vào icon chuông thông báo
showBDNotificationDialog(
    BuildContext context, BirthDayItem birthdayTodo) async {
  var result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Thông báo'),
        content: Text('Bạn muốn tắt thông báo hay đặt lại giờ thông báo?'),
        actions: <Widget>[
          TextButton(
            child: Text('Tắt thông báo'),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('birthdays')
                  .doc(birthdayTodo.id)
                  .update({'isNotification': false});
              if (birthdayTodo.isNotification) {
                FlutterLocalNotificationsPlugin()
                    .cancel(birthdayTodo.notificationID);
              }
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Đặt lại giờ thông báo'),
            onPressed: () async {
              var newTime = await showTimePicker(
                context: context,
                initialTime: birthdayTodo.timeNotification ?? TimeOfDay.now(),
              );
              if (newTime != null) {
                var notificationTime = birthdayTodo.getDateTime();
                notificationTime = DateTime(
                  notificationTime.year,
                  notificationTime.month,
                  notificationTime.day,
                  newTime.hour,
                  newTime.minute,
                );
                FirebaseFirestore.instance
                    .collection('birthdays')
                    .doc(birthdayTodo.id)
                    .update({
                  'timeNotification': newTime.format(context),
                  'isNotification': true,
                });
                if (birthdayTodo.isNotification) {
                  FlutterLocalNotificationsPlugin()
                      .cancel(birthdayTodo.notificationID);
                }
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class BirthDayItem {
  final String id;
  final String content;
  DateTime? date;
  String? description;
  TimeOfDay? timeNotification;
  bool isNotification;
  int notificationID;

  BirthDayItem({
    required this.id,
    required this.content,
    this.description,
    required this.notificationID,
    this.date,
    this.timeNotification,
    this.isNotification = false,
  }) : assert(id != null);

  DateTime getDateTime() {
    final now = DateTime.now();
    final year = date?.year ?? now.year;
    final month = date?.month ?? now.month;
    final day = date?.day ?? now.day;
    return DateTime(year, month, day);
  }

  factory BirthDayItem.fromSnapshot(DocumentSnapshot snapshot) {
    // var timeFromSnapshot = snapshot['birthDay'];
    // TimeOfDay? time;

    var timeNotificationFromSnapshot = snapshot['timeNotification'];
    TimeOfDay? timeNotification;
    if (timeNotificationFromSnapshot is String) {
      timeNotification = TimeOfDay(
        hour: DateFormat('HH:mm').parse(timeNotificationFromSnapshot).hour,
        minute: DateFormat('HH:mm').parse(timeNotificationFromSnapshot).minute,
      );
    } else if (timeNotificationFromSnapshot != null) {
      timeNotification = TimeOfDay(
        hour: timeNotificationFromSnapshot.hour,
        minute: timeNotificationFromSnapshot.minute,
      );
    }

    return BirthDayItem(
      id: snapshot.id,
      notificationID: snapshot['notificationID'],
      content: snapshot['description'] ?? '',
      date: snapshot['birthDay']?.toDate(),
      timeNotification: timeNotification,
      isNotification: snapshot['isNotification'],
    );
  }
}

class BirthdayScreen extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _showBirthDayNotification(
    String title,
    String message,
    DateTime notificationTime,
    int notificationId,
  ) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {},
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      'channel_description',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      message,
      tz.TZDateTime.from(notificationTime, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'default',
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Center(
        child: Text('Vui lòng đăng nhập để xem danh sách sinh nhật'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách sinh nhật'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('birthdays')
            .where('userID', isEqualTo: currentUser.uid)
            .orderBy('birthDay')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<BirthDayItem> birthdayList = snapshot.data!.docs
              .map((doc) => BirthDayItem.fromSnapshot(doc))
              .toList();

          final now = DateTime.now();
          List<List<BirthDayItem>> birthDayItemsByMonth =
              List.generate(12, (index) => []);

          birthdayList.forEach((item) {
            DateTime itemDate =
                DateTime(item.date!.year, item.date!.month, item.date!.day);
            DateTime nowDate = DateTime(now.year, now.month, now.day);

            if (item.isNotification) {
              final now = DateTime.now();
              final notificationTime = tz.TZDateTime(
                tz.local,
                now.year,
                item.date!.month,
                item.date!.day,
                item.timeNotification!.hour,
                item.timeNotification!.minute,
              );
              final notificationId = item.notificationID;
              final time = DateTime(
                item.date!.year,
                item.date!.month,
                item.date!.day,
              );
              final timeFormat = DateFormat.Hm();
              final dateFormat = DateFormat('dd/MM/yyyy');
              _showBirthDayNotification(
                'Hôm nay có ${item.content}',
                'Sinh nhật ngày: ${dateFormat.format(item.date!)}',
                notificationTime,
                notificationId,
              );
            }
            if (itemDate.month <= 12 && itemDate.month >= 1) {
              birthDayItemsByMonth[itemDate.month - 1].add(item);
            }

            List<BirthDayItem> birthdayList = snapshot.data!.docs
                .map((doc) => BirthDayItem.fromSnapshot(doc))
                .toList();
          });
          Widget? emptyListWidget;
          if (birthdayList.isEmpty) {
            emptyListWidget = Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text('Không có sinh nhật nào trong danh sách'),
              ),
            );
          }
          return ListView(
            children: [
              for (int i = 0; i < 12; i++)
                if (birthDayItemsByMonth[i].isNotEmpty)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildBirthDaySection(
                        context, 'Tháng ${i + 1}', birthDayItemsByMonth[i]),
                  ),
              if (emptyListWidget != null) emptyListWidget,
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.cake),
        onPressed: () async {
          BirthDayItem? newTodo = await Navigator.push<BirthDayItem?>(
            context,
            MaterialPageRoute(builder: (context) => CreateBirthDayTaskScreen()),
          );
          if (newTodo != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã thêm task mới')),
            );
          }
        },
      ),
    );
  }

  Widget _buildBirthDaySection(
      BuildContext context, String title, List<BirthDayItem> birthdayList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: birthdayList.length,
          itemBuilder: (context, index) {
            BirthDayItem birthayItem = birthdayList[index];
            return BirthDayWidget(birthdayTodo: birthayItem);
          },
        ),
      ],
    );
  }
}
