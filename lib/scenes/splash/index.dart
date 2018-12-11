import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:chatpot_app/models/member-model.dart';

class SplashScene extends StatefulWidget {
  @override 
  _SplashState createState() => _SplashState(); 
}

class _SplashState extends State<SplashScene> {
  MemberModel _memberModel;

  @override 
  Widget build(BuildContext context) {
    print('build()');
    return ScopedModel<MemberModel>(
      model: _memberModel,
      child: Scaffold(
        body: Center(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: FlutterLogo(
                    size: 60.0
                  ),
                  margin: EdgeInsets.all(15.0)
                ),
                Text(
                  'Chatpot',
                  style: TextStyle(
                    fontSize: 25.0
                  )
                ),
                _SplashProgress(),
                _SplashBottomTools()
              ],
            )
          )
        )
      )
    );
  }

  @override
  void initState() {
    super.initState();
    print('initState()');
    _memberModel = MemberModel();

    _memberModel.initialize()
    .then((status) {
      if (status == AuthStatus.AuthCompleted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }
}

class _SplashProgress extends StatelessWidget {
  @override
  Widget build (BuildContext conext) {
    return ScopedModelDescendant<MemberModel>(
      builder: (context, child, model) {
        return Opacity(
          opacity: model.loading == true ? 1.0 : 0.0,
          child: Container(
            margin: EdgeInsets.all(25.0),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class _SplashBottomTools extends StatelessWidget {
  @override 
  Widget build (BuildContext context) {
    return ScopedModelDescendant<MemberModel>(
      builder: (context, child, model) {
        return Opacity(
          opacity: model.loginToolsShow == true ? 1.0 : 0.0,
          child: Container(
            margin: EdgeInsets.only(top: 30),
            child: Column(
              children: [
                RaisedButton(
                  child: Text('Start Chatpot without Sign-up'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  }
                ),
                RaisedButton(
                  child: Text('Sign in'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  }
                )
              ],
            )
          )
        );
      }
    );
  }
}