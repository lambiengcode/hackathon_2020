import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class CommentInput extends StatefulWidget {
  final String idPost;
  final index;

  CommentInput({this.idPost, this.index});

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  TextEditingController _controller = TextEditingController();
  String message = "";
  int maxLines = 1;

  @override
  void initState() {
    super.initState();
    message = "";
    _controller.text = "";
  }

  Future<void> _updateFavourite(value) async {
    Firestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.index);
      int comment = snapshot['comment'];
      await transaction.update(widget.index, {
        'comment': comment + value,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double sizeWidth = MediaQuery.of(context).size.width;
    final double sizeHeight = MediaQuery.of(context).size.height;
    final user = Provider.of<User>(context);

    Future<void> _pushMessage(message, type) async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        CollectionReference reference =
            Firestore.instance.collection("comment");
        await reference.add({
          'id': user.uid,
          'idPost': widget.idPost,
          'parent': '@null',
          'publishAt': DateTime.now(),
          'edited': false,
          'comment': message,
          'reply': 0,
        });
      });
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: sizeHeight * 0.3,
      ),
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              shadowColor: Color(0xFFABBAD5),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.multiline,
                maxLines: maxLines,
                autofocus: false,
                decoration: InputDecoration(
                    hintText: 'Type comment...',
                    hintStyle:
                        TextStyle(color: Colors.grey, fontSize: sizeWidth / 24),
                    contentPadding: EdgeInsets.only(left: 24.0, top: 30.0),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {},
                          child: Icon(
                            FontAwesomeIcons.smileWink,
                            size: sizeWidth / 15.5,
                            color: Color(0xFF565D76),
                          ),
                        ),
                        SizedBox(
                          width: 14.0,
                        ),
                      ],
                    ),
                    suffixIconConstraints: BoxConstraints(
                      maxWidth: sizeWidth * 0.2,
                    )),
                onChanged: (mes) {
                  setState(() {
                    if (mes.length == 0) {
                      maxLines = 1;
                    } else {
                      if (mes.length > 18) {
                        maxLines = 2;
                      }
                    }
                    return message = mes.trim();
                  });
                },
              ),
            ),
          ),
          SizedBox(
            width: message.length == 0 ? 0.0 : 10.0,
          ),
          message.length == 0
              ? Container(
                  height: 0.0,
                )
              : GestureDetector(
                  onTap: () async {
                    if (message != "") {
                      await _pushMessage(message, 'text');
                      await _updateFavourite(1);
                      message = "";
                      _controller.text = "";
                      setState(() {
                        maxLines = 1;
                      });
                    }
                  },
                  child: Icon(
                    FontAwesome.paper_plane_o,
                    color: Color(0xFF565D76),
                    size: sizeWidth / 14.5,
                  ),
                ),
        ],
      ),
    );
  }
}
