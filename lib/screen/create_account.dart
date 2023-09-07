import 'package:cardmonix/screen/Verification/otp_verification.dart';
import 'package:cardmonix/screen/login_signup.dart';
// import 'package:cardmonix/screen/User/dto/User.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateAccountScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  SizedBox spaceHieigt = const SizedBox(height: 20);
  //

  String url = "http://192.168.2.159:8085/api/v1/auth/register";
  final _formKey = GlobalKey<FormState>();

  CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              child: Form(
                key: _formKey,
                child: Container(
                  width: 400,
                  color: Colors.red,
                  child: Image.asset(
                    'images/bg.jpg',
                    width: MediaQuery.of(context).size.width - 90,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150,
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 550,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      spaceHieigt,
                      buildInputField(
                        hintText: 'Username',
                        controller: _usernameController,
                      ),
                      spaceHieigt,
                      buildInputField(
                        hintText: 'Email',
                        controller: _emailController,
                      ),
                      spaceHieigt,
                      buildInputField(
                        hintText: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                      ),
                      spaceHieigt,
                      buildInputField(
                        hintText: 'Re-Password',
                        controller: _cpasswordController,
                        obscureText: true,
                      ),
                      spaceHieigt,
                      buildElevatedButton(context),
                      spaceHieigt,
                      _wrightContent("Already have an account", "Log In"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInputField({
    required String hintText,
    bool obscureText = false,
    required TextEditingController controller,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        obscureText: obscureText,
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }
          return null;
        },
      ),
    );
  }

  Widget buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _registerUser(context);
        }
      },
      child: const SizedBox(
        width: 280,
        height: 50,
        child: Center(
          child: Text('Signup'),
        ),
      ),
    );
  }

  Future<void> _registerUser(BuildContext context) async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String cpassword = _cpasswordController.text;
    String username = _usernameController.text;
    if (password != cpassword) {
      _showMessageWarning(context, "Password does not Match");
    }

    Map<String, dynamic> requestBody = {
      'email': email,
      'password': password,
      'username': username,
    };
    Uri uri = Uri.parse(url);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingSpinner();
      },
    );

    http.Response response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    _showResponseAlert(context, response);
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration'),
          content: const Text('Otp Have been sent to your inbox'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Otp(email: _emailController.text)),
                );
              },
              child: const Text('Next'),
            ),
          ],
        );
      },
    );
  }

  void _showMessageWarning(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showResponseAlert(BuildContext context, http.Response response) {
    Map<String, dynamic> responseBody = json.decode(response.body);
    String title = response.statusCode == 201 ? 'Success' : 'Error';
    String message = responseBody['data'];
    print(response.statusCode);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                if (response.statusCode == 201) {
                  _showSuccessDialog(context);
                } else {
                  _showSuccessDialog(context);
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _wrightContent(String text, String text2) {
    return GestureDetector(
      onTap: () {
        Get.to(LoginSignupScreen(), transition: Transition.cupertino);
      },
      child: SizedBox(
        width: 250,
        height: 50,
        child: Center(
          child: Column(children: [
            Text(text),
            Text(text2),
          ]),
        ),
      ),
    );
  }
}

class LoadingSpinner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
