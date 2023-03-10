import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myshedule/forgot_password/set_new_password.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quên mật khẩu'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Tài khoản'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập tài khoản';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Số điện thoại'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _submitForm();
                    }
                  },
                  child: Text('Xác thực'),
                ),
                SizedBox(height: 20),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    // Xác thực tài khoản, email và số điện thoại từ Firestore
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();

    print(username);
    print(phone);
    print(email);

    if (!userDoc.exists) {
      setState(() {
        _errorMessage = 'Tài khoản không tồn tại';
      });
      return;
    }

    final userData = userDoc.data();
    if (userData!['phone'].isEmpty ||
        userData['email'].isEmpty ||
        userData['phone'] != phone ||
        userData['email'] != email) {
      setState(() {
        _errorMessage =
            'Số điện thoại hoặc email không đúng hoặc có trường trống';
      });
      return;
    }

    // Thông báo xác thực thành công và chuyển đến màn hình SetNewPasswordScreen
    setState(() {
      _errorMessage = 'Xác thực thành công';
    });

    // Lưu UID hiện tại để chuyển vào màn hình đặt mật khẩu mới
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetNewPasswordScreen(uid: currentUid),
      ),
    );
  }
}
