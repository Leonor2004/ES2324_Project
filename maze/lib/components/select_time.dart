import 'dart:async';

import 'package:flutter/material.dart';

DateTime selectedDate = DateTime.now();
bool changed = false;

Future<void> selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (picked != null && picked != selectedDate) {
    final selectedDateTime = DateTime(
      picked.year,
      picked.month,
      picked.day,
      selectedDate.hour,
      selectedDate.minute,
    );
    selectedDate = selectedDateTime;
    changed = true;
  }
}

Future<void> selectTime(BuildContext context) async {
  final now = DateTime.now();
  final TimeOfDay initialTime = TimeOfDay(hour: now.hour, minute: now.minute);
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );
  if (picked != null) {
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      picked.hour,
      picked.minute,
    );
    if (selectedDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time later than the current time.'),
        ),
      );
    } else {
      selectedDate = selectedDateTime;
      changed = true;
    }
  }
}

void resetTime() {
  selectedDate = DateTime.now();
  changed = false;
}
