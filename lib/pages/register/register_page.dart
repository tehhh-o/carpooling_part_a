import 'package:carpool_training/app_theme.dart';
import 'package:carpool_training/pages/login_page.dart';
import 'package:carpool_training/pages/register/register_document.dart';
import 'package:carpool_training/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  //final VoidCallback showLogin;
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController icController = TextEditingController();
  String selectedGender = 'Male';
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final userCredentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: "${icController.text.trim()}@driver.cc",
            password: passwordController.text.trim(),
          );
      print(userCredentials);
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  Future<void> uploadUserInfoToDb() async {
    try {
      await FirebaseFirestore.instance
          .collection("driver")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
            "name": nameController.text.trim(),
            "icNumber": icController.text.trim(),
            "gender": selectedGender,
            "phone": phoneController.text.trim(),
            "email": emailController.text.trim(),
            "address": addressController.text.trim(),
          });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tStyle = Theme.of(context).textTheme;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Hero(
              tag: 'register_appbar',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Register as Driver', style: tStyle.titleLarge),
                  Text('Step 1 of 3', style: tStyle.labelLarge),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(20),
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  vertical: AppTheme.s16,
                  horizontal: AppTheme.s24,
                ),
                child: Hero(
                  tag: 'progress_bar',
                  child: LinearProgressIndicator(
                    value: 1 / 3,
                    minHeight: AppTheme.s8,
                  ),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
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
                              Text(
                                "Register (Personal Information)",
                                style: tStyle.titleLarge,
                              ),
                              SizedBox(height: AppTheme.s24),
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  label: Text(
                                    "Name",
                                    style: tStyle.titleMedium,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hint: Text(
                                    "Enter your Name",
                                    style: tStyle.bodySmall,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppTheme.r16),
                              TextFormField(
                                controller: icController,
                                decoration: InputDecoration(
                                  label: Text(
                                    "IC Number",
                                    style: tStyle.titleMedium,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
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
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  label: Text(
                                    "Gender",
                                    style: tStyle.titleMedium,
                                  ),
                                  prefixIcon: Icon(Icons.wc),
                                ),
                                initialValue: selectedGender,
                                items: ['Male', 'Female'].map((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                  });
                                },
                              ),
                              SizedBox(height: AppTheme.r16),
                              TextFormField(
                                controller: phoneController,

                                decoration: InputDecoration(
                                  label: Text(
                                    "Phone",
                                    style: tStyle.titleMedium,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hint: Text(
                                    "Enter your Phone Number",
                                    style: tStyle.bodySmall,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Phone Number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppTheme.r16),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  label: Text(
                                    "Email",
                                    style: tStyle.titleMedium,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hint: Text(
                                    "Enter your Email",
                                    style: tStyle.bodySmall,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppTheme.r16),
                              TextFormField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  label: Text(
                                    "Address",
                                    style: tStyle.titleMedium,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hint: Text(
                                    "Enter your Address",
                                    style: tStyle.bodySmall,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.home,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Address';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppTheme.r16),
                              TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  label: Text(
                                    "Password",
                                    style: tStyle.titleMedium,
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hint: Text(
                                    "Enter your Password",
                                    style: tStyle.bodySmall,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.password,
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Password';
                                  }
                                  return null;
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      SlideFadeRoute(page: LoginPage()),
                                    );
                                  },
                                  child: Text(
                                    "Login?",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Hero(
                  tag: 'register_submit_button',
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.s4),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          await createUserWithEmailAndPassword();
                          await uploadUserInfoToDb();
                          setState(() => isLoading = false);
                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text("Success"),
                                  content: Text(
                                    'All information submitted succssfully',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        SlideFadeRoute(
                                          page: RegisterDocument(),
                                        ),
                                      ),
                                      child: Text('Next Step'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        }
                      },
                      child: Text("Submit"),
                    ),
                  ),
                ),
              ],
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
    );
  }
}
