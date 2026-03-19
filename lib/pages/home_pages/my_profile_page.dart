import 'package:carpool_training/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late Future<DocumentSnapshot> profileFuture;
  @override
  void initState() {
    super.initState();
    profileFuture = FirebaseFirestore.instance
        .collection("driver")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final tStyle = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder(
              future: profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return Center(child: Text("Data not found,"));
                }
                final currentUser = snapshot.data!;
                return Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          currentUser['profilePicUrl'],
                        ),
                        radius: 100,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppTheme.s16),
                        child: Text(
                          "Welcome ${currentUser["name"]}",
                          style: tStyle.headlineSmall,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Profile QR Code'),
                                content: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: Center(
                                    child: QrImageView(
                                      data:
                                          'Uid : ${FirebaseAuth.instance.currentUser!.uid}\nName : ${currentUser['name']}',
                                      size: 200,
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Back'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Show Profile QR'),
                      ),
                      SizedBox(height: AppTheme.s16),
                      Chip(
                        label: Row(
                          children: [
                            Icon(Icons.mail),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.s8,
                                horizontal: AppTheme.s16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email'),
                                  Text(
                                    currentUser["email"],
                                    style: tStyle.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.s8,
                        ),
                        child: Chip(
                          label: Row(
                            children: [
                              Icon(Icons.phone),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.s8,
                                  horizontal: AppTheme.s16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Phone Number'),
                                    Text(
                                      currentUser["phone"],
                                      style: tStyle.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Chip(
                        label: Row(
                          children: [
                            Icon(Icons.location_on),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppTheme.s8,
                                horizontal: AppTheme.s16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Address'),
                                  Text(
                                    currentUser["address"],
                                    style: tStyle.titleMedium,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  padding: EdgeInsets.all(AppTheme.s16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.dark_mode),
                                        title: Text('Dark Mode'),
                                        trailing: Switch(
                                          value: Get.isDarkMode,
                                          onChanged: (val) async {
                                            Get.changeThemeMode(
                                              val
                                                  ? ThemeMode.dark
                                                  : ThemeMode.light,
                                            );
                                            await SharedPreferences.getInstance()
                                                .then(
                                                  (pref) => pref.setBool(
                                                    'isDarkMode',
                                                    val,
                                                  ),
                                                );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.settings),
                                  Text('Settings'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: AppTheme.s8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => FirebaseAuth.instance.signOut(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(Icons.exit_to_app),
                                  Text('Sign Out'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
