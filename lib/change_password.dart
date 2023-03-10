import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmNewPasswordVisible = false;

  Future<void> _changePassword() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();

      // Lấy thông tin người dùng hiện tại từ Firebase Authentication
      final user = FirebaseAuth.instance.currentUser;

      // Lấy thông tin người dùng từ collection users
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);
      final userData = await userRef.get();

      // So sánh mật khẩu hiện tại với password trong collection users
      final currentPasswordHash =
          sha256.convert(utf8.encode(_currentPassword)).toString();
      final userPassword = userData.data()?['password'] as String;

      if (userPassword != currentPasswordHash) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mật khẩu hiện tại không đúng')),
        );
        return;
      }

      // Kiểm tra xác nhận mật khẩu mới
      if (_newPassword != _confirmNewPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mật khẩu mới không khớp')),
        );
        return;
      }

      // Cập nhật password mới cho người dùng
      final newPasswordHash =
          sha256.convert(utf8.encode(_newPassword)).toString();
      await userRef.update({'password': newPasswordHash});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật mật khẩu thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Đổi mật khẩu'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu hiện tại',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _currentPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentPasswordVisible = !_currentPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_currentPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu hiện tại';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _currentPassword = value!;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu mới',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _newPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _newPasswordVisible = !_newPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_newPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu mới';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu mới phải có ít nhất 6 ký tự';
                      }
                      if (!RegExp(
                              r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]+$')
                          .hasMatch(value)) {
                        return 'Mật khẩu mới phải chứa ít nhất 1 chữ hoa, 1 chữ thường, 1 số và 1 ký tự đặc biệt';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _newPassword = value!;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nhập lại mật khẩu mới',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmNewPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _confirmNewPasswordVisible =
                                !_confirmNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_confirmNewPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu mới';
                      }
                      if (value != _newPassword) {
                        return 'Mật khẩu nhập lại không khớp';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _confirmNewPassword = value!;
                    },
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: _changePassword,
                    child: Text('Đổi mật khẩu'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
