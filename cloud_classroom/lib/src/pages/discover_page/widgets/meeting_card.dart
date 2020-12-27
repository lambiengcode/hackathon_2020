import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class MeetingCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        bottom: 12.0,
      ),
      padding: EdgeInsets.fromLTRB(14.0, 12.0, 8.0, 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(.04)
                : Color(0xFFABBAD5),
            spreadRadius: 1.15,
            blurRadius: 1.25,
            offset: Offset(0, 2.0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                      image: DecorationImage(
                        image: AssetImage('images/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dung Hoang',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: _size.width / 22.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Raleway-Bold',
                        ),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        '12m ago',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: _size.width / 28.0,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => null,
                icon: Icon(
                  Feather.more_vertical,
                  size: _size.width / 16.0,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 12.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.5),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Link: ',
                    style: TextStyle(
                      fontSize: _size.width / 24.0,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: '[Join Room]',
                    style: TextStyle(
                      fontSize: _size.width / 24.0,
                      color: Colors.blueAccent.shade700,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          Divider(
            height: .25,
            thickness: .25,
            color: Colors.grey.shade400,
          ),
          SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAction(
                context,
                'Comment',
                Feather.message_square,
              ),
              _buildAction(
                context,
                'Favourite',
                Feather.heart,
              ),
              _buildAction(
                context,
                'Bookmark',
                Feather.bookmark,
              ),
              _buildAction(
                context,
                'Share',
                Feather.share_2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    context,
    title,
    icon,
  ) {
    final _size = MediaQuery.of(context).size;

    return Expanded(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: _size.width / 18.5,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
