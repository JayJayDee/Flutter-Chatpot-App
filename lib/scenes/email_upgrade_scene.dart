import 'dart:async';
import 'package:chatpot_app/apis/api_entities.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:chatpot_app/models/app_state.dart';
import 'package:chatpot_app/styles.dart';
import 'package:chatpot_app/factory.dart';

class EmailUpgradeScene extends StatefulWidget {
  @override
  State createState() => _EmailUpgradeSceneState();
}

class _EmailUpgradeSceneState extends State<EmailUpgradeScene> with WidgetsBindingObserver {

  bool _loading;
  String _email;
  ActivationStatus _status;

  _EmailUpgradeSceneState() {
    _loading = false;
  }

  Future<void> _loadAndRefreshStatus() async {
    final state = ScopedModel.of<AppState>(context);
    String memberToken = state.member.token;
    setState(() {
      _loading = true;
    });

    var activationStatus = 
      await activationApi().requestAcitvationStatus(
        memberToken: memberToken);

    if (this.mounted) {
      setState(() {
        this._email = activationStatus.email;
        this._status = activationStatus.status;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAndRefreshStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Future.delayed(Duration.zero).then((data) {
      if (state == AppLifecycleState.resumed) {
        _loadAndRefreshStatus();
      }
    });
  }

  Future<void> _onEmailInputed(BuildContext context, String email) async {
    final state = ScopedModel.of<AppState>(context);
    setState(() {
      this._loading = true;
    });
    await activationApi().requestEmailActivation(
      email: email,
      memberToken: state.member.token
    );
    _loadAndRefreshStatus();
  }

  Future<void> _onCodeInputed(String code) async {

  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Styles.mainBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(locales().emailUpgradeScene.title)
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView(
              children: 
                this._status == ActivationStatus.IDLE ? 
                  _buildEmailInputWidgets(
                    loading: _loading,
                    emailInputCallback: (email) => _onEmailInputed(context, email)) :
                this._status == ActivationStatus.SENT ?
                  _buildCodeInputWidgets(
                    email: _email,
                    codeInputCallback: (code) => _onCodeInputed(code)) :
                this._status == ActivationStatus.CONFIRMED ?
                  _buildCompletedWidgets() :
                []
            ),
            Positioned(
              child: _buildProgressBar(this._loading)
            )
          ]
        )
      )
    );
  }
}

typedef StringInputCallback (String content);

List<Widget> _buildEmailInputWidgets({
  @required bool loading,
  @required StringInputCallback emailInputCallback
}) {
  String inputedText = '';
  return [
    Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10),
      child: Text(locales().emailUpgradeScene.emailInput,
        style: TextStyle(
          color: Styles.primaryFontColor,
          fontSize: 16
        ),
      )
    ),
    Container(
      margin: EdgeInsets.only(left: 10, top: 15, right: 10),
      child: CupertinoTextField(
        prefix: Icon(CupertinoIcons.mail_solid,
          size: 28.0,
          color: CupertinoColors.inactiveGray),
        placeholder: locales().signupScene.emailPlaceHolder,
        onChanged: (String a) => inputedText = a,
        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
        keyboardType: TextInputType.emailAddress,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.0, color: CupertinoColors.inactiveGray))
        )
      )
    ),
    Container(
      margin: EdgeInsets.only(left: 10, top: 15, right: 10),
      child: CupertinoButton(
        child: Text(locales().emailUpgradeScene.emailButtonLabel),
        onPressed: loading == true ? null : 
          () => emailInputCallback(inputedText)
      )
    )
  ];
}

List<Widget> _buildCodeInputWidgets({
  @required String email,
  @required StringInputCallback codeInputCallback 
}) {

  return [
    Container(
      margin: EdgeInsets.only(left: 10, top: 10, right: 10),
      child: Text(locales().emailUpgradeScene.codeInput(email),
        style: TextStyle(
          color: Styles.primaryFontColor,
          fontSize: 16
        ),
      )
    ),
  ];
}

List<Widget> _buildCompletedWidgets() => [

];

Widget _buildProgressBar(bool loading) {
  if (loading == true) return CupertinoActivityIndicator();
  return Center();
}