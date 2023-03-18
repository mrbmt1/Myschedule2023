import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myshedule/birthdaylist.dart';
import 'package:myshedule/calendar.dart';
import 'package:myshedule/event.dart';
import 'package:myshedule/group_schedule.dart';
import 'package:myshedule/search.dart';
import 'edit_task.dart';
import 'main.dart';
import 'profile.dart';
import 'create_task.dart';
import 'edit_task.dart';
import 'package:myshedule/todolist.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:ui' as ui;
import 'package:unorm_dart/unorm_dart.dart';
import 'setting.dart';
import 'task_widget.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;

//log out function
void logout(BuildContext context) async {
  bool confirm = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Đăng xuất"),
      content: Text("Bạn muốn đăng xuất khỏi tài khoản?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text("Không"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text("Có"),
        ),
      ],
    ),
  );
  if (confirm == true) {
    // Đăng xuất khỏi Firebase Authentication
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainApp()),
    );
  }
}

//Hàm hiển thị thông báo khi bấm vào icon chuông thông báo
showNotificationDialog(BuildContext context, TodoItem todo) async {
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
                  .collection('tasks')
                  .doc(todo.id)
                  .update({'isNotification': false});
              if (todo.isNotification) {
                FlutterLocalNotificationsPlugin().cancel(todo.notificationID);
              }
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Đặt lại giờ thông báo'),
            onPressed: () async {
              var newTime = await showTimePicker(
                context: context,
                initialTime: todo.timeNotification ?? TimeOfDay.now(),
              );
              if (newTime != null) {
                var notificationTime = todo.getDateTime();
                notificationTime = DateTime(
                  notificationTime.year,
                  notificationTime.month,
                  notificationTime.day,
                  newTime.hour,
                  newTime.minute,
                );
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(todo.id)
                    .update({
                  'timeNotification': newTime.format(context),
                  'isNotification': true,
                });
                if (todo.isNotification) {
                  FlutterLocalNotificationsPlugin().cancel(todo.notificationID);
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

class TodoItem {
  final String id;
  final String content;
  bool completed;
  DateTime? date;
  String? description;
  TimeOfDay? time;
  TimeOfDay? timeNotification;
  bool isNotification;
  int notificationID;

  TodoItem({
    required this.id,
    required this.content,
    this.completed = false,
    this.description,
    required this.notificationID,
    this.date,
    this.time,
    this.timeNotification,
    this.isNotification = false,
  }) : assert(id != null);

  DateTime getDateTime() {
    final now = DateTime.now();
    final year = date?.year ?? now.year;
    final month = date?.month ?? now.month;
    final day = date?.day ?? now.day;
    final hour = time?.hour ?? TimeOfDay.now().hour;
    final minute = time?.minute ?? TimeOfDay.now().minute;
    return DateTime(year, month, day, hour, minute);
  }

  factory TodoItem.fromSnapshot(DocumentSnapshot snapshot) {
    var timeFromSnapshot = snapshot['timeOfDueDay'];
    TimeOfDay? time;

    if (timeFromSnapshot is String) {
      time = TimeOfDay(
        hour: DateFormat('HH:mm').parse(timeFromSnapshot).hour,
        minute: DateFormat('HH:mm').parse(timeFromSnapshot).minute,
      );
    } else if (timeFromSnapshot != null) {
      time = TimeOfDay(
        hour: timeFromSnapshot.hour,
        minute: timeFromSnapshot.minute,
      );
    }

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

    return TodoItem(
      id: snapshot.id,
      notificationID: snapshot['notificationID'],
      content: snapshot['description'] ?? '',
      completed: snapshot['completed'] ?? false,
      date: snapshot['dueDate']?.toDate(),
      time: time, // assign parsed time directly to the time field
      timeNotification: timeNotification,
      isNotification: snapshot['isNotification'],
    );
  }
}

class TodoListScreen extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _showNotification(
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
        child: Text('Vui lòng đăng nhập để xem danh sách task'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách lịch của tôi'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              icon: Icon(Icons.search))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Menu'),
              decoration: BoxDecoration(),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Thông tin người dùng'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.loop_outlined),
              title: Text('Thời gian biểu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ScheduleScreen()),
                );
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.groups_2),
            //   title: Text('Lịch chung'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => GroupSchdeduleScreen()),
            //     );
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.cake),
              title: Text('Sinh nhật'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BirthdayScreen()),
                );
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.local_activity_rounded),
            //   title: Text('Sự kiện'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => EventScreen()),
            //     );
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Cài đặt'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Đăng xuất'),
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('userID', isEqualTo: currentUser.uid)
            .orderBy('timeOfDueDay')
            .orderBy('dueDate')
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

          List<TodoItem> todoList = snapshot.data!.docs
              .map((doc) => TodoItem.fromSnapshot(doc))
              .toList();

          final now = DateTime.now();
          List<TodoItem> beforeList = [];
          List<TodoItem> todayList = [];
          List<TodoItem> afterList = [];

          todoList.forEach((item) {
            DateTime itemDate =
                DateTime(item.date!.year, item.date!.month, item.date!.day);
            DateTime nowDate = DateTime(now.year, now.month, now.day);

            if (itemDate.isBefore(nowDate)) {
              beforeList.add(item);
            } else if (itemDate.isAtSameMomentAs(nowDate)) {
              todayList.add(item);
            } else {
              afterList.add(item);
            }

//thông báo của từng task nếu isNotification = true
            if (item.isNotification) {
              final notificationTime = tz.TZDateTime(
                tz.local,
                item.date!.year,
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
                item.time!.hour,
                item.time!.minute,
              );
              final timeFormat = DateFormat.Hm();
              final dateFormat = DateFormat('dd/MM/yyyy');
              _showNotification(
                'Bạn có lịch: ${item.content}',
                'Hạn chót lúc: ${timeFormat.format(time)} ${dateFormat.format(item.date!)}',
                notificationTime,
                notificationId,
              );
            }
          });

// Sắp xếp danh sách theo ngày hạn
          beforeList
              .sort((a, b) => a.getDateTime()!.compareTo(b.getDateTime()!));
          todayList
              .sort((a, b) => a.getDateTime()!.compareTo(b.getDateTime()!));
          afterList
              .sort((a, b) => a.getDateTime()!.compareTo(b.getDateTime()!));
          // Kiểm tra xem phần đang hiển thị có phải là phần trống hay không
          Widget? emptyListWidget;
          if (todoList.isEmpty) {
            emptyListWidget = Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text('Không có công việc nào trong danh sách'),
              ),
            );
          }

// Giao diện single task
          return ListView(
            children: [
              if (beforeList.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildSection(context, 'Những ngày trước', beforeList),
                ),
              if (todayList.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: _buildSection(context, 'Hôm nay', todayList),
                ),
              if (afterList.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Bo tròn cạnh của Card
                  ),
                  child: _buildSection(context, 'Những ngày sau', afterList),
                ),
              if (emptyListWidget != null) emptyListWidget,
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.note_add_rounded),
        onPressed: () async {
          TodoItem? newTodo = await Navigator.push<TodoItem?>(
            context,
            MaterialPageRoute(builder: (context) => CreateTaskScreen()),
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

  Widget _buildSection(
      BuildContext context, String title, List<TodoItem> todoList) {
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
          itemCount: todoList.length,
          itemBuilder: (context, index) {
            TodoItem todoItem = todoList[index];
            return TaskWidget(todo: todoItem);
          },
        ),
      ],
    );
  }
}
