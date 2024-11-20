import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/authController.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Email'),
              subtitle: Text(authController.user.value?.email ?? 'N/A'),
            ),
           
          ],
        ),
      ),
    );
  }
}
