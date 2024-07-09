import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maze/model/line.dart';
import 'package:maze/auxiliaries/fetch_stops.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final TextEditingController _reportController = TextEditingController();
  String? selectedOption;
  String? selectedLine;
  String? selectedStop;
  List<Line> lines = [];

  @override
  void initState() {
    super.initState();
    _initializeLines();
  }

  Future<void> _initializeLines() async {
    lines = await fetchLinesNumbers();
    setState(() {});
  }

  Future<List<Line>> fetchLinesNumbers() async {
    String jsonString = await rootBundle.loadString('files/lines.json');
    Map<String, dynamic> data = json.decode(jsonString);

    List<Line> lines = [];

    data.forEach((key, value) {
      String number = value['number'];
      String from = value['from'];
      String to = value['to'];

      Line line = Line(number: number, from: from, to: to);
      lines.add(line);
    });

    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Theme.of(context).focusColor),
        title: Text(
          'Submit a report',
          style: TextStyle(color: Theme.of(context).focusColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select type of report:',
                    style: TextStyle(
                      color: Theme.of(context).focusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Theme.of(context).hintColor,
                    ),
                    child: DropdownButton<String>(
                      value: selectedOption,
                      icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).focusColor),
                      iconSize: 24,
                      elevation: 16,
                      isExpanded: true,
                      style: TextStyle(color: Theme.of(context).focusColor),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue;
                          selectedLine = null;
                          selectedStop = null;
                        });
                      },
                      items: <String>[
                        'About the app functionalities',
                        'About a stop',
                        'About a line',
                        'Other'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(color: Theme.of(context).focusColor, fontFamily: 'CenturyGothic'),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (selectedOption == 'About a line') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Select line:',
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Theme.of(context).hintColor,
                      ),
                      child: DropdownButton<String>(
                        value: selectedLine,
                        icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).focusColor),
                        iconSize: 24,
                        elevation: 16,
                        isExpanded: true,
                        style: TextStyle(color: Theme.of(context).focusColor),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLine = newValue;
                          });
                        },
                        items: lines.map<DropdownMenuItem<String>>((Line line) {
                          return DropdownMenuItem<String>(
                            value: line.number,
                            child: Text(
                              line.number,
                              style: TextStyle(color: Theme.of(context).focusColor, fontFamily: 'CenturyGothic'),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ] else if (selectedOption == 'About a stop') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Select stop:',
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Theme.of(context).hintColor,
                      ),
                        child: DropdownButton<String>(
                          value: selectedStop,
                          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).focusColor),
                          iconSize: 24,
                          elevation: 16,
                          isExpanded: true,
                          style: TextStyle(color: Theme.of(context).focusColor),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStop = newValue;
                            });
                          },
                          items: stops.entries.map((MapEntry<String, String> entry) => entry.value).toSet().toList().map<DropdownMenuItem<String>>((String stopName) {
                            return DropdownMenuItem<String>(
                              value: stops.entries.firstWhere((entry) => entry.value == stopName).key,
                              child: Text(
                                stopName,
                              style: TextStyle(color: Theme.of(context).focusColor, fontFamily: 'CenturyGothic'),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reportController,
              decoration: InputDecoration(
                hintText: 'Write your report here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).hintColor,
                hintStyle: TextStyle(
                  color: Theme.of(context).focusColor,
                ),
              ),
              style: TextStyle(
                color: Theme.of(context).focusColor,
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedOption == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select a type of report.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (selectedOption == 'About a line' && selectedLine == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select a line.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else if (selectedOption == 'About a stop' && selectedStop == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select a stop.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                } else {
                  String reportText = _reportController.text;
                  if (reportText.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'You have to write to submit the report.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else {
                    saveReportToFirebase(reportText);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Your report has been submitted.',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).hintColor,
              ),
              child: Text(
                "Submit a Report",
                style: TextStyle(color: Theme.of(context).focusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveReportToFirebase(String reportText) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    DatabaseReference reportRef;
    if (selectedOption == 'About a line') {
      reportRef = FirebaseDatabase.instance.ref().child('reports').child(selectedOption!).child(selectedLine!);
    } else if (selectedOption == 'About a stop') {
      String stopName = stops[selectedStop!] ?? '';
      reportRef = FirebaseDatabase.instance.ref().child('reports').child(selectedOption!).child(stopName.replaceAll('.', ''));
    } else {
      reportRef = FirebaseDatabase.instance.ref().child('reports').child(selectedOption!);
    }

    reportRef.push().set({
      'timestamp': formattedDate,
      'reportText': reportText,
      'uid': uid,
    });
  }
}
