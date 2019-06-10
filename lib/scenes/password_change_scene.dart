import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/cupertino.dart';
import 'package:chatpot_app/factory.dart';
import 'package:chatpot_app/styles.dart';
import 'package:chatpot_app/components/simple_alert_dialog.dart';

class PasswordChangeScene extends StatefulWidget {

  @override
  State createState() => _PasswordChangeSceneState();
}

class _PasswordChangeSceneState extends State<PasswordChangeScene> {
  
  String _oldPassword = '';
  String _newPassword = '';
  String _newPasswordConfirm = '';

  Future<void> _onClickChangeButton(BuildContext context) async {
    if (_oldPassword.trim().length == 0) {
      await showSimpleAlert(context, 'old password required'); // TODO: locale
      return;
    }

    if (_newPassword.trim().length == 0) {
      await showSimpleAlert(context, 'new password required'); // TODO: locale
      return;
    }

    if (_newPassword.trim().compareTo(_newPasswordConfirm.trim()) != 0) {
      await showSimpleAlert(context, 'passwords does not matched'); // TODO: locale
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: locales().setting.title,
        middle: Text(locales().passwordChange.title),
        transitionBetweenRoutes: true
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: Text(locales().passwordChange.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Styles.primaryFontColor
                    )
                  )
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: _buildOldPasswordField(context,
                    callback: (String text) => setState(() => _oldPassword = text)
                  )
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: _buildNewPasswordField(context,
                    callback: (String text) => setState(() => _newPassword = text)
                  )
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: _buildNewPasswordConfirmField(context,
                    callback: (String text) => setState(() => _newPasswordConfirm = text)
                  )
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: CupertinoButton(
                    child: Text(locales().passwordChange.changeButtonLabel),
                    onPressed: () => _onClickChangeButton(context)
                  )
                )
              ]
            ),
            _buildProgress(context)
          ]
        )
      )
    );
  }
}

typedef TextChangedCallback (String inputed);

Widget _buildOldPasswordField(BuildContext context, {
  @required TextChangedCallback callback
}) {
  return CupertinoTextField(
    prefix: Icon(CupertinoIcons.padlock_solid,
      size: 28.0,
      color: CupertinoColors.inactiveGray),
    placeholder: locales().passwordChange.oldPasswordPlaceholder,
    onChanged: callback,
    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
    obscureText: true,
    keyboardType: TextInputType.text,
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(width: 0.0, color: CupertinoColors.inactiveGray))
    )
  );
}

Widget _buildNewPasswordField(BuildContext context, {
  @required TextChangedCallback callback
}) {
  return CupertinoTextField(
    prefix: Icon(CupertinoIcons.padlock_solid,
      size: 28.0,
      color: CupertinoColors.inactiveGray),
    placeholder: locales().passwordChange.newPasswordPlaceholder,
    onChanged: callback,
    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
    obscureText: true,
    keyboardType: TextInputType.text,
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(width: 0.0, color: CupertinoColors.inactiveGray))
    )
  );
}

Widget _buildNewPasswordConfirmField(BuildContext context, {
  @required TextChangedCallback callback
}) {
  return CupertinoTextField(
    prefix: Icon(CupertinoIcons.padlock_solid,
      size: 28.0,
      color: CupertinoColors.inactiveGray),
    placeholder: locales().passwordChange.newPasswordConfirmPlaceholder,
    onChanged: callback,
    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
    obscureText: true,
    keyboardType: TextInputType.text,
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(width: 0.0, color: CupertinoColors.inactiveGray))
    )
  );
}

Widget _buildProgress(BuildContext context) {
  return Container();
}