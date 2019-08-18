import 'package:cached_network_image/cached_network_image.dart';
import 'package:eatwithme/models/models.dart';
import 'package:eatwithme/pages/chat/constant.dart';
import 'package:eatwithme/widgets/profile_photo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatMessageItem extends StatelessWidget {
  const ChatMessageItem({
    Key key,
    @required this.message,
    @required this.prevMessage,
    @required this.mostRecentMessage,
    @required this.photoURL,
  }) : super(key: key);

  final Message message;
  final Message prevMessage;
  final Message mostRecentMessage;
  final String photoURL;

  Widget chatBubble(String loggedInUid) {
    bool ownMessage = message.isMessageFromUser(loggedInUid);

    var bubbleWidth = 200.0;
    var bubbleHeight = 200.0;
    var stickerWidth = 100.0;
    var stickerHeight = 100.0;

    var textColour = (ownMessage) ? primaryColor : Colors.white;
    var bubbleColour = (ownMessage) ? greyColor2 : primaryColor;
    var leftMargin = (ownMessage) ? 0.0 : 10.0;
    var bottomMargin =
        (message.isPrevMessageSameSide(prevMessage, loggedInUid)) ? 20.0 : 10.0;
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
      content = Container(
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

  Widget profileImage(String loggedInUid) {
    var profile;

    if (message.shouldDrawPeerProfilePhoto(mostRecentMessage, loggedInUid)) {
      profile = Material(
        child: ProfilePhoto(profileURL: photoURL, width: 35.0, height: 35.0)
            .getWidget(),
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

  Widget timestamp(String loggedInUid) {
    return message.isPeerMessage(loggedInUid) && (message.id == mostRecentMessage.id)
        ? Container(
            child: Text(
              DateFormat('dd MMM kk:mm').format(message.timestamp),
              style: TextStyle(
                  color: greyColor,
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic),
            ),
            margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
          )
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    var loggedinUser = Provider.of<FirebaseUser>(context);
    
    if (message.isMessageFromUser(loggedinUser.uid)) {
      return Row(
        children: <Widget>[
          chatBubble(loggedinUser.uid),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                profileImage(loggedinUser.uid),
                chatBubble(loggedinUser.uid),
              ],
            ),
            timestamp(loggedinUser.uid),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }
}

