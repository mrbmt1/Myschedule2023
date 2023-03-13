// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:myshedule/main.dart';

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   static const String _title = 'Flutter Push Notification';

//   @override
//   Widget build(BuildContext context) {
//     final AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'your channel id',
//       'your channel name',
//       'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//       channelShowBadge: true,
//       largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
//       playSound: true,
//       sound: RawResourceAndroidNotificationSound('notification'),
//       autoCancel: false,
//       fullScreenIntent: true,
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(_title),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text('Gửi thông báo đẩy'),
//           onPressed: () async {
//             await _showNotification(androidPlatformChannelSpecifics);
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> _showNotification(
//       AndroidNotificationDetails androidPlatformChannelSpecifics) async {
//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     final android = AndroidNotificationDetails(
//       'your channel id',
//       'your channel name',
//       'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//       channelShowBadge: true,
//       largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
//       playSound: true,
//       sound: RawResourceAndroidNotificationSound('notification'),
//       autoCancel: false,
//       fullScreenIntent: true,
//     );
//     final IOSNotificationDetails iOS = IOSNotificationDetails();

//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'Thông báo đẩy',
//       'Đây là một thông báo đẩy',
//       platformChannelSpecifics,
//       payload: 'item x',
//       // android: android,
//       // iOS: iOS,
//       // Add the FLAG_IMMUTABLE flag here
//       // FLAG_IMMUTABLE: PendingIntent.FLAG_IMMUTABLE
//     );
//   }
// }

// void main() {
//   runApp(const MaterialApp(
//     title: 'Flutter Push Notification',
//     home: MyHomePage(),
//   ));
// }
