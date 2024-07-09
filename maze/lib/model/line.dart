import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maze/pages/line_page.dart';

class Line extends StatelessWidget {
  const Line({super.key, required this.number, required this.from, required this.to});

  final String number;
  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Card(
        color: Theme.of(context).hintColor,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
            dense: true,
            leading: SizedBox(
              width: 35,
              child: SvgPicture.asset(
                'images/stcp.svg',
                color: Theme.of(context).focusColor,
              ),
            ),
            title: Text(number,
                style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                )),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  from,
                  style: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  to,
                  style: TextStyle(
                    color: Theme.of(context).focusColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LinePage(
                    line: number,
                    orig: from,
                    dest: to,
                  ),
                ),
              );
            }),
      ),
    );
  }
}
