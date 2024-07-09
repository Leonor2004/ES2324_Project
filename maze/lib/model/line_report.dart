import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maze/components/select_time.dart';
import 'package:firebase_database/firebase_database.dart';

final databaseReference = FirebaseDatabase.instance.ref();

// ignore: must_be_immutable
class LineReport extends StatefulWidget {
  final String id;
  final int hour;
  final int minutes;
  final String line;
  final String stopCode;
  final String trip;
  final bool isWaiting;
  final bool itArrived;
  final bool outService;
  final String? uid;
  final int? diff;

  LineReport({
    super.key,
    required this.id,
    required this.hour,
    required this.minutes,
    required this.line,
    required this.stopCode,
    required this.trip,
    required this.isWaiting,
    required this.itArrived,
    required this.outService,
    this.diff,
    this.uid,
  });

  @override
  State<LineReport> createState() => _LineReportState();

  Map<String, dynamic> toJson() {
    return {
      'line': line,
      'stopCode': stopCode,
      'trip': trip,
      'isWaiting': isWaiting,
      'itArrived': itArrived,
      'outService': outService,
      'hour': hour,
      'minutes': minutes,
      'uid': uid,
      'day': selectedDate.day,
      'month': selectedDate.month,
      'diff': diff,
    };
  }
}

//---------------------------------------------------------------------

class _LineReportState extends State<LineReport> {
  //final FirebaseDatabaseService _databaseService = FirebaseDatabaseService();
  late String currentUserUid;

  @override
  void initState() {
    super.initState();
    currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  @override
  Widget build(BuildContext context) {
    Icon icon;
    if (widget.itArrived) {
      icon = Icon(Icons.check_circle, color: Theme.of(context).highlightColor);
    } else if (widget.outService) {
      icon =
          Icon(Icons.directions_bus, color: Theme.of(context).highlightColor);
    } else {
      icon = Icon(Icons.timer, color: Theme.of(context).highlightColor);
    }

    String text;
    if (widget.itArrived) {
      text = 'It arrived to ${widget.stopCode} ';
    } else if (widget.outService) {
      text = "It's out of service ";
    } else {
      text = "Waiting for this bus. ";
    }

    return ListTile(
      leading: icon,
      title: Row(children: [
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).focusColor,
          ),
        ),
        Text(
          widget.hour < 10
              ? widget.minutes < 10
                  ? "(0${widget.hour}:0${widget.minutes})"
                  : "(0${widget.hour}:${widget.minutes})"
              : widget.minutes < 10
                  ? "(${widget.hour}:0${widget.minutes})"
                  : "(${widget.hour}:${widget.minutes})",
          style: TextStyle(
            color: Theme.of(context).focusColor,
            fontSize: 12,
          ),
        ),
      ]),
    );
  }
}
/*
*/