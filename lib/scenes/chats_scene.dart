import 'dart:async';
import 'dart:io' show Platform;
import 'package:chatpot_app/apis/api_entities.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:chatpot_app/styles.dart';
import 'package:chatpot_app/scenes/tabbed_scene_interface.dart';
import 'package:chatpot_app/models/app_state.dart';
import 'package:chatpot_app/entities/room.dart';
import 'package:chatpot_app/components/my_room_row.dart';
import 'package:chatpot_app/scenes/new_chat_scene.dart';
import 'package:chatpot_app/scenes/message_scene.dart';
import 'package:chatpot_app/factory.dart';
import 'package:chatpot_app/components/chat_type_choose_dialog.dart';
import 'package:chatpot_app/scenes/new_roulette_scene.dart';

@immutable
class ChatsScene extends StatelessWidget implements EventReceivable {

  final BuildContext parentContext;
  final TabActor actor;

  ChatsScene({
    @required this.parentContext,
    @required this.actor
  });

  void _showMessageScene(BuildContext context, String roomToken) async {
    final model = ScopedModel.of<AppState>(context);
    List<MyRoom> rooms = model.myRooms.where((r) => r.roomToken == roomToken).toList();

    if (rooms.length > 0) {
      await Navigator.of(parentContext).push(CupertinoPageRoute<bool>(
        builder: (BuildContext context) => MessageScene(
          room: rooms[0]
        )
      ));
    }
  }

  Future<void> _onNewChatClicked(BuildContext context) async {
    if (Platform.isIOS == true) {
      String roomToken = await Navigator.of(parentContext).push(CupertinoPageRoute<String>(
        builder: (BuildContext context) => NewChatScene()
      ));
      if (roomToken == null) return;
      _showMessageScene(context, roomToken);
      return;
    }

    var type = await showChatTypeChooseDialog(context);
    if (type == null) return;

    if (type == SelectedChatType.PUBLIC) {
      final model = ScopedModel.of<AppState>(context);
      String roomToken = await Navigator.of(parentContext).push(CupertinoPageRoute<String>(
        builder: (BuildContext context) => NewChatScene()
      ));
      if (roomToken == null) return;

      // if room was created, move to new room
      if (roomToken != null) {
        List<MyRoom> rooms = model.myRooms.where((elem) => elem.roomToken == roomToken).toList();
        if (rooms.length > 0) {
          MyRoom room = rooms[0];
          Navigator.of(parentContext).push(CupertinoPageRoute<bool>(
            builder: (BuildContext context) => MessageScene(
              room: room
            )
          ));
        }
      }
    }

    else if (type == SelectedChatType.ROULETTE) {
      await Navigator.of(parentContext).push(CupertinoPageRoute<String>(
        builder: (BuildContext context) => NewRouletteScene()
      ));
    }
  }

  Future<void> _onMyRoomSelected(BuildContext context, MyRoom room) async {
    Navigator.of(parentContext).push(CupertinoPageRoute<bool>(
      title: room.title,
      builder: (BuildContext context) => MessageScene(
        room: room
      )
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: styles().mainBackground,
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.only(start: 5, end: 5),
        backgroundColor: styles().navigationBarBackground,
        middle: Text(locales().chats.title,
          style: TextStyle(
            color: styles().primaryFontColor
          )
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Icon(MdiIcons.plus,
            size: 27,
            color: styles().link
          ),
          onPressed: () => _onNewChatClicked(context)
        )
      ),
      child: SafeArea(
        child: _buildMyRoomsView(context)
      )
    );
  }

  Future<void> onSelected(BuildContext context) async {
    final model = ScopedModel.of<AppState>(context);
    await model.fetchMyRooms();
    await model.translateMyRooms();
  }

  Widget _buildMyRoomsView(BuildContext context) {
    final model = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    List<MyRoom> myRooms = model.myRooms;
    if (myRooms.length == 0 &&
        model.loading == false &&
        model.roulettes.length == 0) {
      return _buildEmptyRoomsView(context);
    }

    Map<RoomType, List<MyRoom>> groupped = groupBy(myRooms, (r) => r.type);
    List<Widget> widgets = List();

    List<Widget> rouletteWidgets = List();

    List<RouletteStatus> waitings =
      model.roulettes.where((r) => r.matchStatus == RouletteMatchStatus.WAITING).toList();

    if (model.roulettes.length > 0) {
      rouletteWidgets.add(_buildRoomTypeHeaderLabel(RoomType.ROULETTE, model.roulettes.length));
    }

    if (waitings.length > 0) {
      waitings.forEach((w) {
        rouletteWidgets.add(MyRouletteWaitingRow(
          roulette: w,
          clickCallback: () {
            Navigator.of(parentContext).push(CupertinoPageRoute<String>(
              builder: (BuildContext context) => NewRouletteScene()
            ));
          }
        ));
      });
    }

    groupped.forEach((RoomType rtype, List<MyRoom> rooms) {
      if (rooms.length == 0) {
        return;
      }
      if (rtype == RoomType.ROULETTE) {
        rouletteWidgets.addAll(rooms.map((r) => MyRoomRow(
          myRoom: r,
          myRoomSelectCallback: (r) => _onMyRoomSelected(context, r)
        )).toList());
        return;
      }

      widgets.add(_buildRoomTypeHeaderLabel(rtype, rooms.length));

      rooms.sort((var a, var b) {
        int aTime = 
          a.lastMessage == null ? a.regDate.second :
            a.lastMessage.sentTime.second;
        int bTime =
          b.lastMessage == null ? b.regDate.second :
            b.lastMessage.sentTime.second;
        return aTime > bTime ? 1 :
          aTime < bTime ? -1 : 0;
      });

      widgets.addAll(rooms.map((r) => MyRoomRow(
        myRoom: r,
        myRoomSelectCallback: (r) => _onMyRoomSelected(context, r)
      )).toList());
    });

    List<Widget> allWidgets = [];
    allWidgets.addAll(rouletteWidgets);
    allWidgets.addAll(widgets);

    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: allWidgets.length,
      itemBuilder: (BuildContext context, int idx) => allWidgets[idx]
    );
  }

  Widget _buildRoomTypeHeaderLabel(RoomType type, int number) =>
    Container(
      decoration: BoxDecoration(
        color: styles().listRowHeaderBackground,
        border: Border(
          top: BorderSide(color: styles().listRowDivider, width: 0.3),
          bottom:BorderSide(color: styles().listRowDivider, width: 0.3)
        )
      ),
      padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      child: Row(
        children: [
          Text(locales().room.roomTypeLabel(type),
            style: TextStyle(
              fontSize: 14,
              color: styles().primaryFontColor
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              color: styles().secondaryFontColor
            ),
            padding: EdgeInsets.only(left: 5, top: 2, bottom: 2, right: 5),
            child: Text(number.toString(),
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.white
              )
            )
          )
        ]
      )
    );

  Widget _buildEmptyRoomsView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 90,
            child: Image(
              image: AssetImage('assets/chatpot-logo-only-800-grayscale.png')
            )
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          Text(locales().chats.emptyRooms,
            style: TextStyle(
              color: styles().secondaryFontColor,
              fontSize: 15
            ),
            textAlign: TextAlign.center,
          )
        ]
      )
    );
  }
}