import 'dart:convert';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:meta/meta.dart';
import 'package:flutter/cupertino.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:chatpot_app/scenes/home_scene.dart';
import 'package:chatpot_app/scenes/chats_scene.dart';
import 'package:chatpot_app/scenes/settings_scene.dart';
import 'package:chatpot_app/scenes/tabbed_scene_interface.dart';
import 'package:chatpot_app/models/app_state.dart';
import 'package:chatpot_app/entities/message.dart';
import 'package:chatpot_app/factory.dart';

class ContainerScene extends StatefulWidget {
  @override
  _ContainerSceneState createState() => _ContainerSceneState();
}

class _WidgetWrapper {
  _WidgetWrapper({
    @required Widget widget,
    @required EventReceivable receivable
  }) {
    _widget = widget;
    _receivable = receivable;
  }
  Widget _widget;
  EventReceivable _receivable;

  Widget get widget => _widget;
  EventReceivable get receivable => _receivable;
}

class _ContainerSceneState extends State<ContainerScene> {
  Map<String, _WidgetWrapper> _widgetMap;
  Map<String, bool> _initMap;

  _ContainerSceneState() {
    _widgetMap = Map();
    _initMap = Map();
  }

  void _initFcm(BuildContext context) {
    firebaseMessaging().configure(
      onMessage: (Map<String, dynamic> message) {
        if (message.isEmpty) return;
        print('MESSAGE_ARRIVAL');

        Map<String, dynamic> source;
        if (Platform.isIOS) {
          source = message;
        } else if (Platform.isAndroid) {
          source = message['data'].cast<String, dynamic>();
        }

        if (source != null) {
          String payload = source['payload'];
          Map<String, dynamic> payloadMap = jsonDecode(payload);
          Message msg = Message.fromJson(payloadMap);
          print(msg);
        }
      },
      onResume: (Map<String, dynamic> message) {
        print('ON_RESUME');
        print(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        print('ON_LAUNCH');
        print(message);
      }
    );
  }

  _WidgetWrapper _inflate(BuildContext context, int index) {
    String key = index.toString();
    _WidgetWrapper cached = _widgetMap[key];
    if (cached != null) return cached;
      
    if (key == '0') {
      HomeScene scene = HomeScene(parentContext: context);
      cached = _WidgetWrapper(
        widget: scene,
        receivable: scene
      );
    } 
    
    else if (key == '1') {
      ChatsScene scene = ChatsScene(parentContext: context);
      cached = _WidgetWrapper(
        widget:  scene,
        receivable: scene
      );
    }

    else if (key == '2') {
      SettingsScene scene = SettingsScene(parentContext: context);
      cached = _WidgetWrapper(
        widget: scene,
        receivable: scene
      );
    }

    _widgetMap[key] = cached;
    return cached;
  }

  @override
  Widget build(BuildContext context) {
    _initFcm(context);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.tea),
            title: Text('Lounge'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.chatProcessing),
            title: Text('Chats'),
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.settings),
            title: Text('Settings'),
          )
        ],
        onTap: (int index) {
          var wrapper = _inflate(context, index);
          wrapper.receivable.onSelected(context);
        }
      ),
      tabBuilder: (context, index) {
        _WidgetWrapper wrapper = _inflate(context, index);
        var inited = _initMap[index.toString()];
        if (inited == null && index == 0) {
          _initMap[index.toString()] = true;
          Future.delayed(Duration(milliseconds: 200)).then((dynamic val) {
            var delayedWrapper = _widgetMap[index.toString()];
            if (delayedWrapper != null) delayedWrapper.receivable.onSelected(context);
          });
        }

        return CupertinoTabView(
          builder: (BuildContext context) => 
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                wrapper.widget,
                Positioned(
                  child: _buildProgressBar(context)
                )
              ],
            )
        );
      }
    );
  }
}

Widget _buildProgressBar(BuildContext context) {
  final model = ScopedModel.of<AppState>(context, rebuildOnChange: true);
  if (model.loading == true) return CupertinoActivityIndicator();
  return Center();
}