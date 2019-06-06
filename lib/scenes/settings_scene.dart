import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:chatpot_app/styles.dart';
import 'package:chatpot_app/components/profile_card.dart';
import 'package:chatpot_app/components/not_login_card.dart';
import 'package:chatpot_app/models/app_state.dart';
import 'package:chatpot_app/entities/member.dart';
import 'package:chatpot_app/scenes/login_scene.dart';
import 'package:chatpot_app/scenes/tabbed_scene_interface.dart';
import 'package:chatpot_app/factory.dart';
import 'package:chatpot_app/scenes/email_upgrade_scene.dart';

@immutable
class SettingsScene extends StatelessWidget implements EventReceivable {

  final BuildContext parentContext;
  final TabActor actor;

  SettingsScene({
    @required this.parentContext,
    @required this.actor
  });
  
  void _onEditProfileClicked() async {

  }

  void _onSignoutClicked(BuildContext context) async {
    final model = ScopedModel.of<AppState>(context);
    bool isSimple = model.member.authType == AuthType.SIMPLE;
    var resp = await _showSignoutWarningDialog(context, isSimple);

    if (resp == 'SIGNOUT') {
      await model.signout();
      Navigator.of(parentContext).pushReplacement(CupertinoPageRoute<bool>(
        builder: (BuildContext context) => LoginScene()
      ));
    }
  }

  void _onSigninClicked(BuildContext context) async {
    await Navigator.of(context).push(CupertinoPageRoute<bool>(
      title: 'Sign in',
      builder: (BuildContext context) => LoginScene()
    ));
  }

  void _onAboutClicked() async {

  }

  void _onDonationClicked() async {

  }

  void _onEmailAccountClicked() async {
    print('EMAIL_ACCOUNT');
    await Navigator.of(parentContext).push(CupertinoPageRoute<bool>(
      builder: (BuildContext context) => EmailUpgradeScene()
    ));
  }

  @override
  Future<void> onSelected(BuildContext context) async {
    print('SETTINGS_SCENE');
  }

  @override
  Widget build(BuildContext context) {
    final model = ScopedModel.of<AppState>(context, rebuildOnChange: true);
    List<Widget> elems;

    if (model.member == null) {
      elems = <Widget>[
        buildNotLoginCard(context, loginSelectCallback: () => _onSigninClicked(context)),
        _buildMenuItem(locales().setting.signin, () => _onSigninClicked(context)),
      ];
    } else {
      elems = <Widget> [
        buildProfileCard(context, editButton: true, editCallback: _onEditProfileClicked),
        _buildMenuItem(locales().setting.signout, () => _onSignoutClicked(context)),
      ];
    }

    if (model.member != null && model.member.authType == AuthType.SIMPLE) {
      elems.add(_buildMenuItem(locales().setting.linkMail, () => _onEmailAccountClicked() ));
    }

    elems.add(_buildMenuItem(locales().setting.about, _onAboutClicked));
    elems.add(_buildMenuItem(locales().setting.donation, _onDonationClicked));

    return CupertinoPageScaffold(
      backgroundColor: Styles.mainBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(locales().setting.title)
      ),
      child: SafeArea(
        child: ListView(
          children: elems
        ),
      )
    );
  }
}

Widget _buildMenuItem(String title, VoidCallback pressedCallback) {
  return Container(
    decoration: BoxDecoration(
      color: Color(0xffffffff),
      border: Border(
        top: BorderSide(color: Color(0xFFBCBBC1), width: 0.3),
        bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.3)
      ),
    ),
    child: CupertinoButton(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title,
          style: TextStyle(
            fontSize: 16
          )
        ),
      ),
      onPressed: pressedCallback
    ),
  );
}

Future<dynamic> _showSignoutWarningDialog(BuildContext context, bool isSimple) {
  String content = '';
  if (isSimple == true) {
    content = locales().setting.simpleSignoutWarning;
  } else {
    content = locales().setting.signoutWarning;
  }
  return showCupertinoDialog<String>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(locales().setting.signout),
      content: Text(content),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text(locales().setting.signout),
          onPressed: () => Navigator.pop(context, 'SIGNOUT')
        ),
        CupertinoDialogAction(
          child: Text(locales().setting.cancel),
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          isDestructiveAction: true,
        )
      ]
    )
  );
}