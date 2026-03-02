import 'dart:io';
import 'package:carpool_training/pages/register/register_vehicle.dart';
import 'package:carpool_training/style.dart';
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
    return Stack(
      children: [
        Scaffold(
          appBar: uniPoolAppBar(
            appBarTitle: "Documents",
            leadingWidget: Icon(Icons.looks_two_outlined, color: Colors.white),
            implyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 5),
                  frontDoc == null
                      ? Container(
                          color: Colors.grey[350],
                          height: 130,
                          width: 250,
                        )
                      : Image.file(frontDoc!, height: 130, width: 250),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: Text("Front IC/Driving License"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final img = await pickImage(ImageSource.camera);
                          setState(() {
                            frontDoc = img;
                          });
                        },
                        child: Text("Pick from Camera"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final img = await pickImage(ImageSource.gallery);
                          setState(() {
                            frontDoc = img;
                          });
                        },
                        child: Text("Pick from Gallery"),
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
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: Text("Back IC/Driving License"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final img = await pickImage(ImageSource.camera);
                          setState(() {
                            backDoc = img;
                          });
                        },
                        child: Text("Pick from Camera"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final img = await pickImage(ImageSource.gallery);
                          setState(() {
                            backDoc = img;
                          });
                        },
                        child: Text("Pick from Gallery"),
                      ),
                    ],
                  ),

                  SizedBox(height: 30),
                  profilePic == null
                      ? Container(
                          color: Colors.grey[350],
                          height: 130,
                          width: 250,
                        )
                      : Image.file(profilePic!, height: 130, width: 130),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: Text('Profile Picture'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final img = await pickImage(ImageSource.camera);
                          setState(() {
                            profilePic = img;
                          });
                        },
                        child: Text("Pick from Camera"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final img = await pickImage(ImageSource.gallery);
                          setState(() {
                            profilePic = img;
                          });
                        },
                        child: Text("Pick from Gallery"),
                      ),
                    ],
                  ),

                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () async {
                      if (frontDoc == null || backDoc == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please upload all images.")),
                        );
                      } else {
                        setState(() => isLoading = true);
                        await uploadDocumentsToDb();
                        setState(() => isLoading = false);
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Success"),
                              content: Text(
                                "All information submitted successfully.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterVehicle(),
                                    ),
                                  ),
                                  child: Text("Next Step"),
                                ),
                              ],
                            ),
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
