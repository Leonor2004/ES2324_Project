import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maze/auxiliaries/fetch_lines.dart';
import 'package:maze/components/select_time.dart';
import 'package:maze/model/line.dart';

class Lines extends StatefulWidget {
  const Lines({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LinesState createState() => _LinesState();
}

class _LinesState extends State<Lines> {
  late Timer timer;
  late List<Line> filteredLines;

  @override
  void initState() {
    super.initState();
    _initializeLines();
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      if (selectedDate != DateTime.now() && !changed) {
        setState(() {
          selectedDate = DateTime.now();
        });
      }
    });
    filteredLines = lines;
  }

  @override
  void dispose() {
    lines.clear();
    super.dispose();
  }

  Future<void> _initializeLines() async {
    await fetchLines();
    setState(() {});
  }

  void getSuggestionsBasedOnQuery(String query) {
    String lowerCaseQuery = query.toLowerCase();
    filteredLines = lines
        .where((item) =>
            item.number.toLowerCase().contains(lowerCaseQuery) ||
            item.from.toLowerCase().contains(lowerCaseQuery) ||
            item.to.toLowerCase().contains(lowerCaseQuery))
        .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 15, right: 15),
          child: SearchBar(
            backgroundColor:
                MaterialStateProperty.all(Theme.of(context).hintColor),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SvgPicture.asset('images/maze.svg',
                  color: Theme.of(context).focusColor, height: 40),
            ),
            trailing: <Widget>[
              PopupMenuButton(
                color: Theme.of(context).hintColor,
                icon: Icon(Icons.access_time,
                    color: Theme.of(context).focusColor),
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    onTap: () => selectDate(context),
                    child: Text(
                        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                        style: TextStyle(color: Theme.of(context).focusColor)),
                  ),
                  PopupMenuItem(
                    onTap: () => selectTime(context),
                    child: Text(
                        '${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Theme.of(context).focusColor)),
                  ),
                  PopupMenuItem(
                    onTap: () => resetTime(),
                    child: Text('Reset Time',
                        style: TextStyle(color: Theme.of(context).focusColor)),
                  ),
                ],
              ),
            ],
            hintText: 'Search',
            hintStyle: MaterialStatePropertyAll(
                TextStyle(color: Theme.of(context).focusColor)),
            textStyle: MaterialStatePropertyAll(
                TextStyle(color: Theme.of(context).focusColor)),
            onChanged: (value) => getSuggestionsBasedOnQuery(value),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredLines.length,
            itemBuilder: (BuildContext context, int index) {
              return filteredLines[index];
            },
          ),
        ),
      ],
    );
  }
}
