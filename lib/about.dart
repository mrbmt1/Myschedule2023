import 'package:flutter/material.dart';

class AboutAppScreen extends StatefulWidget {
  @override
  _AboutAppScreenState createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin ứng dụng'),
      ),
      body: Padding(
        padding: EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên tài khoản:Tên ứng dụng:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('MySchedule', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 16.0),
            Text('Chức năng',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text(
                'Ứng dụng được tạo ra để hỗ trợ người trong việc lập lịch biểu hoặc các ghi chú \nvà cả trong công cuộc kiếm việc làm của tôi nữa -_-',
                style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 16.0),
            Text('Phiên bản:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('1.0', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 16.0),
            Text('Ngày phát hành:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('Chưa xác định', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 16.0),
            Text('Tên người tạo app:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('Bùi Minh Thương', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 16.0),
            Text('Email chủ app',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('mrbmt1@gmail.com', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
