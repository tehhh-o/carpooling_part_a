import 'package:carpool_training/app_theme.dart';
import 'package:carpool_training/pages/register/register_page.dart';
import 'package:carpool_training/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final icController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool showPassword = false;

  Future<void> signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "${icController.text.trim()}@driver.cc",
        password: passwordController.text.trim(),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.code)));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tStyle = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text('Kongsi Kereta')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(height: AppTheme.s24),
                    Text(
                      'Welcome to Kongsi Kereta',
                      style: tStyle.headlineSmall,
                    ),
                    Text(
                      'An app that makes carpooling\neasier than before!',
                      textAlign: TextAlign.center,
                      style: tStyle.titleSmall,
                    ),
                    SizedBox(height: AppTheme.s40),
                    Column(
                      children: [
                        Text("Login", style: tStyle.titleLarge),
                        SizedBox(height: AppTheme.s24),
                        TextFormField(
                          controller: icController,
                          decoration: InputDecoration(
                            label: Text("IC Number", style: tStyle.titleMedium),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hint: Text(
                              "Enter your IC Number",
                              style: tStyle.bodySmall,
                            ),
                            prefixIcon: Icon(
                              Icons.credit_card,
                              color: Colors.black,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your IC';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppTheme.r16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !showPassword,
                          decoration: InputDecoration(
                            label: Text("Password", style: tStyle.titleMedium),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hint: Text(
                              "Enter your password",
                              style: tStyle.bodySmall,
                            ),
                            prefixIcon: Icon(Icons.password),
                            suffixIcon: InkWell(
                              onTapDown: (_) => setState(() {
                                showPassword = showPassword ? false : true;
                              }),
                              child: Icon(Icons.remove_red_eye),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                SlideFadeRoute(page: RegisterPage()),
                              );
                            },
                            child: Text(
                              "Register?",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() => isLoading = true);
                              await signInWithEmailAndPassword();
                              setState(() => isLoading = false);
                            }
                          },
                          child: Text("Submit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          isLoading
              ? Container(
                  color: Colors.black.withAlpha(10),
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
