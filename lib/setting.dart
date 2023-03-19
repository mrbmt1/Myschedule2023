import 'package:flutter/material.dart';
import 'package:myshedule/setting_option/about.dart';
import 'package:myshedule/setting_option/change_password.dart';
import 'package:myshedule/setting_option/feedback.dart';
import 'package:myshedule/setting_option/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localizations/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  // const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          Divider(),
          ListTile(
            leading: Icon(Icons.nightlight_round),
            title: Text('Chế độ tối'),
            trailing: Switch(
              value: themeNotifier.darkTheme,
              onChanged: (value) {
                themeNotifier.toggleTheme();
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setBool('darkTheme', value);
                });
              },
            ),
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
