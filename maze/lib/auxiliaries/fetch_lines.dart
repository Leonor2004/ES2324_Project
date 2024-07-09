import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:maze/model/line.dart';


List<Line> lines = [];

Future<void> fetchLines() async {
  String jsonString = await rootBundle.loadString('files/lines.json');
  Map<String, dynamic> data = json.decode(jsonString);

  data.forEach((key, value) {
    lines.add(
      Line(number: value["number"], from: value["from"], to: value["to"],),
    );
  });
}
