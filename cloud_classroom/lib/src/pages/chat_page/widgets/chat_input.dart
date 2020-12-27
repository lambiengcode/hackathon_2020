import 'dart:async';
import 'dart:io';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_lists.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:whoru/src/models/menu_item.dart';
import 'package:whoru/src/models/user.dart';
import 'package:whoru/src/utils/constants.dart';

class ChatInput extends StatefulWidget {
  final String roomID;
  final int color;
  final index;
  final String receiveID;
  final VoidCallback showSnackbar;

  ChatInput(
      {this.roomID, this.showSnackbar, this.receiveID, this.index, this.color});

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();
  String message = "";
  int maxLines = 1;
  File _image;
  bool isWriting = false;
  bool showEmojiPicker = false;
  bool record = false;
  bool media = true;
  String filePath = '';
  List<String> filePaths = List();
  List<String> urlToImages = List();
  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();
    message = "";
    textFieldController.text = "";
  }

  List<SendMenuItems> menuItems = [
    SendMenuItems(text: "Videos", icons: Icons.image, color: Colors.deepPurple),
    SendMenuItems(
        text: "Document", icons: Icons.insert_drive_file, color: Colors.blue),
    SendMenuItems(
        text: "Location", icons: Icons.location_on, color: Colors.green),
  ];

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        4.0,
      ),
      margin: EdgeInsets.fromLTRB(
        24.0,
        .0,
        24.0,
        16.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          30.0,
        ),
        color: Colors.grey.shade50,
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(.04)
                : Color(0xFFABBAD5),
            spreadRadius: 1.0,
            blurRadius: 1.25,
            offset: Offset(0, 2.0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          chatControls(),
          showEmojiPicker
              ? Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // 2 button : Icons & Sticker
                      emojiContainer(),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      noRecentsStyle: TextStyle(
        color: Color(widget.color),
      ),
      bgColor: Colors.transparent,
      indicatorColor: Colors.white38,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
          message = message += emoji.emoji;
        });
        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad", "dog", "smile"],
      numRecommended: 40,
      buttonMode: ButtonMode.MATERIAL,
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    final user = Provider.of<User>(context);
    final sizeWidth = MediaQuery.of(context).size.width;

    Future<List<String>> uploadImage(List<File> _imageFile) async {
      List<String> _urllist = [];
      await _imageFile.forEach((image) async {
        String rannum =
            user.uid + DateTime.now().millisecondsSinceEpoch.toString();
        StorageReference reference =
            FirebaseStorage.instance.ref().child('Reviews').child(rannum);
        StorageUploadTask uploadTask = reference.putFile(image);
        StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
        String _url = await downloadUrl.ref.getDownloadURL();
        _urllist.add(_url);
      });

      return _urllist;
    }

    Future<void> _pushListImage(type) async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        CollectionReference reference =
            Firestore.instance.collection("datachatrooms");
        await reference.add({
          'id': user.uid,
          'message': 'Send Image',
          'hour': DateTime.now().hour,
          'min': DateTime.now().minute,
          'sec': DateTime.now().second,
          'room': widget.roomID,
          'publishAt': DateTime.now(),
          'type': type,
          'seen': false,
          'filePaths': filePaths,
          'receiveID': widget.receiveID,
          'images': '',
        });
      });
    }

    Future<void> _updateTime(index) async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        await transaction.update(index, {
          'publishAt': DateTime.now(),
        });
      });
    }

    Future<void> _pushImage(type) async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        CollectionReference reference =
            Firestore.instance.collection("datachatrooms");
        await reference.add({
          'id': user.uid,
          'message': 'Send a image',
          'hour': DateTime.now().hour,
          'min': DateTime.now().minute,
          'sec': DateTime.now().second,
          'room': widget.roomID,
          'publishAt': DateTime.now(),
          'type': type,
          'seen': false,
          'filePath': filePath,
          'receiveID': widget.receiveID,
          'images': '',
        });
      });
    }

    Future<void> _pickImage(ImageSource source, index) async {
      File selected = await ImagePicker.pickImage(source: source);
      setState(() {
        _image = selected;
      });
      if (_image != null) {
        await _updateTime(index);
        await _pushImage('image');
      }
    }

    Future<void> _pushMessage(message, type) async {
      Firestore.instance.runTransaction((Transaction transaction) async {
        CollectionReference reference =
            Firestore.instance.collection("datachatrooms");
        await reference.add({
          'id': user.uid,
          'message': message,
          'hour': DateTime.now().hour,
          'min': DateTime.now().minute,
          'sec': DateTime.now().second,
          'room': widget.roomID,
          'publishAt': DateTime.now(),
          'type': type,
          'seen': false,
          'receiveID': widget.receiveID,
        });
      });
    }

    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 10.0,
          ),
          IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              if (!showEmojiPicker) {
                // keyboard is visible
                hideKeyboard();
                showEmojiContainer();
              } else {
                //keyboard is hidden
                showKeyboard();
                hideEmojiContainer();
              }
            },
            icon: Icon(
              FontAwesome5Solid.kiss_wink_heart,
              color: Color(widget.color),
              size: sizeWidth / 16.5,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  onTap: () {
                    hideEmojiContainer();
                    setState(() {
                      media = false;
                    });
                  },
                  style: TextStyle(
                      color: Colors.grey.shade800, fontSize: sizeWidth / 26),
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  keyboardType: TextInputType.multiline,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(
                      left: 8.0,
                      right: 40.0,
                      bottom: 4.0,
                      top: 4.0,
                    ),
                    hintText: 'Type message...',
                    hintStyle: TextStyle(
                        color: Colors.blueGrey[800], fontSize: sizeWidth / 26),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (mes) {
                    setState(() {
                      if (mes.length == 0) {
                        maxLines = 1;
                      } else {
                        if (mes.length > 18) {
                          maxLines = 2;
                        }
                      }

                      (mes.length != 0)
                          ? setWritingTo(true)
                          : setWritingTo(false);

                      (mes.length != 0) ? media = false : media = true;

                      return message = mes.trim();
                    });
                  },
                ),
              ],
            ),
          ),
          message.length == 0
              ? IconButton(
                  icon: Icon(
                    Icons.mic,
                    size: sizeWidth / 14.0,
                    color: Color(widget.color),
                  ),
                  onPressed: () async {},
                )
              : StreamBuilder(
                  stream: Firestore.instance
                      .collection('chatrooms')
                      .where('room', isEqualTo: widget.roomID)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return IconButton(
                        icon: Icon(
                          FontAwesome.send,
                          color: message.length == 0
                              ? Colors.white
                              : Color(widget.color),
                          size: sizeWidth / 14.5,
                        ),
                        onPressed: () {},
                      );
                    }

                    return IconButton(
                        icon: Icon(
                          FontAwesome.send,
                          color: message.length == 0
                              ? Colors.white
                              : Color(widget.color),
                          size: sizeWidth / 16.5,
                        ),
                        onPressed: () async {
                          if (message != "") {
                            await _pushMessage(message, 'text');
                            message = "";
                            textFieldController.text = "";
                            await _updateTime(
                                snapshot.data.documents[0].reference);
                            setState(() {
                              maxLines = 1;
                            });
                          }
                        });
                  },
                ),
          SizedBox(
            width: 4.0,
          ),
        ],
      ),
    );
  }

  void showModal() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.width * 0.8,
            color: ThemeProvider.of(context).brightness == Brightness.dark
                ? Colors.black54
                : Color(0xff737373),
            child: Container(
              decoration: BoxDecoration(
                color: ThemeProvider.of(context).brightness == Brightness.dark
                    ? kDarkSecondaryColor
                    : kLightSecondaryColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20)),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: Container(
                      height: 4,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    itemCount: menuItems.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: menuItems[index].color.shade100,
                            ),
                            height: 50,
                            width: 50,
                            child: Icon(
                              menuItems[index].icons,
                              size: 20,
                              color: menuItems[index].color.shade400,
                            ),
                          ),
                          title: Text(menuItems[index].text),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          );
        });
  }
}
