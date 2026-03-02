import 'package:flutter/material.dart';

AppBar uniPoolAppBar({
  required String appBarTitle,
  Widget? leadingWidget,
  bool? implyLeading,
}) {
  return AppBar(
    title: Text(appBarTitle),
    centerTitle: true,
    automaticallyImplyLeading: implyLeading ?? true,
    leading: leadingWidget,
    shadowColor: const Color.fromARGB(255, 248, 255, 240),
    elevation: 3,
    titleTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
    toolbarHeight: 70,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightGreen[600]!, Colors.lightGreen[300]!],
          begin: AlignmentGeometry.topCenter,
          end: AlignmentGeometry.bottomRight,
        ),
      ),
    ),
  );
}

const List<Color> cardGradient = [
  Color.fromARGB(255, 251, 255, 248),
  Color.fromRGBO(220, 237, 200, 1),
];
