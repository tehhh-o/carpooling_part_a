import 'dart:io';

import 'package:carpool_training/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterVehicle extends StatefulWidget {
  const RegisterVehicle({super.key});

  @override
  State<RegisterVehicle> createState() => _RegisterVehicleState();
}

class _RegisterVehicleState extends State<RegisterVehicle> {
  bool isLoading = false;
  final scrollbarController = ScrollController();
  final formKey = GlobalKey<FormState>();
  final carModelController = TextEditingController();
  final carPlateController = TextEditingController();
  final sittingCapacityController = TextEditingController();
  File? vehicleImage;
  Map<String, bool> features = {
    'Wheelchair Accessible ': false,
    'Child Seat': false,
    'Pet Friendly': false,
  };

  Future<void> pickImage(ImageSource imageSource) async {
    final returnedImage = await ImagePicker().pickImage(
      source: imageSource,
      imageQuality: 75,
      maxWidth: 300,
    );

    if (returnedImage == null) return;
    setState(() {
      vehicleImage = File(returnedImage.path);
    });
  }

  Future<void> updateVehicleToDb() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final vehicleRef = await FirebaseStorage.instance
        .ref('vehicle')
        .child('vehicle_$currentUserUid')
        .putFile(vehicleImage!);
    final vehicleUrl = await vehicleRef.ref.getDownloadURL();

    FirebaseFirestore.instance.collection('driver').doc(currentUserUid).update({
      'vehicle': {
        'carModel': carModelController.text.trim(),
        'carPlate': carPlateController.text.trim(),
        'carPhotoUrl': vehicleUrl,
        'sittingCapacity': int.parse(sittingCapacityController.text.trim()),
        'specialFeatures': features.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key)
            .toList(),
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: uniPoolAppBar(
            appBarTitle: "Vehicle Information",
            leadingWidget: Icon(Icons.looks_3_outlined, color: Colors.white),
            implyLeading: false,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 32,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    vehicleImage == null
                        ? Container(
                            color: Colors.grey[350],
                            height: 130,
                            width: 250,
                          )
                        : Image.file(vehicleImage!, height: 130, width: 250),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Vehicle Image"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await pickImage(ImageSource.camera);
                          },
                          child: Text("Pick from Camera"),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            await pickImage(ImageSource.gallery);
                          },
                          child: Text("Pick from Gallery"),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: carModelController,
                            decoration: InputDecoration(
                              hintText: "Car Model",
                              prefixIcon: Icon(Icons.directions_car),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter the car model";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: carPlateController,
                                    decoration: InputDecoration(
                                      hintText: "Car Plate",
                                      prefixIcon: Icon(Icons.app_registration),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter the car Plate";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: TextFormField(
                                    controller: sittingCapacityController,
                                    decoration: InputDecoration(
                                      hintText: "Capacity",
                                      prefixIcon: Icon(Icons.people),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter the sitting capacity";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),

                    Align(
                      alignment: AlignmentGeometry.bottomLeft,
                      child: Text("Additonal Features: "),
                    ),

                    SizedBox(
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Scrollbar(
                          controller: scrollbarController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: scrollbarController,
                            itemCount: features.length,
                            itemBuilder: (context, index) {
                              final entry = features.entries.toList()[index];
                              return CheckboxListTile(
                                title: Text(entry.key),
                                value: entry.value,
                                onChanged: (val) => setState(() {
                                  features[entry.key] = val ?? false;
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: () async {
                        if (vehicleImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please upload the vehicle image'),
                            ),
                          );
                        }
                        if (formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          await updateVehicleToDb();
                          setState(() => isLoading = false);
                          if (context.mounted) {
                            return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'All Information Submitted Successfully',
                                  ),
                                  content: Text(
                                    'Account Created successfully, Proceed to Login.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          FirebaseAuth.instance.signOut();
                                          Navigator.popUntil(
                                            context,
                                            (route) => route.isFirst,
                                          );
                                        });
                                      },
                                      child: Text('Go to Login'),
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
                          borderRadius: BorderRadiusGeometry.circular(4),
                        ),
                      ),
                      child: Text("Submit"),
                    ),
                  ],
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
