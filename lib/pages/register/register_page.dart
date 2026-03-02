import 'package:carpool_training/pages/login_page.dart';
import 'package:carpool_training/pages/register/register_document.dart';
import 'package:carpool_training/style.dart';
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
    return Stack(
      children: [
        Scaffold(
          appBar: uniPoolAppBar(appBarTitle: "UniPool"),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Text(
                        'Welcome to UniPool',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'An app that makes carpooling\neasier than before!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          border: BoxBorder.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 32.0,
                            horizontal: 12,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Register (3 Steps)",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                ),
                              ),
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  label: Text("Name"),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: icController,
                                decoration: InputDecoration(
                                  label: Text("IC"),
                                  prefixIcon: Icon(Icons.credit_card),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your ic";
                                  }
                                  return null;
                                },
                              ),
                              RadioGroup<String>(
                                groupValue: selectedGender,
                                onChanged: (value) =>
                                    setState(() => selectedGender = value!),
                                child: Row(
                                  children: [
                                    SizedBox(width: 12),
                                    Icon(Icons.wc),
                                    SizedBox(width: 14),
                                    Text('Gender: '),
                                    Radio<String>(value: 'Male'),
                                    Text('Male'),
                                    Radio<String>(value: 'Female'),
                                    Text('Female'),
                                  ],
                                ),
                              ),
                              TextFormField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  label: Text("Phone"),
                                  prefixIcon: Icon(Icons.phone),
                                ),
                              ),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  label: Text("Email"),
                                  prefixIcon: Icon(Icons.email),
                                ),
                              ),
                              TextFormField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  label: Text("Address"),
                                  prefixIcon: Icon(Icons.home),
                                ),
                              ),
                              TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  label: Text("Password"),
                                  prefixIcon: Icon(Icons.password),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter the password.";
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
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
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
                              ElevatedButton(
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
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        RegisterDocument(),
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
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(300, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      4,
                                    ),
                                  ),
                                ),
                                child: Text("Submit"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
    );
  }
}
