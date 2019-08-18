import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/chat/chat_message_list.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/widgets/profile_photo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/chat/constant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'chat_message_list.dart';

class ChatRoomPage extends StatelessWidget {
  final String peerId;

  ChatRoomPage({
    Key key,
    @required this.peerId,
  }) : super(key: key);

  void verifyChatRoom(List<String> userUids) async {
    var db = DatabaseService();
    await db.verifyChatRoom(userUids);
  }

  @override
  Widget build(BuildContext context) {
    var db = DatabaseService();
    var loggedInUser = Provider.of<FirebaseUser>(context);
    var userUids = [loggedInUser.uid, peerId];
    var roomId = ChatRoom.generateID(userUids);

    verifyChatRoom(userUids);

    return MultiProvider(
      providers: [
        StreamProvider<Iterable<Message>>.value(
            value: db.streamMessagesFromChatRoom(roomId, loggedInUser.uid)),
        StreamProvider<User>.value(
            value: db.streamUserInChatRoom(roomId, loggedInUser.uid)),
      ],
      child: ChatPage(),
    );
  }
}

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var peerUser = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Material(
              borderRadius: BorderRadius.all(Radius.circular(180.0)),
              clipBehavior: Clip.hardEdge,
              child: ProfilePhoto(
                profileURL: peerUser.photoURL,
                height: 35.0,
                width: 35.0,
              ).getWidget(),
            ),
            Text(
              ' ' + peerUser.displayName,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF333333),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final textEditingController = TextEditingController();
  final focusNode = FocusNode();

  final chatMessageList = ChatMessageList();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    // groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false; 
      });
      onSendMessage(imageUrl, MessageType.image);
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, MessageType messageType) {
    if (content.trim() == '') {
      Fluttertoast.showToast(msg: 'Nothing to send');
      return;
    }

    textEditingController.clear();

    var userUids = List<String>();
    var loggedInUid = Provider.of<FirebaseUser>(context).uid;
    userUids.add(loggedInUid);
    userUids.add(Provider.of<User>(context).uid);

    var db = DatabaseService();

    db.writeMessageToChatRoom(
        userUids,
        Message.fromMap({
          'type': messageType.index,
          'content': content,
          'uidFrom': loggedInUid,
          'timestamp': Timestamp.fromMillisecondsSinceEpoch(
              DateTime.now().millisecondsSinceEpoch),
        }));

    chatMessageList.scrollToPosition(0.0, 300, Curves.easeOut);

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ChatMessageList(),

                // Sticker
                (isShowSticker ? buildStickerList() : Container()),

                // Input content
                buildInputFields(),
              ],
            ),
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker(int index) {
    var content = 'mimi$index';
    var imagePath = 'images/mimi$index.gif';

    return FlatButton(
      onPressed: () => onSendMessage(content, MessageType.sticker),
      child: new Image.asset(
        imagePath,
        width: 50.0,
        height: 50.0,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildStickerList() {
    return Container(
      height: 180.0,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
        color: greyColor2,
      ),
      child: GridView.count(
        crossAxisCount: 3,
        scrollDirection: Axis.vertical,
        mainAxisSpacing: 5.0,
        children: List.generate(9, (index) {
          return buildSticker(index + 1);
        }),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInputFields() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () =>
                    onSendMessage(textEditingController.text, MessageType.text),
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }
}
