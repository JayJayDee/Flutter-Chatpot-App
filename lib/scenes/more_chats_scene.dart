import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:chatpot_app/apis/api_entities.dart';
import 'package:chatpot_app/factory.dart';

class RoomSearchCondition {
  String query;
  RoomQueryOrder order;

  RoomSearchCondition({
    String query,
    RoomQueryOrder order
  }) {
    this.query = query;
    this.order = order;
  }

  @override
  String toString() =>
    "[RoomSearchCondition] ORDER:$order QUERY:$query";
}

class MoreChatsScene extends StatefulWidget {

  final RoomSearchCondition condition;

  MoreChatsScene({
    @required this.condition
  });

  @override
  _MoreChatsSceneState createState() =>
    _MoreChatsSceneState(condition: condition);
}

class _MoreChatsSceneState extends State<MoreChatsScene> {

  RoomSearchCondition _condition;
  bool _loading;

  TextEditingController _queryEditController;

  _MoreChatsSceneState({
    @required RoomSearchCondition condition
  }) {
    _condition = condition;
    _loading = false;
    _queryEditController = TextEditingController();
  }

  @override
  initState() {
    super.initState();
  }

  Future<void> _refreshSearch() async {
    setState(() {
      _loading = true;
    });
  }

  Future<void> _onPickerSelected(RoomQueryOrder order) async {
    _condition.order = order;
    await _refreshSearch();
  }
  
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: _buildPicker(context, 
          callback: _onPickerSelected,
          selected: _condition.order
        )
      ),
      Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: _buildQueryInputField(context,
          controller: _queryEditController,
          textChangeCallback: (String query) => print(query)
        )
      )
    ];
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          previousPageTitle: locales().home.title,
          middle: Text(locales().morechat.title),
          transitionBetweenRoutes: true
        ),
        child: SafeArea(
          child: ListView(
            children: widgets
          )
        )
      );
  }
}

typedef QueryTextChangeCallback (String query);
typedef OrderSelectCallback (RoomQueryOrder order);
Widget _buildPicker(BuildContext context, {
  @required RoomQueryOrder selected,
  @required OrderSelectCallback callback
}) {
  List<RoomQueryOrder> items = [
    RoomQueryOrder.ATTENDEE_DESC,
    RoomQueryOrder.REGDATE_DESC
  ];
  return Center();
}

String _orderLabel(RoomQueryOrder order) =>
  order == RoomQueryOrder.ATTENDEE_DESC ? locales().morechat.orderPeopleDesc :
  order == RoomQueryOrder.REGDATE_DESC ? locales().morechat.orderRecentDesc : '';

Widget _buildQueryInputField(BuildContext context, {
  @required TextEditingController controller,
  @required QueryTextChangeCallback textChangeCallback
}) =>
  CupertinoTextField(
    controller: controller,
    prefix: const Icon(
      CupertinoIcons.search,
      color: CupertinoColors.lightBackgroundGray,
      size: 28.0,
    ),
    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
    clearButtonMode: OverlayVisibilityMode.editing,
    textCapitalization: TextCapitalization.words,
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(width: 0.0, color: CupertinoColors.inactiveGray)),
    ),
    placeholder: locales().morechat.queryEditPlaceholder
  );