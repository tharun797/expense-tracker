import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/screens/dashboard_screen.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading.value = true;

      if (!_isValidEmail(email)) {
        Get.snackbar('Error', 'Please enter a valid email address');
        return;
      }

      if (password.length < 6) {
        Get.snackbar('Error', 'Password must be at least 6 characters');
        return;
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await _storage.write(
          key: 'token',
          value: await result.user!.getIdToken(),
        );

        Get.offAll(() => DashboardScreen());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Login failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      // Clean up ExpenseController before signing out
      _cleanupExpenseController();

      // Sign out from Firebase
      await _auth.signOut();

      // Clear secure storage
      await _storage.delete(key: 'token');

      // Clear all shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to login screen
      Get.offAll(() => LoginScreen());
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }

  // /// Initialize ExpenseController after successful login
  // void _initializeExpenseController() {
  //   try {
  //     if (!Get.isRegistered<ExpenseController>()) {
  //       Get.put(ExpenseController());
  //     } else {
  //       // If already registered, reset it
  //       Get.delete<ExpenseController>();
  //       Get.put(ExpenseController());
  //     }
  //   } catch (e) {
  //     debugPrint('Error initializing ExpenseController: $e');
  //   }
  // }

  /// Clean up ExpenseController before logout
  void _cleanupExpenseController() {
    try {
      if (Get.isRegistered<ExpenseController>()) {
        Get.delete<ExpenseController>();
      }
    } catch (e) {
      debugPrint('Error cleaning up ExpenseController: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
