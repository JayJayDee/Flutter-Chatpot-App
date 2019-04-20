import 'package:meta/meta.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatpot_app/entities/message.dart';
import 'package:chatpot_app/models/app_state.dart';
import 'package:chatpot_app/factory.dart';
import 'package:chatpot_app/styles.dart';

enum _RowType {
  NOTIFICATION, MY_MSG, OTHER_MSG
}

typedef ImageClickCallback (String messageId);

@immutable
class MessageRow extends StatelessWidget {

  final Message message;
  final AppState state;
  final ImageClickCallback imageClickCallback;

  MessageRow({
    @required this.message,
    @required this.state,
    @required this.imageClickCallback
  });

  Widget build(BuildContext context) {
    String myToken = state.member.token;
    _RowType type = judgeRowType(message, myToken);

    Widget widget;
    if (type == _RowType.MY_MSG) {
      widget = _MyMessageRow(
        message: message,
        imageClickCallback: imageClickCallback
      );

    } else if (type == _RowType.OTHER_MSG) {
      widget = _OtherMessageRow(
        message: message,
        appState: state,
        imageClickCallback: imageClickCallback
      );

    } else if (type ==_RowType.NOTIFICATION) {
      widget = _NotificationRow(
        message: message
      );
    }
    return Center(
      child: widget
    );
  }

  _RowType judgeRowType(Message msg, String myToken) {
    if (msg.messageType == MessageType.NOTIFICATION) return _RowType.NOTIFICATION;
    else if (msg.from.token == myToken) return _RowType.MY_MSG;
    return _RowType.OTHER_MSG;
  }
}

class _NotificationRow extends StatelessWidget {
  final Message message;

  _NotificationRow({
    this.message
  });

  Widget build(BuildContext context) {
    String text = locales().message.notificationText(message.getNotificationContent());
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(5),
                color: Styles.secondaryFontColor,
                child: Text(text,
                  style: TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.white
                  )
                )
              )
            )
          )
        ]
      )
    );
  }
}

class _MyMessageRow extends StatelessWidget {
  final Message message;
  final ImageClickCallback imageClickCallback;

  _MyMessageRow({
    this.message,
    this.imageClickCallback
  });

  Widget build(BuildContext context) {
    Widget contentWidget;
    if (message.messageType == MessageType.TEXT) {
      contentWidget = _getTextContentWidget(message);
    } else if (message.messageType == MessageType.IMAGE) {
      if (message.attchedImageStatus == AttchedImageStatus.LOCAL_IMAGE) {
        contentWidget = _getLoadingImageContentWidget(message);
      } else if (message.attchedImageStatus == AttchedImageStatus.REMOTE_IMAGE) {
        contentWidget = _getRemoteImageContentWidget(message, imageClickCallback);
      }
    }

    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                contentWidget,
                Container(
                  padding: EdgeInsets.only(top: 3, left: 3),
                  child: _receiveTimeIndicator(message)
                )
              ]
            )
          )
        ]
      )
    );
  }
}

class _OtherMessageRow extends StatelessWidget {
  final Message message;
  final AppState appState;
  final ImageClickCallback imageClickCallback;

  _OtherMessageRow({
    this.message,
    this.appState,
    this.imageClickCallback
  });

  Widget build(BuildContext context) {
    Widget contentWidget;
    if (message.messageType == MessageType.TEXT) {
      contentWidget = _getTextContentWidget(message);
    } else if (message.messageType == MessageType.IMAGE) {
      contentWidget = _getRemoteImageContentWidget(message, imageClickCallback);
    }

    return Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: CachedNetworkImage(
                    imageUrl: message.from.avatar.thumb,
                    placeholder: (context, url) => CupertinoActivityIndicator(),
                    width: 50,
                    height: 50
                  )
                ),
                Positioned(
                  child: Container(
                    width: 24,
                    height: 12,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: locales().getFlagImage(message.from.region),
                        fit: BoxFit.cover
                      )
                    )
                  )
                )
              ]
            )
          ),
          Padding(padding: EdgeInsets.only(left: 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(locales().getNick(message.from.nick),
                  style: TextStyle(
                    fontSize: 13,
                    color: Styles.secondaryFontColor
                  ),
                ),
                contentWidget,
                _translatedTextIndicator(appState, message),
                Container(
                  padding: EdgeInsets.only(top: 3, left: 3),
                  child: _receiveTimeIndicator(message)
                )
              ]
            )
          )
        ],
      ),
    );
  }
}

Widget _translatedTextIndicator(AppState state, Message message) {
  if (message.messageType != MessageType.TEXT) return Center();
  if (state.member.language == message.from.language) return Center();
  Widget translated;
  if (message.translated == null) {
    translated = Container(
      margin: EdgeInsets.only(top: 3),
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
        strokeWidth: 1
      )
    );
  } else {
    translated = Expanded(
      child: Container(
        child: Text(message.translated,
          style: TextStyle(
            fontSize: 14,
            color: Styles.secondaryFontColor
          )
        )
      )  
    );
  }
  return Container(
    padding: EdgeInsets.only(top: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: EdgeInsets.only(left: 5)),
        Container(
          child: Text(locales().message.translateLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Styles.secondaryFontColor
            )
          )
        ),
        Padding(padding: EdgeInsets.only(left: 5)),
        translated
      ]
    )
  );
}

Widget _receiveTimeIndicator(Message msg) {
  if (msg.isSending == true) {
    return Container(
      width: 12,
      height: 12,
      margin: EdgeInsets.only(right: 5),
      child: CircularProgressIndicator(
        strokeWidth: 1,
      )
    );
  }
  return Text(locales().message.messageReceiveTime(msg.sentTime),
    style: TextStyle(
      fontSize: 12,
      color: Styles.secondaryFontColor
    )
  );
}

Widget _getLoadingImageContentWidget(Message message) =>
  Container(
    color: CupertinoColors.activeBlue,
    width: 120,
    height: 120,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(CupertinoColors.white)
        ),
        Positioned(
          child: Text("${message.attatchmentUploadProgress}%",
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.white
            )
          )
        )
      ]
    )
  );

Widget _getRemoteImageContentWidget(Message message, ImageClickCallback callback) =>
  CupertinoButton(
    padding: EdgeInsets.all(0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: CachedNetworkImage(
        imageUrl: message.getImageContent().thumbnailUrl,
        placeholder: (context, url) => CupertinoActivityIndicator(),
        width: 150,
        height: 150,
      )
    ),
    onPressed: () => callback(message.messageId)
  );

Widget _getTextContentWidget(Message message) =>
  ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: EdgeInsets.all(7),
      color: CupertinoColors.activeBlue,
      child: Text(message.getTextContent(),
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.white
        )
      )
    ),
  );