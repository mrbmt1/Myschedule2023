import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myshedule/forgot_password/forgot_password.dart';
import 'package:myshedule/register.dart';
import 'package:myshedule/create_task.dart';
import 'package:myshedule/theme.dart';
import 'package:myshedule/todolist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'localizations/app_localizations.dart';
import 'dart:ui' as ui;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool darkTheme = prefs.getBool('darkTheme') ?? false;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: ThemeConfiguration(child: MainApp()),
    ),
  );
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  User? _currentUser;
  bool rememberMe = false;
  bool _obscureText = true;

  // late Locale _locale;

  Future<void> _saveLoginStatus(bool rememberMe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!rememberMe) {
      await prefs.remove('rememberMe');
    } else {
      await prefs.setBool('rememberMe', true);
    }
  }

  @override
  void initState() {
    super.initState();
    _readLoginStatus();
  }

  Future<void> _readLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
    });
    if (rememberMe) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TodoListScreen()),
        );
      } else {
        setState(() {
          rememberMe = false;
        });
        await _saveLoginStatus(false);
      }
    }
  }

  void _login(BuildContext context) async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin đăng nhập')),
      );
    } else {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: _usernameController.text.trim())
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          final user = userDoc.data();
          final passwordHash = sha256
              .convert(utf8.encode(_passwordController.text.trim()))
              .toString();
          if (rememberMe) {
            // Lưu trạng thái "Lưu đăng nhập" vào SharedPreferences
            await _saveLoginStatus(true);
          }

          if (user['password'] == passwordHash) {
            // Đăng nhập thành công, lưu uid vào biến _currentUser
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: user['email'],
              password: _passwordController.text.trim(),
            );
            setState(() {
              _currentUser = userCredential.user;
            });
            if (rememberMe) {
              // Lưu trạng thái "Lưu đăng nhập" vào SharedPreferences
              await _saveLoginStatus(true);
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TodoListScreen()),
            );
          } else {
            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
              SnackBar(content: Text('Sai mật khẩu')),
            );
          }
        } else {
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            SnackBar(content: Text('Tài khoản không tồn tại')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: themeNotifier.darkTheme ? ThemeMode.dark : ThemeMode.light,
      scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      home: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false, //Thêm dòng này

        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Đăng nhập',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập tài khoản';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: 'Tài khoản',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 0),
                    Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            dense: true,
                            title: Text('Lưu đăng nhập',
                                style: TextStyle(fontWeight: FontWeight.w400)),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: Text(
                              'Đăng ký',
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RegisterScreen()),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _login(context),
                            child: Text('Đăng nhập',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: Text('Quên mật khẩu?'),
                    ),
                    SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                          width: double.infinity, height: 40),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Image.asset('assets/images/google_logo.png',
                            fit: BoxFit.cover),
                        label: Text('Đăng nhập với Google'),
                      ),
                    ),
                    SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                          width: double.infinity, height: 40),
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: Image.asset('assets/images/facebook_logo.png',
                            fit: BoxFit.cover),
                        label: Text('Đăng nhập với Facebook'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
