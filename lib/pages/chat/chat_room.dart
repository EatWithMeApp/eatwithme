import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/chat/chat_message_list.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:eatwithme/widgets/profile_photo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/chat/constant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static String buildPeerAvatar(String peerAvatar) {
    String avatarURL = peerAvatar;

    if (avatarURL == null) {
      avatarURL = PROFILE_PHOTO_PLACEHOLDER_PATH;
    }

    return avatarURL;
  }

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
              child: FadeInImage.assetNetwork(
                placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
                image: buildPeerAvatar(peerUser.photoURL),
                width: 35.0,
                height: 35.0,
                fit: BoxFit.cover,
              ),
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
  // final String userId;
  // final String peerId;
  // final String peerAvatar;

  ChatScreen({
    Key key,
    // @required this.userId,
    // @required this.peerId,
    // @required this.peerAvatar
  }) : super(key: key);

  @override
  State createState() => new ChatScreenState(
      // userId: userId, peerId: peerId, peerAvatar: peerAvatar
      );
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({
    Key key,
    // @required this.userId,
    // @required this.peerId,
    // @required this.peerAvatar
  });

  // String peerId;
  // String peerAvatar;
  // String userId;

  // var listMessage;
  // String groupChatId;
  // SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final textEditingController = TextEditingController();
  // final ScrollController listScrollController = new ScrollController();
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
        onSendMessage(imageUrl, MessageType.image);
      });
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
    // userUids.add(groupChatId.split('-')[0]);
    // userUids.add(groupChatId.split('-')[1]);
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
          'timestamp': Timestamp.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch),
        }));

    chatMessageList.scrollToPosition(0.0, 300, Curves.easeOut);

    // // Make Chat in Chats
    // Firestore.instance.collection('Chats').document(groupChatId).setData(
    //     {'userUids': userUids, 'lastModified': rightNow},
    //     merge: true);

    // // Make Message in Messages
    // var documentReference =
    //     Firestore.instance.collection('Messages').document();

    // Firestore.instance.runTransaction((transaction) async {
    //   await transaction.set(
    //     documentReference,
    //     {
    //       'chatId': groupChatId,
    //       'idFrom': userId,
    //       'idTo': peerId,
    //       'timestamp': rightNow.millisecondsSinceEpoch.toString(),
    //       'content': content,
    //       'type': type
    //     },
    //   );
    // });

    // listScrollController.animateTo(0.0,
    //     duration: Duration(milliseconds: 300), curve: Curves.easeOut);
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
                //Provide messages AND users in room
                ChatMessageList(),

                // StreamProvider.value(
                //   value:
                //       db.streamMessagesFromChatRoom(roomId, loggedInUser.uid),
                //   child: ChatMessageList(),
                // ),

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
    // return Container(
    //   child: Column(
    //     children: <Widget>[
    //       Row(
    //         children: <Widget>[
    //           FlatButton(
    //             onPressed: () => onSendMessage('mimi1', 2),
    //             child: new Image.asset(
    //               'images/mimi1.gif',
    //               width: 50.0,
    //               height: 50.0,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //           FlatButton(
    //             onPressed: () => onSendMessage('mimi2', 2),
    //             child: new Image.asset(
    //               'images/mimi2.gif',
    //               width: 50.0,
    //               height: 50.0,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //           FlatButton(
    //             onPressed: () => onSendMessage('mimi3', 2),
    //             child: new Image.asset(
    //               'images/mimi3.gif',
    //               width: 50.0,
    //               height: 50.0,
    //               fit: BoxFit.cover,
    //             ),
    //           )
    //         ],
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       ),
    //       Row(
    //         children: <Widget>[
    //           FlatButton(
    //             onPressed: () => onSendMessage('mimi4', 2),
    //             child: new Image.asset(
    //               'images/mimi4.gif',
    //               width: 50.0,
    //               height: 50.0,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //           FlatButton(
    //             onPressed: () => onSendMessage('mimi5', 2),
    //             child: new Image.asset(
    //               'images/mimi5.gif',
    //               width: 50.0,
    //               height: 50.0,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //           FlatButton(
    //             onPressed: () => onSendMessage('mimi6', 2),
    //             child: new Image.asset(
    //               'images/mimi6.gif',
    //               width: 50.0,
    //               height: 50.0,
    //               fit: BoxFit.cover,
    //             ),
    //           )
    //         ],
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       ),
    //       Row(
    //         children: <Widget>[
    //           FlatButton(
    //             onPressed: () => onSendMessage('mimi7', 2),
    //             child: new Image.asset(
    //               'images/mimi7.gif',
    //               width: 50.0,
    //               height: 50.0,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //           FlatButton(
    //             onPressed: () => onSendMessage('mimi8', 2),
    //             child: new Image.asset(
    //               'images/mimi8.gif',
    //               width: 50.0,
    //               height: 50.0,
    //               fit: BoxFit.cover,
    //             ),
    //           ),
    //           FlatButton(
    //             onPressed: () => onSendMessage('mimi9', 2),
    //             child: new Image.asset(
    //               'images/mimi9.gif',
    //               width: 50.0,
    //               height: 50.0,
    //               fit: BoxFit.cover,
    //             ),
    //           )
    //         ],
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       )
    //     ],
    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   ),
    //   decoration: new BoxDecoration(
    //       border:
    //           new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
    //       color: Colors.white),
    //   padding: EdgeInsets.all(5.0),
    //   height: 180.0,
    // );

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
