import 'package:flutter/material.dart';

class FeedBackScreen extends StatefulWidget {
  @override
  _FeedBackScreenState createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hỗ trợ và phản hồi'),
      ),
      body: Padding(
        padding: EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mọi yêu cầu về hỗ trợ và phản hồi xin liên hệ:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('Email: mrbmt1@gmail.com', style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8.0),
            Text('Số điện thoại: 03x 46x 022x',
                style: TextStyle(fontSize: 16.0)),
            SizedBox(height: 8.0),
            Text(
                'Địa chỉ: Văn phòng CTy TNHH VINATech, tòa nhà số 69, LandMark 81, VN',
                style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
    );
  }
}
