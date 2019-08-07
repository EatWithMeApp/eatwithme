import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/services/db.dart';
import 'package:eatwithme/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:eatwithme/pages/chat/constant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pass userID and peerID to fix UI
// Multi provide both peer and chat room
// Change how chat mesasges are written to firestore
// Change how chat messages are read to firestore

class ChatRoomPage extends StatelessWidget {
  final String peerId;

  ChatRoomPage({
    Key key,
    @required this.peerId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var db = DatabaseService();

    return StreamProvider<User>.value(
      value: db.streamUser(peerId),
      child: ChatPage(),
    );
  }
}

class ChatPage extends StatelessWidget {
  //TODO: test this works for placeholder - if it does replace ProfilePhoto!
  static String buildPeerAvatar(String peerAvatar) {
    String avatarURL = peerAvatar;

    if (avatarURL == null) {
      avatarURL = PROFILE_PHOTO_PLACEHOLDER_PATH;
    }

    return avatarURL;
  }

  @override
  Widget build(BuildContext context) {
    var peer = Provider.of<User>(context);
    var loggedInUser = Provider.of<FirebaseUser>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Material(
              borderRadius: BorderRadius.all(Radius.circular(180.0)),
              clipBehavior: Clip.hardEdge,
              child: FadeInImage.assetNetwork(
                placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
                image: buildPeerAvatar(peer.photoURL),
                width: 35.0,
                height: 35.0,
                fit: BoxFit.cover,
              ),
            ),
            Text(
              ' ' + peer.displayName,
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
      body: ChatScreen(
          // userId: userId,
          // peerId: peerId,
          // peerAvatar: peerAvatar,
          ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String userId;
  final String peerId;
  // final String peerAvatar;

  final String chatRoomId;

  ChatScreen({
    Key key,
    @required this.chatRoomId,
    @required this.userId,
    @required this.peerId,
    // @required this.peerAvatar
  }) : super(key: key);

  @override
  State createState() => new ChatScreenState(
      // userId: userId,
      // peerId: peerId, peerAvatar: peerAvatar
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

  var listMessage;
  // String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    // groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    //Make group ID from userID and peerID
    // makeGroupId();

    // Future.delayed(Duration.zero, () {
    //   var loggedInUser = Provider.of<FirebaseUser>(context);
    //   var peer =
    // });
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  // makeGroupId() async {
  //   if (userId.hashCode <= peerId.hashCode) {
  //     groupChatId = '$userId-$peerId';
  //   } else {
  //     groupChatId = '$peerId-$userId';
  //   }

  //   setState(() {});
  // }

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
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var userUids = List<String>();
      userUids.add(groupChatId.split('-')[0]);
      userUids.add(groupChatId.split('-')[1]);

      var rightNow = DateTime.now();

      // Make Chat in Chats
      Firestore.instance.collection('Chats').document(groupChatId).setData(
          {'userUids': userUids, 'lastModified': rightNow},
          merge: true);

      // Make Message in Messages
      var documentReference =
          Firestore.instance.collection('Messages').document();

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'chatId': groupChatId,
            'idFrom': widget.userId,
            'idTo': widget.peerId,
            'timestamp': rightNow.millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  // bool isLastMessageLeft(List<Message> messages, int index) {
  //   if ((index > 0 &&
  //           messages != null &&
  //           messages[index - 1]['idFrom'] == widget.userId) ||
  //       index == 0) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  // bool isLastMessageRight(int index) {
  //   if ((index > 0 &&
  //           listMessage != null &&
  //           listMessage[index - 1]['idFrom'] != widget.userId) ||
  //       index == 0) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

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
    // var chatRoom = Provider.of<ChatRoom>(context);

    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ChatMessageList(),

                // Show sticker picker when selected
                (isShowSticker ? buildStickerPicker() : Container()),

                buildInputFields(),
              ],
            ),
          ),
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildStickerPicker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: new Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: new Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: new Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: new Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: new Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: new Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: new Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: new Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: new Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
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
                onPressed: () => onSendMessage(textEditingController.text, 0),
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

class ChatMessageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('Messages')
                  .where('chatId', isEqualTo: groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(themeColor)));
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => new ChatMessageItem(
                        widget: widget,
                        index: index,
                        document: listMessage[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}

class ChatMessageItem extends StatelessWidget {
  const ChatMessageItem({
    Key key,
    // @required this.widget,
    @required this.index, 
    @required this.message,
    @required this.loggedInUid, this.prevMessage, this.mostRecentMessage,
    @required this.messages,
  }) : super(key: key);

  // final ChatScreen widget;
  final List<Message> messages;
  final int index;

  final Message message;
  final Message prevMessage;
  final Message mostRecentMessage;
  final String loggedInUid;

  var ownMessage = message.isMessageFromUser(loggedInUid);

  Widget chatBubble(Message prevMsg) {
    var bubbleWidth = 200.0;
    var bubbleHeight = 200.0;
    var stickerWidth = 100.0;
    var stickerHeight = 100.0;

    var textColour = (ownMessage) ? primaryColor : Colors.white;
    var bubbleColour = (ownMessage) ? greyColor2 : primaryColor;
    var leftMargin = (ownMessage) ? 0.0 : 10.0;
    var bottomMargin =
        (message.isPrevMessageSameSide(prevMsg, loggedInUid)) ? 20.0 : 10.0;
    var rightMargin = (ownMessage) ? 10.0 : 0.0;

    var content = Container();
    if (message.type == MessageType.text) {
      content = Container(
        child: Text(
          message.content,
          style: TextStyle(color: textColour),
        ),
        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        width: bubbleWidth,
        decoration: BoxDecoration(
            color: bubbleColour, borderRadius: BorderRadius.circular(8.0)),
        margin: EdgeInsets.only(
            bottom: bottomMargin, right: rightMargin, left: leftMargin),
      );
    } else if (message.type == MessageType.image) {
      content = Container(
        child: Material(
          child: CachedNetworkImage(
            placeholder: (context, url) => Container(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
              width: bubbleWidth,
              height: bubbleHeight,
              padding: EdgeInsets.all(70.0),
              decoration: BoxDecoration(
                color: bubbleColour,
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Material(
              child: Image.asset(
                'images/img_not_available.jpeg',
                width: bubbleWidth,
                height: bubbleHeight,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
            ),
            imageUrl: message.content,
            width: bubbleWidth,
            height: bubbleHeight,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          clipBehavior: Clip.hardEdge,
        ),
        margin: EdgeInsets.only(bottom: bottomMargin, right: rightMargin),
      );
    } else if (message.type == MessageType.sticker) {
      Container(
        child: new Image.asset(
          'images/${message.content}.gif',
          width: stickerWidth,
          height: stickerHeight,
          fit: BoxFit.cover,
        ),
        margin: EdgeInsets.only(
            bottom: bottomMargin, right: rightMargin, left: leftMargin),
      );
    }
    return content;
  }

  Widget profileImage() {
    var profile;

    if (message.shouldDrawPeerProfilePhoto(mostRecentMessage, loggedInUid)) {
      profile = Material(
                        child: FadeInImage.assetNetwork(
                          placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
                          image: message.,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      );
    } else {
      profile = Container(width: 35.0);
    }
    return profile;
  }

  Widget timestamp() {
    isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: TextStyle(
                          color: greyColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
  }

  @override
  Widget build(BuildContext context) {

    if (message.isMessageFromUser(loggedInUid)) {
      return Row(
        children: <Widget>[
          chatBubble(),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                profileImage(),
                chatBubble(),
              ],
            ),
            timestamp(),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }


    // if (document['idFrom'] == widget.userId) {
    //   // Right (my message)
    //   return Row(
    //     children: <Widget>[
    //       document['type'] == 0
    //           // Text
    //           ? Container(
    //               child: Text(
    //                 document['content'],
    //                 style: TextStyle(color: primaryColor),
    //               ),
    //               padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
    //               width: 200.0,
    //               decoration: BoxDecoration(
    //                   color: greyColor2,
    //                   borderRadius: BorderRadius.circular(8.0)),
    //               margin: EdgeInsets.only(
    //                   bottom:
    //                       ChatScreen.isLastMessageRight(index) ? 20.0 : 10.0,
    //                   right: 10.0),
    //             )
    //           : document['type'] == 1
    //               // Image
    //               ? Container(
    //                   child: Material(
    //                     child: CachedNetworkImage(
    //                       placeholder: (context, url) => Container(
    //                         child: CircularProgressIndicator(
    //                           valueColor:
    //                               AlwaysStoppedAnimation<Color>(themeColor),
    //                         ),
    //                         width: 200.0,
    //                         height: 200.0,
    //                         padding: EdgeInsets.all(70.0),
    //                         decoration: BoxDecoration(
    //                           color: greyColor2,
    //                           borderRadius: BorderRadius.all(
    //                             Radius.circular(8.0),
    //                           ),
    //                         ),
    //                       ),
    //                       errorWidget: (context, url, error) => Material(
    //                         child: Image.asset(
    //                           'images/img_not_available.jpeg',
    //                           width: 200.0,
    //                           height: 200.0,
    //                           fit: BoxFit.cover,
    //                         ),
    //                         borderRadius: BorderRadius.all(
    //                           Radius.circular(8.0),
    //                         ),
    //                         clipBehavior: Clip.hardEdge,
    //                       ),
    //                       imageUrl: document['content'],
    //                       width: 200.0,
    //                       height: 200.0,
    //                       fit: BoxFit.cover,
    //                     ),
    //                     borderRadius: BorderRadius.all(Radius.circular(8.0)),
    //                     clipBehavior: Clip.hardEdge,
    //                   ),
    //                   margin: EdgeInsets.only(
    //                       bottom: isLastMessageRight(index) ? 20.0 : 10.0,
    //                       right: 10.0),
    //                 )
    //               // Sticker
    //               : Container(
    //                   child: new Image.asset(
    //                     'images/${document['content']}.gif',
    //                     width: 100.0,
    //                     height: 100.0,
    //                     fit: BoxFit.cover,
    //                   ),
    //                   margin: EdgeInsets.only(
    //                       bottom: isLastMessageRight(index) ? 20.0 : 10.0,
    //                       right: 10.0),
    //                 ),
    //     ],
    //     mainAxisAlignment: MainAxisAlignment.end,
    //   );
    // } else {
    //   // Left (peer message)
    //   return Container(
    //     child: Column(
    //       children: <Widget>[
    //         Row(
    //           children: <Widget>[
    //             isLastMessageLeft(index)
    //                 ? Material(
    //                     child: FadeInImage.assetNetwork(
    //                       placeholder: PROFILE_PHOTO_PLACEHOLDER_PATH,
    //                       image: ChatRoomPage.buildPeerAvatar(peerAvatar),
    //                       width: 35.0,
    //                       height: 35.0,
    //                       fit: BoxFit.cover,
    //                     ),
    //                     borderRadius: BorderRadius.all(
    //                       Radius.circular(18.0),
    //                     ),
    //                     clipBehavior: Clip.hardEdge,
    //                   )
    //                 : Container(width: 35.0),
    //             document['type'] == 0
    //                 ? Container(
    //                     child: Text(
    //                       document['content'],
    //                       style: TextStyle(color: Colors.white),
    //                     ),
    //                     padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
    //                     width: 200.0,
    //                     decoration: BoxDecoration(
    //                         color: primaryColor,
    //                         borderRadius: BorderRadius.circular(8.0)),
    //                     margin: EdgeInsets.only(left: 10.0),
    //                   )
    //                 : document['type'] == 1
    //                     ? Container(
    //                         child: Material(
    //                           child: CachedNetworkImage(
    //                             placeholder: (context, url) => Container(
    //                               child: CircularProgressIndicator(
    //                                 valueColor: AlwaysStoppedAnimation<Color>(
    //                                     themeColor),
    //                               ),
    //                               width: 200.0,
    //                               height: 200.0,
    //                               padding: EdgeInsets.all(70.0),
    //                               decoration: BoxDecoration(
    //                                 color: greyColor2,
    //                                 borderRadius: BorderRadius.all(
    //                                   Radius.circular(8.0),
    //                                 ),
    //                               ),
    //                             ),
    //                             errorWidget: (context, url, error) => Material(
    //                               child: Image.asset(
    //                                 'images/img_not_available.jpeg',
    //                                 width: 200.0,
    //                                 height: 200.0,
    //                                 fit: BoxFit.cover,
    //                               ),
    //                               borderRadius: BorderRadius.all(
    //                                 Radius.circular(8.0),
    //                               ),
    //                               clipBehavior: Clip.hardEdge,
    //                             ),
    //                             imageUrl: document['content'],
    //                             width: 200.0,
    //                             height: 200.0,
    //                             fit: BoxFit.cover,
    //                           ),
    //                           borderRadius:
    //                               BorderRadius.all(Radius.circular(8.0)),
    //                           clipBehavior: Clip.hardEdge,
    //                         ),
    //                         margin: EdgeInsets.only(left: 10.0),
    //                       )
    //                     : Container(
    //                         child: new Image.asset(
    //                           'images/${document['content']}.gif',
    //                           width: 100.0,
    //                           height: 100.0,
    //                           fit: BoxFit.cover,
    //                         ),
    //                         margin: EdgeInsets.only(
    //                             bottom: isLastMessageRight(index) ? 20.0 : 10.0,
    //                             right: 10.0),
    //                       ),
    //           ],
    //         ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: TextStyle(
                          color: greyColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }
}
