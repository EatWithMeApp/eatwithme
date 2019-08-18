import 'package:eatwithme/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_message_item.dart';

class ChatMessageList extends StatelessWidget {
  final ScrollController listScrollController = ScrollController();

  void scrollToPosition(double offset, int milliseconds, Curve curve) {
    listScrollController.animateTo(offset,
        duration: Duration(milliseconds: milliseconds), curve: curve);
  }

  @override
  Widget build(BuildContext context) {
    var messages = Provider.of<Iterable<Message>>(context);
    var roomUser = Provider.of<User>(context);

    if (messages == null) {
      // TODO: Build nice widget if wrong/bad chat room got loaded
      return Container();
    }

    return Flexible(
        child: ListView.builder(
      padding: EdgeInsets.all(10.0),
      itemBuilder: (context, index) => ChatMessageItem(
        message: messages.elementAt(index),
        prevMessage: messages.elementAt((index < 1) ? 0 : index - 1),
        mostRecentMessage: messages.last,
        photoURL: roomUser.photoURL,
      ),
      itemCount: messages.length,
      reverse: true,
      controller: listScrollController,
    ));
  }
}
