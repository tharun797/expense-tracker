// lib/widgets/common/delete_confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteConfirmationDialog {
  static void show({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Get.back();
            },
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}