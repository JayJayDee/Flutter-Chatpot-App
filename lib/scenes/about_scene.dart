import 'package:chatpot_app/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:chatpot_app/factory.dart';
import 'package:chatpot_app/components/simple_alert_dialog.dart';
import 'package:flutter/services.dart';

class AboutScene extends StatelessWidget {

  void _onBitcoinClicked(BuildContext context) async {
    String bitAddr = '1LNLrgkDPL5KgSxVoW4CLw5ezWWr2aqxAP';
    await Clipboard.setData(ClipboardData(text: bitAddr));

    await showSimpleAlert(context, locales().aboutScene.bitcoinAddrCopyCompleted,
      title: locales().successTitle
    );
  }

  void _onEthereumClicked(BuildContext context) async {
    String etherAddr = '0x58f196b91a77a8db0B30a71Fd7273d1De2DCB627';
    await Clipboard.setData(ClipboardData(text: etherAddr));

    await showSimpleAlert(context, locales().aboutScene.ethereumAddrCopyCompleted,
      title: locales().successTitle
    );
  }

  @override 
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: locales().setting.title,
        middle: Text(locales().aboutScene.title)
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(left: 15, top: 30, right: 15),
              child: Image(
                image: AssetImage('assets/chatpot-logo-with-typo-medium.png')
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 30),
              child: Text(locales().aboutScene.greetings1,
                style: TextStyle(
                  fontSize: 16,
                  color: Styles.primaryFontColor
                )
              )
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: CupertinoButton(
                child: Text(locales().aboutScene.bitcoinDonateBtnLabel,
                  style: TextStyle(
                    fontSize: 16
                  )
                ),
                onPressed: () => _onBitcoinClicked(context)
              )
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: CupertinoButton(
                child: Text(locales().aboutScene.ethereumDonateBtnLabel,
                  style: TextStyle(
                    fontSize: 16
                  )
                ),
                onPressed: () => _onEthereumClicked(context)
              )
            ),
            Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 15),
              child: Text('''Developed by JayJayDee.
jindongp@gmail.com''',
                style: TextStyle(
                  fontSize: 16,
                  color: Styles.primaryFontColor
                )
              )
            )
          ]
        )
      )
    );
  }
}