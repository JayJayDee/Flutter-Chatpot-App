import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:chatpot_app/scenes/home_scene.dart';
import 'package:chatpot_app/scenes/chats_scene.dart';
import 'package:chatpot_app/scenes/settings_scene.dart';
import 'package:chatpot_app/scenes/tabbed_scene_interface.dart';
import 'package:chatpot_app/models/app_state.dart';

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

  _WidgetWrapper _inflate(BuildContext context, int index) {
    String key = index.toString();
    _WidgetWrapper cached = _widgetMap[key];
    if (cached != null) return cached;
      
    if (key == '0') {
      HomeScene scene = HomeScene();
      cached = _WidgetWrapper(
        widget: scene,
        receivable: scene
      );
    } 
    
    else if (key == '1') {
      ChatsScene scene = ChatsScene();
      cached = _WidgetWrapper(
        widget:  scene,
        receivable: scene
      );
    }

    else if (key == '2') {
      SettingsScene scene = SettingsScene();
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
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.mail),
            title: Text('Chats'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
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