import 'dart:async';
import 'dart:io';
import 'dart:io' show Platform;
import 'package:meta/meta.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:chatpot_app/entities/room.dart';
import 'package:chatpot_app/models/app_state.dart';
import 'package:chatpot_app/entities/message.dart';
import 'package:chatpot_app/components/message_row.dart';
import 'package:chatpot_app/styles.dart';
import 'package:chatpot_app/factory.dart';
import 'package:chatpot_app/scenes/photo_detail_scene.dart';
import 'package:chatpot_app/scenes/report_scene.dart';
import 'package:chatpot_app/scenes/image_send_confirm_scene.dart';
import 'package:chatpot_app/components/simple_alert_dialog.dart';
import 'package:chatpot_app/components/member_detail_sheet.dart';
import 'package:chatpot_app/storage/block_accessor.dart';

typedef ImageClickCallback (String messageId);
typedef ProfileClickCallback (String memberToken);
typedef UrlMoveCallback (String url);

@immutable
class MessageScene extends StatefulWidget {

  MessageScene();

  @override
  _MessageSceneState createState() => _MessageSceneState();
}

class _MessageSceneState extends State<MessageScene> with WidgetsBindingObserver {
  bool _inited = false;
  AppState _model;
  String _inputedMessage;
  TextEditingController _messageInputFieldCtrl = TextEditingController();
  ScrollController _scrollController = ScrollController();

  // String _generateTemporaryMessageId() =>
  //   "${DateTime.now().millisecondsSinceEpoch}";

  SentPlatform _getPlatform() {
    if (Platform.isAndroid) return SentPlatform.ANDROID;
    else if (Platform.isIOS) return SentPlatform.IOS;
    return null;
  }

  Future<void> _onImageSentClicked(BuildContext context) async {
    final state = ScopedModel.of<AppState>(context);

    SelectedImage image = await Navigator.of(context).push(CupertinoPageRoute<SelectedImage>(
      title: 'Photo',
      builder: (BuildContext context) => 
        ImageSendConfirmScene(
          roomTitle: state.currentRoom.title
        )
    ));

    if (image == null) return;

    ImageContent content = ImageContent(
      imageUrl: image.image,
      thumbnailUrl: image.thumbnail
    );

    await state.publishMessage(
      content: content,
      type: MessageType.IMAGE,
      platform: _getPlatform()
    );
  }

  Future<void> _onMessageSend(BuildContext context) async {
    if (_inputedMessage == null || _inputedMessage.trim().length == 0) {
      await showSimpleAlert(context, locales().msgscene.messageEmpty);
      return;
    }

    final model = ScopedModel.of<AppState>(context);
    model.publishMessage(
      content: _inputedMessage,
      type: MessageType.TEXT,
      platform: _getPlatform()
    );
    _messageInputFieldCtrl.clear();
    _inputedMessage = '';
  }

  Future<void> _onSceneShown(BuildContext context) async {
    final model = ScopedModel.of<AppState>(context);
    _model = model;
    MyRoom room = model.currentRoom;
    room.messages.clearNotViewed();
    await model.fetchMoreMessages(roomToken: room.roomToken);
    await model.translateMessages();
  }

  Future<void> _onRoomLeaveClicked(BuildContext context) async {
    final model = ScopedModel.of<AppState>(context);
    bool isLeave = await _showLeaveDialog(context);
    if (isLeave == true) {
      await model.leaveFromRoom(model.currentRoom.roomToken);
      Navigator.of(context).pop();
    }
  }

  Future<void> _onImageClicked(BuildContext context, String messageId) async {
    final model = ScopedModel.of<AppState>(context);
    List<Message> found = model.currentRoom.messages.messages.where((m) =>
      m.messageId == messageId).toList();

    await Navigator.of(context).push(CupertinoPageRoute<String>(
      builder: (BuildContext context) => 
        PhotoDetailScene(
          messagesSceneContext: context,
          message: found[0]
        )
    ));
  }

  Future<void> _onMemberBlockSelected(BuildContext context, String targetMember) async {
    var result = await _showBlockConfirmDialog(context);

    if (result == true) {
      final state = ScopedModel.of<AppState>(context);
      try {
        if (state.currentRoom != null) {
          await state.blockMember(
            roomToken: state.currentRoom.roomToken,
            targetMemberToken: targetMember,
          );
          await showSimpleAlert(context, locales().msgscene.blockSuccess,
            title: locales().successTitle
          );
          state.updateBanList();
        }
      } catch (err) {
        if (err is AlreadyBlockedMemberError) {
          showSimpleAlert(context, locales().msgscene.alreadyBlockedMember);
        } else {
          throw err;
        }
      }
    }
  }

  Future<void> _onMemberReportSelected(BuildContext context, String targetMember) async {
    final state = ScopedModel.of<AppState>(context);
    await Navigator.of(context).push(CupertinoPageRoute<void>(
      builder: (BuildContext context) => 
        ReportScene(
          targetToken: targetMember,
          roomToken: state.currentRoom.roomToken
        )
    ));
  }

  Future<void> _onProfileClicked(BuildContext context, String memberToken) async {
    await showMemberDetailSheet(context, 
      memberToken: memberToken,
      blockCallback: (String token) => _onMemberBlockSelected(context, token),
      reportCallback: (String token) => _onMemberReportSelected(context, token)
    );
  }

  void _onScrollEventArrival() async {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      final state = ScopedModel.of<AppState>(context);
      await state.fetchMoreMessages(roomToken: state.currentRoom.roomToken);
      await state.translateMessages();
    }
  }

  void _onTextClicked(BuildContext context, String text) async {
    await _showTextSelectionSheet(context,
      text: text,
      copyCallback: () => _onCopySelected(context, text),
      urlMoveCallback: (String url) => _onUrlMoveSelected(context, url)
    );
  }

  void _onCopySelected(BuildContext context, String text) async {
    await Clipboard.setData(new ClipboardData(text: text));
    showToast(locales().msgscene.copied, 
      duration: Duration(milliseconds: 1000),
      position: ToastPosition(align: Alignment.bottomCenter)
    );
  }

  void _onUrlMoveSelected(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showToast(locales().msgscene.wrongUrl, 
        duration: Duration(milliseconds: 1000),
        position: ToastPosition(align: Alignment.bottomCenter)
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScrollEventArrival);
  }

  @override
  void dispose() {
    _inited = false;
    _model.outFromRoom();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScrollEventArrival);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    var func = () async {
      if (state == AppLifecycleState.resumed) {
        if (_model.currentRoom != null) {
          _model.currentRoom.messages.clearNotViewed();
          await _model.fetchMessagesWhenResume(roomToken: _model.currentRoom.roomToken);
          await _model.translateMessages();
        }
      }
    };
    func();
  }

  @override
  Widget build(BuildContext context) {
    if (_inited == false) {
      _inited = true;
      _onSceneShown(context);
    }
    final model = ScopedModel.of<AppState>(context);
    MyRoom room = model.currentRoom;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: locales().chats.title,
        middle: Text(room.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ), 
        trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text(locales().msgscene.leave),
          onPressed: () => _onRoomLeaveClicked(context)
        ),
        transitionBetweenRoutes: true
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Column(
              children: [
                Expanded(
                  child: _buildListView(context,
                    controller: _scrollController,
                    imageClickCallback: (String messageId) =>
                      _onImageClicked(context, messageId),
                    profileClickCallback: (String memberToken) =>
                      _onProfileClicked(context, memberToken),
                    textLongPressCallback: (String text) =>
                      _onTextClicked(context, text)
                  )
                ),
                _buildEditText(context, 
                  controller: _messageInputFieldCtrl,
                  valueChanged: (String value) => setState(() => _inputedMessage = value),
                  imageSelected: () => _onImageSentClicked(context),
                  sendClicked: () => _onMessageSend(context)
                )
              ]
            ),
            Positioned(
              child: _buildProgressBar(context)
            )
          ],
        )
      )
    );
  }
}

Widget _buildListView(BuildContext context, {
  @required ScrollController controller,
  @required ImageClickCallback imageClickCallback,
  @required ProfileClickCallback profileClickCallback,
  @required TextClickCallback textLongPressCallback
}) {
  final model = ScopedModel.of<AppState>(context, rebuildOnChange: true);
  return Scrollbar(
    child: ListView.builder(
      scrollDirection: Axis.vertical,
      reverse: true,
      physics: AlwaysScrollableScrollPhysics(),
      controller: controller,
      itemCount: model.currentRoom.messages.messages.length,
      itemBuilder: (BuildContext context, int idx) {
        Message msg = model.currentRoom.messages.messages[idx];
        return MessageRow(
          message: msg,
          state: model,
          imageClickCallback: imageClickCallback,
          profileClickCallback: profileClickCallback,
          textClickCallback: textLongPressCallback
        );
      }
    )
  );
}

Widget _buildEditText(BuildContext context, {
  @required TextEditingController controller,
  @required ValueChanged<String> valueChanged,
  @required VoidCallback imageSelected,
  @required VoidCallback sendClicked
}) {
  final state = ScopedModel.of<AppState>(context, rebuildOnChange: true);
  return Container(
    height: 50,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CupertinoButton(
          padding: EdgeInsets.all(5),
          child: Icon(Icons.photo,
            size: 27
          ),
          onPressed: imageSelected
        ),
        Expanded(
          child: CupertinoTextField(
            controller: controller,
            keyboardType: TextInputType.text,
            padding: EdgeInsets.all(8),
            style: TextStyle(
              fontSize: 17,
              color: Styles.primaryFontColor
            ),
            onChanged: valueChanged,
            decoration: BoxDecoration(
              border: Border.all(
                color: Styles.thirdFontColor,
                width: 1.0
              ),
              borderRadius: BorderRadius.circular(10.0)
            )
          )
        ),
        state.loading == true ?
          Container(
            margin: EdgeInsets.all(8),
            width: 27,
            height: 27,
            child: CircularProgressIndicator(
              strokeWidth: 2.0
            ),
          ) :
          CupertinoButton(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.send,
              size: 27,
            ),
            onPressed: sendClicked    
          )
      ],
    ),
  );   
}

Widget _buildProgressBar(BuildContext context) {
  final model = ScopedModel.of<AppState>(context, rebuildOnChange: true);
  if (model.loading == false) return Center();
  return CupertinoActivityIndicator();
}

Future<bool> _showLeaveDialog(BuildContext context) async =>
  showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(locales().msgscene.leaveDialogTitle),
      content: Text(locales().msgscene.leaveDialogText),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(locales().msgscene.leave),
          onPressed: () => Navigator.pop(context, true)
        ),
        CupertinoDialogAction(
          child: Text(locales().msgscene.cancel),
          onPressed: () => Navigator.pop(context, false),
          isDestructiveAction: true
        )
      ],
    )
  );

Future<bool> _showBlockConfirmDialog(BuildContext context) async =>
  showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(locales().msgscene.blockTitle),
      content: Text(locales().msgscene.blockConfirm),
      actions: [
        CupertinoDialogAction(
          child: Text(locales().msgscene.doBlockButtonLabel),
          onPressed: () => Navigator.pop(context, true)
        ),
        CupertinoDialogAction(
          child: Text(locales().msgscene.cancelButtonLabel),
          onPressed: () => Navigator.pop(context, false),
          isDestructiveAction: true
        )
      ]
    )
  );

Future<void> _showTextSelectionSheet(BuildContext context, {
  @required String text,
  @required VoidCallback copyCallback,
  @required UrlMoveCallback urlMoveCallback,
}) async {
  List<Widget> actions = List();
  actions.add(CupertinoActionSheetAction(
    child: Text(locales().msgscene.selectedTextMenuCopy,
      style: TextStyle(
        fontSize: 16
      )
    ),
    onPressed: () {
      Navigator.of(context).pop();
      copyCallback();
    }
  ));

  List<String> urls = _getUrlsFromText(text);
  actions.addAll(urls.map((String url) =>
    CupertinoActionSheetAction(
      child: Text(url,
        style: TextStyle(
          fontSize: 16
        )
      ),
      onPressed: () {
        Navigator.of(context).pop();
        urlMoveCallback(url);
      }
    )
  ).toList());
  
  return await showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) =>
      CupertinoActionSheet(
        message: Column(
          children: [
            Text(locales().msgscene.selectedTextTitle,
              style: TextStyle(
                fontSize: 17,
                color: Styles.primaryFontColor
              )
            ),
            Padding(padding: EdgeInsets.only(top: 5)),
            Text(text,
              style: TextStyle(
                fontSize: 15,
                color: Styles.secondaryFontColor,
                fontWeight: FontWeight.normal
              )
            )
          ]
        ),
        actions: actions
      )
  );
}

List<String> _getUrlsFromText(String text) {
  final RegExp exp = RegExp(r"(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+");
  List<Match> matches = exp.allMatches(text).toList();
  List<String> urls = List();
  matches.forEach((m) => urls.add(m.group(0)));
  return urls;
}