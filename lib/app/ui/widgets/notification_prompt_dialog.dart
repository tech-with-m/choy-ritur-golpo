import 'package:flutter/material.dart';

class NotificationPromptDialog extends StatelessWidget {
  const NotificationPromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'সতর্কবার্তা',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'আপনার এলাকায় ভারী বৃষ্টি, ঝড়-তুফান, নিম্নচাপ ইত্যাদি সম্পর্কে আগাম সতর্কতা পেতে নোটিফিকেশনের অনুমতি প্রয়োজন',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'পরে মনে করাবেন',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'অনুমতি দেই',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}