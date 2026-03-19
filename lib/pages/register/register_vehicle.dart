import 'dart:io';

import 'package:carpool_training/app_theme.dart';
import 'package:carpool_training/main.dart';
import 'package:carpool_training/routes.dart';
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
                  Text('Step 2 of 3', style: tStyle.labelLarge),
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
                    value: 2 / 3,
                    minHeight: AppTheme.s8,
                  ),
                ),
              ),
            ),
          ),

          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.s16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.s16,
                          horizontal: AppTheme.s8,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: AppTheme.s12),
                            vehicleImage == null
                                ? Container(
                                    color: Colors.grey[350],
                                    height: 130,
                                    width: 250,
                                  )
                                : Image.file(
                                    vehicleImage!,
                                    height: 130,
                                    width: 250,
                                  ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.s8,
                              ),
                              child: Text(
                                "Vehicle Image",
                                style: tStyle.titleMedium,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await pickImage(ImageSource.camera);
                                    },
                                    child: Text("Pick from Camera"),
                                  ),
                                ),
                                SizedBox(width: AppTheme.s12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await pickImage(ImageSource.gallery);
                                    },
                                    child: Text("Pick from Gallery"),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppTheme.s40),
                            Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: carModelController,
                                    decoration: InputDecoration(
                                      hintText: "Car Model",
                                      hintStyle: tStyle.bodySmall,
                                      prefixIcon: Icon(Icons.directions_car),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter the car model";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: AppTheme.s12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: carPlateController,
                                            decoration: InputDecoration(
                                              hintText: "Car Plate",
                                              hintStyle: tStyle.bodySmall,
                                              prefixIcon: Icon(
                                                Icons.app_registration,
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Please enter the car Plate";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(width: AppTheme.s12),
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                sittingCapacityController,
                                            decoration: InputDecoration(
                                              hintText: "Capacity",
                                              hintStyle: tStyle.bodySmall,
                                              prefixIcon: Icon(Icons.people),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
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
                            SizedBox(height: AppTheme.s40),

                            Align(
                              alignment: AlignmentGeometry.bottomLeft,
                              child: Text(
                                "Additonal Features: ",
                                style: tStyle.titleMedium,
                              ),
                            ),

                            SizedBox(
                              height: 200,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.s8,
                                ),
                                child: Scrollbar(
                                  controller: scrollbarController,
                                  thumbVisibility: true,
                                  child: ListView.builder(
                                    controller: scrollbarController,
                                    itemCount: features.length,
                                    itemBuilder: (context, index) {
                                      final entry = features.entries
                                          .toList()[index];
                                      return Card(
                                        child: CheckboxListTile(
                                          title: Text(entry.key),
                                          value: entry.value,
                                          onChanged: (val) => setState(() {
                                            features[entry.key] = val ?? false;
                                          }),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: AppTheme.s40),
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
                          if (vehicleImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please upload the vehicle image',
                                ),
                              ),
                            );
                          }
                          if (formKey.currentState!.validate()) {
                            setState(() => isLoading = true);
                            await updateVehicleToDb();
                            setState(() => isLoading = false);
                            if (context.mounted) {
                              await FirebaseAuth.instance.signOut();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Account Created Sucessfully. Proceed to Login.",
                                  ),
                                  duration: Duration(
                                    seconds: 1,
                                    milliseconds: 500,
                                  ),
                                ),
                              );

                              await Future.delayed(
                                Duration(seconds: 1, milliseconds: 500),
                              );
                              Navigator.of(context).pushAndRemoveUntil(
                                SlideFadeRoute(page: MyApp()),
                                (route) => false,
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
