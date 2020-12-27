import 'package:flutter/material.dart';
import 'package:whoru/src/pages/discover_page/widgets/meeting_card.dart';

class MeetingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return MeetingCard();
          },
        ),
      ),
    );
  }
}
