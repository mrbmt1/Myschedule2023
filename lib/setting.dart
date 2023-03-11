import 'package:flutter/material.dart';
import 'package:myshedule/about.dart';
import 'package:myshedule/feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localizations/app_localizations.dart';
import 'change_password.dart';

class SettingsScreen extends StatelessWidget {
  // const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          Divider(),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Giao diện tối'),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Đổi mật khẩu'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChangePasswordScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Hỗ trợ và phản hổi'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FeedBackScreen()),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Thông tin ứng dụng'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AboutAppScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
