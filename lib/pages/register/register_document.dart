import 'dart:io';
import 'package:carpool_training/app_theme.dart';
import 'package:carpool_training/pages/register/register_vehicle.dart';
import 'package:carpool_training/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterDocument extends StatefulWidget {
  const RegisterDocument({super.key});

  @override
  State<RegisterDocument> createState() => _RegisterDocumentState();
}

class _RegisterDocumentState extends State<RegisterDocument> {
  bool isLoading = false;
  File? frontDoc;
  File? backDoc;
  File? profilePic;

  Future<File?> pickImage(ImageSource imageSource) async {
    final returnedImage = await ImagePicker().pickImage(
      source: imageSource,
      imageQuality: 75,
      maxWidth: 300,
    );
    if (returnedImage == null) return null;
    return File(returnedImage.path);
  }

  Future<void> uploadDocumentsToDb() async {
    final userUid = FirebaseAuth.instance.currentUser!.uid;
    final imageRef = FirebaseStorage.instance.ref("docs").child(userUid);

    final frontRef = await imageRef.child("front_$userUid").putFile(frontDoc!);
    final backRef = await imageRef.child("back_$userUid").putFile(backDoc!);
    final profilePicRef = await imageRef
        .child("profile_pic_$userUid")
        .putFile(profilePic!);

    final frontUrl = await frontRef.ref.getDownloadURL();
    final backUrl = await backRef.ref.getDownloadURL();
    final profilePicUrl = await profilePicRef.ref.getDownloadURL();

    FirebaseFirestore.instance.collection("driver").doc(userUid).update({
      "document": {"frontUrl": frontUrl, "backUrl": backUrl},
      'profilePicUrl': profilePicUrl,
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

          body: Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        profilePic == null
                            ? Container(
                                color: Colors.grey[350],
                                height: 130,
                                width: 250,
                              )
                            : Image.file(profilePic!, height: 130, width: 130),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppTheme.s8,
                            bottom: AppTheme.s16,
                          ),
                          child: Text(
                            'Profile Picture',
                            style: tStyle.labelLarge,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final img = await pickImage(
                                    ImageSource.camera,
                                  );
                                  setState(() {
                                    profilePic = img;
                                  });
                                },
                                child: Text("Pick from Camera"),
                              ),
                            ),
                            SizedBox(width: AppTheme.s12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final img = await pickImage(
                                    ImageSource.gallery,
                                  );
                                  setState(() {
                                    profilePic = img;
                                  });
                                },
                                child: Text("Pick from Gallery"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppTheme.r12),
                        frontDoc == null
                            ? Container(
                                color: Colors.grey[350],
                                height: 130,
                                width: 250,
                              )
                            : Image.file(frontDoc!, height: 130, width: 250),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppTheme.s8,
                            bottom: AppTheme.s16,
                          ),
                          child: Text(
                            "Front IC/Driving License",
                            style: tStyle.labelLarge,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final img = await pickImage(
                                    ImageSource.camera,
                                  );
                                  setState(() {
                                    frontDoc = img;
                                  });
                                },
                                child: Text("Pick from Camera"),
                              ),
                            ),
                            SizedBox(width: AppTheme.s12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final img = await pickImage(
                                    ImageSource.gallery,
                                  );
                                  setState(() {
                                    frontDoc = img;
                                  });
                                },
                                child: Text("Pick from Gallery"),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30),
                        backDoc == null
                            ? Container(
                                color: Colors.grey[350],
                                height: 130,
                                width: 250,
                              )
                            : Image.file(backDoc!, height: 130, width: 250),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppTheme.s8,
                            bottom: AppTheme.s16,
                          ),
                          child: Text(
                            "Back IC/Driving License",
                            style: tStyle.labelLarge,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final img = await pickImage(
                                    ImageSource.camera,
                                  );
                                  setState(() {
                                    backDoc = img;
                                  });
                                },
                                child: Text("Pick from Camera"),
                              ),
                            ),
                            SizedBox(width: AppTheme.s12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final img = await pickImage(
                                    ImageSource.gallery,
                                  );
                                  setState(() {
                                    backDoc = img;
                                  });
                                },
                                child: Text("Pick from Gallery"),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppTheme.s32),
                      ],
                    ),
                  ),
                ),

                Hero(
                  tag: 'register_submit_button',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.s4),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (frontDoc == null || backDoc == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please upload all images."),
                            ),
                          );
                        } else {
                          setState(() => isLoading = true);
                          await uploadDocumentsToDb();
                          setState(() => isLoading = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'All Information Submitted Sucessfully.',
                                ),
                              ),
                            );
                            Navigator.push(
                              context,
                              SlideFadeRoute(page: RegisterVehicle()),
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
