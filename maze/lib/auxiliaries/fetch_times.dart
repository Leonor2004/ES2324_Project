import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:maze/components/select_time.dart';

Future<List<Map<String, dynamic>>> getBusSchedule(String stopId) async {
  String jsonString = await rootBundle.loadString('files/stop_times.json');
  List<dynamic> data = json.decode(jsonString);

  DateTime generousDate = selectedDate.subtract(const Duration(minutes: 10));

  List<Map<String, dynamic>> schedule = data
      .where((bus) =>
          bus["s"] == stopId &&
          _isAfterCurrentTime(bus["t"], bus["d"], generousDate))
      .map((bus) {
    String busNumber = bus["t"].split("_")[0]; // Extract bus number
    return {"bus_number": busNumber, "departure": bus["d"], "trip": bus["t"]};
  }).toList();

  schedule.sort((a, b) => a["departure"].compareTo(b["departure"]));

  return schedule.take(10).toList();
}

bool _isAfterCurrentTime(
  String tripId, String arrivalTimeString, DateTime selectedDate) {
  String day;
  if (selectedDate.weekday == 6) {
    day = 'S';
  } else if (selectedDate.weekday == 7) {
    day = 'D';
  } else {
    day = 'U';
  }

  if (day != tripId.split("_")[2]) return false;
  List<String> parts = arrivalTimeString.split(':');
  DateTime arrivalTime = DateTime(selectedDate.year, selectedDate.month,
      selectedDate.day, int.parse(parts[0]), int.parse(parts[1]));

  return arrivalTime.isAfter(selectedDate);
}

