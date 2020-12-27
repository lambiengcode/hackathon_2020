import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/pages/profile_page/widgets/line_chart.dart';

import '../../models/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: .0,
        brightness: ThemeProvider.of(context).brightness,
        leading: IconButton(
          onPressed: () => null,
          icon: Icon(
            LineAwesomeIcons.cog,
            color: Colors.blueGrey.shade700,
            size: _size.width / 10.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => null,
            icon: Icon(
              LineAwesomeIcons.qrcode,
              color: Colors.blueGrey.shade700,
              size: _size.width / 10.5,
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .where('id', isEqualTo: user.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }

                String urlToImage = snapshot.data.documents[0]['urlToImage'];
                String username = snapshot.data.documents[0]['username'];
                String idStudent = snapshot.data.documents[0]['idStudent'];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: _size.width * .33,
                      width: _size.width * .33,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        height: _size.width * .28,
                        width: _size.width * .28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2.0,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(urlToImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 14.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          username,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: _size.width / 16.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'ID: ',
                                style: TextStyle(
                                  fontSize: _size.width / 22.5,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: idStudent,
                                style: TextStyle(
                                  fontSize: _size.width / 22.5,
                                  color: Colors.blueAccent.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Expect Graduated: ',
                                style: TextStyle(
                                  fontSize: _size.width / 22.5,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: '2022',
                                style: TextStyle(
                                  fontSize: _size.width / 22.5,
                                  color: Colors.blueAccent.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(
              height: 16.0,
            ),
            Container(
              height: 42.0,
              margin: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  4.0,
                ),
                border: Border.all(
                  color: Colors.blueAccent.shade400,
                  width: .25,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        ThemeProvider.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(.04)
                            : Color(0xFFABBAD5),
                    spreadRadius: 1.15,
                    blurRadius: 1.25,
                    offset: Offset(0, 2.0), // changes position of shadow
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: _size.width / 25.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent.shade400,
                ),
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            Divider(
              thickness: .25,
              height: .25,
              indent: 10.0,
              endIndent: 10.0,
              color: Colors.blueAccent.shade100,
            ),
            Expanded(child: LineChartSubmit()),
            SizedBox(
              height: 12.0,
            ),
            Container(
              height: 48.0,
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Blue:\t\t',
                          style: TextStyle(
                            fontSize: _size.width / 24.0,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Completed',
                          style: TextStyle(
                            fontSize: _size.width / 25.0,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Red :\t\t',
                          style: TextStyle(
                            fontSize: _size.width / 24.0,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'Not Completed',
                          style: TextStyle(
                            fontSize: _size.width / 25.0,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: _size.height * .025,
            ),
          ],
        ),
      ),
    );
  }
}
