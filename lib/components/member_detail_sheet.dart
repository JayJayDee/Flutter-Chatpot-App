import 'dart:async';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:chatpot_app/apis/api_errors.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:meta/meta.dart';
import 'package:flutter/widgets.dart';
import 'package:chatpot_app/entities/member.dart';
import 'package:chatpot_app/factory.dart';
import 'package:chatpot_app/styles.dart';
import 'package:chatpot_app/components/simple_alert_dialog.dart';

const popupMenuFontStyle = TextStyle(
  fontSize: 16.0
);

typedef MemberTokenCallback (String token);

Future<void> showMemberDetailSheet(BuildContext context, {
  @required String memberToken,
  @required MemberTokenCallback blockCallback,
  @required MemberTokenCallback reportCallback
}) async {
  await showCupertinoModalPopup<bool>(
    context: context,
    builder: (BuildContext context) =>
      CupertinoActionSheet(
        message: _MemberDetailSheet(memberToken: memberToken),
        actions: [
          CupertinoActionSheetAction(
            child: Text(locales().memberDetailSheet.menuBlockUser,
              style: popupMenuFontStyle
            ),
            onPressed: () {
              Navigator.of(context).pop();
              blockCallback(memberToken);
            }
          ),
          CupertinoActionSheetAction(
            child: Text(locales().memberDetailSheet.menuReportUser,
              style: popupMenuFontStyle
            ),
            onPressed: () {
              Navigator.of(context).pop();
              reportCallback(memberToken);
            }
          )
        ]
      )
  );
}

class _MemberDetailSheet extends StatefulWidget {

  final String memberToken;

  _MemberDetailSheet({
    this.memberToken
  });

  @override
  State createState() =>
    _MemberDetailSheetState(memberToken: this.memberToken);
}

class _MemberDetailSheetState extends State<_MemberDetailSheet> {

  bool _loading;
  String _memberToken;
  MemberPublic _member;

  _MemberDetailSheetState({
    @required String memberToken
  }) {
    _memberToken = memberToken;
    _loading = false;
  }

  Future<void> _loadMemberInfo(String token) async {
    setState(() {
      _loading = true;
    });

    try {
      MemberPublic fetched = await memberApi().requestMemberPublic(memberToken: token);
      if (this.mounted == true) {
        setState(() {
          _member = fetched;
          _loading = false;
        });
      }
    } catch (err) {
      if (this.mounted == true) {
        setState(() {
          _loading = false;
        });
      }
      if (err is ApiFailureError) {
        await showSimpleAlert(context, locales().error.messageFromErrorCode(err.code));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    this._loadMemberInfo(_memberToken);
  }
  
  @override
  Widget build(BuildContext context) {
    if (this._loading == true) {
      return Center(
        child: CupertinoActivityIndicator()
      );
    }
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: _buildProfilePicture(_member)
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: _buildAdditionalInfoField(_member)
          )
        ]
      )
    );
  }
}

Widget _buildProfilePicture(MemberPublic member) =>
  Container(
    width: 100,
    height: 100,
    child: Stack(
      alignment: Alignment.bottomRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CachedNetworkImage(
            imageUrl: member.avatar.thumb,
            placeholder: (context, url) => CupertinoActivityIndicator(),
          )
        ),
        Container(
          width: 40,
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: styles().primaryFontColor),
            image: DecorationImage(
              image: locales().getFlagImage(member.region),
              fit: BoxFit.cover
            )
          )
        )
      ]
    )
  );

Widget _buildAdditionalInfoField(MemberPublic member) =>
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        child: Text(locales().getNick(member.nick),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: styles().popupPrimaryFontColor,
            fontSize: 17
          ),
        ),
      ),
      Container(
        margin: EdgeInsets.only(left: 5),
        child: Text(member.regionName,
          style: TextStyle(
            color: styles().popupSecondaryFontColor,
            fontSize: 15,
            fontWeight: FontWeight.normal
          )
        )
      ),
      member.gender == Gender.M || member.gender == Gender.F ?
        Container(
          margin: EdgeInsets.only(left: 5, top: 10),
          child: _genderIcon(member.gender)
        ) :
        Container()
    ]
  );

Icon _genderIcon(Gender g) =>
  g == Gender.M ? 
    Icon(MdiIcons.humanMale,
      color: styles().secondaryFontColor,
    ) 
  :
  g == Gender.F ?
    Icon(MdiIcons.humanFemale,
      color: styles().secondaryFontColor
    ) 
  : null;