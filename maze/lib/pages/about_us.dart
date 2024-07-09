import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Theme.of(context).focusColor),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 40, left: 30, right: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'ABOUT US',
              style: TextStyle(
                  color: Theme.of(context).highlightColor,
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Text(
              "Maze: Navigating Public Transit Together",
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).focusColor,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "Welcome to Maze, your smart commute companion designed to revolutionize "
                  "public transport experience. By providing real-time updates on bus schedules "
                  "and user-generated reports on delays or cancellations, Maze ensures you have "
                  "the most accurate commuting information. Developed by a dedicated team from "
                  "the Faculty of Engineering of the University of Porto, Maze empowers users to "
                  "contribute to and benefit from the collective intelligence of a community-driven "
                  "navigation system. Join us in transforming the way we travel, making every journey "
                  "smoother and more reliable.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).focusColor,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "© 2024 Maze. All rights reserved. Trademarks belong to their respective owners.",
                style: TextStyle(
                  color: Theme.of(context).focusColor,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
