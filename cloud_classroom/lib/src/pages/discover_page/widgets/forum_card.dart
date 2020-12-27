import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/widgets/bookmark_bottomsheet.dart';
import 'package:whoru/src/widgets/chat_bottomsheet.dart';

import '../../../models/user.dart';
import '../../../widgets/photo_viewer.dart';

class ForumCard extends StatefulWidget {
  final DocumentSnapshot info;
  final DocumentSnapshot userInfo;
  ForumCard({this.info, this.userInfo});
  @override
  State<StatefulWidget> createState() => _ForumCardState();
}

class _ForumCardState extends State<ForumCard> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 42.0,
                    width: 42.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                      image: DecorationImage(
                        image: widget.userInfo['urlToImage'] == ''
                            ? AssetImage('images/logo.png')
                            : NetworkImage(widget.userInfo['urlToImage']),
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
                        widget.userInfo['username'],
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
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              widget.info['content'],
              style: TextStyle(
                fontSize: _size.width / 24.0,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          widget.info['filePath'] == ''
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'File:\t\t',
                          style: TextStyle(
                            fontSize: _size.width / 24.0,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '[Download]',
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
            height: 16.0,
          ),
          widget.info['urlToImage'] == ''
              ? Container()
              : GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PhotoViewer(
                        image: widget.info['urlToImage'],
                      ),
                    ),
                  ),
                  child: Container(
                    height: 240.0,
                    margin: EdgeInsets.only(
                      right: 8.0,
                      left: 2.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.info['urlToImage'],
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 10.0,
          ),
          Divider(
            height: .25,
            thickness: .25,
            color: Colors.grey.shade300,
          ),
          SizedBox(
            height: 12.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAction(
                context,
                widget.info['id'],
                'Comment',
                Feather.message_square,
                Colors.grey.shade600,
                null,
                true,
              ),
              StreamBuilder(
                stream: Firestore.instance
                    .collection('favourites')
                    .where('id', isEqualTo: user.uid)
                    .where('post', isEqualTo: widget.info['id'])
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return _buildAction(
                      context,
                      widget.info['id'],
                      'Favourite',
                      Feather.heart,
                      Colors.grey.shade600,
                      null,
                      false,
                    );
                  }

                  List<DocumentSnapshot> docs = snapshot.data.documents;

                  return _buildAction(
                    context,
                    widget.info['id'],
                    'Favourite',
                    Feather.heart,
                    docs.length == 0 ? Colors.grey.shade600 : Colors.redAccent,
                    docs.length == 0 ? null : docs[0].reference,
                    true,
                  );
                },
              ),
              _buildAction(
                context,
                widget.info['id'],
                'Bookmark',
                Feather.bookmark,
                Colors.grey.shade600,
                null,
                true,
              ),
              _buildAction(
                context,
                widget.info['id'],
                'Share',
                Feather.share_2,
                Colors.grey.shade600,
                null,
                true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    context,
    post,
    title,
    icon,
    color,
    index,
    done,
  ) {
    Future<void> _favourite(id, post) async {
      Firestore.instance.collection('favourites').add({
        'id': id,
        'publishAt': DateTime.now(),
        'post': post,
      });
    }

    Future<void> _unFavourite() async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        await transaction.delete(index);
      });
    }

    void showChatBottomSheet() {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0))),
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return CommentBottomSheet(
              index: index,
              idPost: post,
            );
          });
    }

    void showSaveBottomSheet() {
      showModalBottomSheet(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0))),
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return BookmarkBottomSheet(
              idPost: post,
            );
          });
    }

    final _size = MediaQuery.of(context).size;
    final user = Provider.of<User>(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (done) {
            switch (title) {
              case 'Favourite':
                index == null ? _favourite(user.uid, post) : _unFavourite();
                break;
              case 'Bookmark':
                showSaveBottomSheet();
                break;
              case 'Comment':
                showChatBottomSheet();
                break;
              case 'Share':
                Get.snackbar(
                  '',
                  '',
                  colorText: Colors.white,
                  backgroundColor: Colors.black45,
                  dismissDirection: SnackDismissDirection.HORIZONTAL,
                  duration: Duration(
                    milliseconds: 2000,
                  ),
                  titleText: Text(
                    'Comming Soon!',
                    style: TextStyle(
                      fontSize: _size.width / 24.5,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  messageText: Text(
                    'This feature will available in next version.',
                    style: TextStyle(
                      fontSize: _size.width / 26.0,
                      color: Colors.white.withOpacity(.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20.0,
                    20.0,
                    8.0,
                    18.0,
                  ),
                );
                break;
              default:
                break;
            }
          }
        },
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: _size.width / 18.5,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
