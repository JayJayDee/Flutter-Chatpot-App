import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:meta/meta.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:chatpot_app/entities/message.dart';
import 'package:chatpot_app/styles.dart';
import 'package:chatpot_app/factory.dart';
import 'package:chatpot_app/components/simple_alert_dialog.dart';

class PhotoDetailScene extends StatefulWidget {

  final BuildContext messagesSceneContext;
  final Message message;

  PhotoDetailScene({
    @required this.messagesSceneContext,
    @required this.message
  });

  @override
  _PhotoDetailSceneState createState() => _PhotoDetailSceneState(
    message: message,
  );
}

class _PhotoDetailSceneState extends State<PhotoDetailScene> {

  Message _message;
  bool _loading;
  bool _imageDownloading;

  _PhotoDetailSceneState({
    @required Message message
  }) {
    _message = message;
    _loading = false;
    _imageDownloading = false;
  }

  void _onImageDownloadClicked(BuildContext context, String imageUrl) async {
    setState(() => _loading = true);

    try {
      
      showToast(locales().photoDetail.downloadSuccess, 
        duration: Duration(milliseconds: 1000),
        position: ToastPosition(align: Alignment.bottomCenter)
      );
    } catch (err) {
      showSimpleAlert(context, locales().photoDetail.failedToDownload(err.toString()));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: styles().mainBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: styles().navigationBarBackground,
        previousPageTitle: locales().photoDetail.previousTitle,
        actionsForegroundColor: styles().link,
        middle: Text(locales().photoDetail.title,
          style: TextStyle(
            color: styles().primaryFontColor
          )
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text('Save',
            style: TextStyle(
              color: styles().link,
            )
          ),
          onPressed: () {},
        ),
        transitionBetweenRoutes: true
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              child: _buildImagePage(context, _message),
            ),
            Positioned(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 1.0],
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.8)
                        ]
                      )
                    ),
                    height: 140,
                    child: _overlayIndicator(_message)
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }

  Widget _overlayIndicator(Message selected) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 10),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 60,
                  height: 60,
                  child: CachedNetworkImage(
                    imageUrl: selected.from.avatar.thumb,
                  )
                )
              ),
              Positioned(
                child: Container(
                  width: 30,
                  height: 15,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: locales().getFlagImage(selected.from.region),
                      fit: BoxFit.cover
                    )
                  ),
                )
              )
            ]
          ),
          Padding(padding: EdgeInsets.only(left: 15)),
          Text(locales().getNick(selected.from.nick),
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold
            )
          )
        ]
      )
    );
  }
}

Widget _buildImagePage(BuildContext context, Message message) {
  return Container(
    color: CupertinoColors.black,
    alignment: Alignment.center,
    child: PhotoView(
      backgroundDecoration: BoxDecoration(
        color: CupertinoColors.black
      ),
      imageProvider: CachedNetworkImageProvider(
        message.getImageContent().imageUrl
      )
    )
  );
}