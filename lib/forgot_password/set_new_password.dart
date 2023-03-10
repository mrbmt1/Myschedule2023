import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String uid;

  const SetNewPasswordScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _SetNewPasswordScreenState createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Hàm xử lý khi nhấn nút đổi mật khẩu
  void _handleSubmit() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      setState(() {
        _loading = false;
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    try {
      // Đổi mật khẩu trên Firebase Authentication
      await _auth.signInWithCustomToken(widget.uid);
      await _auth.currentUser!.updatePassword(password);
      await _auth.signOut();

      // Điều hướng đến màn hình đăng nhập
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.message;
      });
    }
  }

  // Hàm build màn hình
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set New Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
// Trường xác nhận mật khẩu mới
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    errorText: _errorMessage,
                  ),
                ),
                SizedBox(height: 16.0),
// Nút đổi mật khẩu
                ElevatedButton(
                  onPressed: _loading ? null : _handleSubmit,
                  child: _loading
                      ? CircularProgressIndicator()
                      : Text('Set New Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
