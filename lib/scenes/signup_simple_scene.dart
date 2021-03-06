import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:chatpot_app/models/app_state.dart';
import 'package:chatpot_app/factory.dart';
import 'package:chatpot_app/styles.dart';
import 'package:chatpot_app/components/gender_selector.dart';
import 'package:chatpot_app/entities/member.dart';

class SimpleSignupScene extends StatefulWidget {

  @override
  State createState() => _SimpleSignupSceneState();
}

class _SimpleSignupSceneState extends State<SimpleSignupScene> {

  String _gender;

  Future<void> _onSimpleSignUpClicked(BuildContext context) async {
    Gender gender = parseGender(_gender);

    Locale locale = Localizations.localeOf(context);
    final model = ScopedModel.of<AppState>(context);
    await model.simpleSignup(
      gender: gender,
      region: locale.countryCode,
      language: locale.languageCode
    );
    Navigator.pop(context, true);
  }

  void _onGenderSelected(String gender) {
    setState(() {
      _gender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: styles().mainBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: styles().navigationBarBackground,
        previousPageTitle: 'Back',
        actionsForegroundColor: styles().link,
        middle: Text(locales().simpleSignup.title,
          style: TextStyle(
            color: styles().primaryFontColor
          )
        ),
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ListView(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child: Text(locales().simpleSignup.description,
                    style: TextStyle(
                      color: styles().primaryFontColor
                    )
                  )
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10, top: 25),
                  child: buildGenderSeletor(context,
                    gender: _gender,
                    genderSelectCallback: _onGenderSelected
                  )
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10, top: 25),
                  child: _buildSignupButton(context, () => 
                    _onSimpleSignUpClicked(context))
                )
              ],
            ),
            _buildProgress(context)
          ]
        )
      )
    );
  } 
}

Widget _buildSignupButton(BuildContext context, VoidCallback callback) {
  final model = ScopedModel.of<AppState>(context, rebuildOnChange: true);
  VoidCallback buttonCallback;
  if (model.loading == false) buttonCallback = callback;
  return CupertinoButton(
    color: CupertinoColors.activeBlue,
    child: Text(locales().simpleSignup.startButtonLabel), // TODO: locale
    onPressed: buttonCallback
  );
}

Widget _buildProgress(BuildContext context) {
  final model = ScopedModel.of<AppState>(context, rebuildOnChange: true);
  if (model.loading == true) {
    return Center(
      child: CupertinoActivityIndicator()
    );
  }
  return Container();
}