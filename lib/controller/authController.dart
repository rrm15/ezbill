import 'package:ezbill/view/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/homeScreen.dart';


class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable user
  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  void login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.snackbar("Hooray", "Login success");
      Get.to(() => HomeScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Get.to(() => HomeScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void logout() async {
    try {
      await _auth.signOut();
      Get.to(() => LoginScreen());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
