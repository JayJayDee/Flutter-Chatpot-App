import 'package:meta/meta.dart';
import 'package:chatpot_app/entities/member.dart';

enum AttchedImageStatus {
  REMOTE_IMAGE, LOCAL_IMAGE
}

enum NotificationType {
  JOIN_ROOM, LEAVE_ROOM
}

enum SentPlatform {
  IOS, ANDROID, WEB
}

String sentPlatformExpression(SentPlatform platform) {
  if (platform == SentPlatform.ANDROID) return 'ANDROID';
  else if (platform == SentPlatform.IOS) return 'IOS';
  return '';
}

SentPlatform _parseSentPlatform(String expr) {
  if (expr == 'ANDROID') return SentPlatform.ANDROID;
  else if (expr == 'IOS') return SentPlatform.IOS;
  return SentPlatform.WEB;
}

class Message {
  String messageId;
  String translated;
  MessageType messageType;
  Member from;
  MessageTo to;
  DateTime sentTime;
  dynamic content;
  SentPlatform platform;

  bool _isSending;

  AttchedImageStatus _attachedImageStatus;
  int _imageUploadProgress;
  
  Message() {
    _isSending = false;
    _attachedImageStatus = null;
    _imageUploadProgress = 0;
    _attachedImageStatus = AttchedImageStatus.REMOTE_IMAGE;
  }

  factory Message.fromJson(Map<String, dynamic> map) {
    Message message = Message();
    message.messageId = map['message_id'];
    message.messageType = _getType(map['type']);

    if (map['from'] != null) {
      message.from = Member.fromJson(map['from']);
    }
    message.to = MessageTo.fromJson(map['to']);
    message.sentTime = DateTime.fromMillisecondsSinceEpoch(map['sent_time']);
    message.content = map['content'];

    if (map['platform'] != null) {
      message.platform = _parseSentPlatform(map['platform']);
    }
    return message;
  }

  bool get isSending => _isSending;
  int get attatchmentUploadProgress => _imageUploadProgress;
  void changeToSending() => _isSending = true;
  void changeToSent() => _isSending = false;

  AttchedImageStatus get attchedImageStatus => _attachedImageStatus;

  void changeToLocalImage(String imagePath) {
    _attachedImageStatus = AttchedImageStatus.LOCAL_IMAGE;
    Map<String, String> imageSrcMap = Map();
    imageSrcMap['image_url'] = imagePath;
    imageSrcMap['thumb_url'] = imagePath;
    this.content = imageSrcMap;
    _imageUploadProgress = 0;
  }

  void changeUploadProgress(int prog) => _imageUploadProgress = prog;

  void changeToRemoteImage({
    @required String imageUrl,
    @required String thumbUrl
  }) {
    _attachedImageStatus = AttchedImageStatus.REMOTE_IMAGE;
    Map<String, String> imageSrcMap = Map();
    imageSrcMap['image_url'] = imageUrl;
    imageSrcMap['thumb_url'] = thumbUrl;
    this.content = imageSrcMap;
  }

  String getTextContent() {
    if (messageType != MessageType.TEXT) return null;
    return content.toString();
  }

  ImageContent getImageContent() {
    if (messageType != MessageType.IMAGE) return null;
    if (content is ImageContent) return content;
    Map<String, dynamic> converted = Map.from(content);
    return ImageContent.fromJson(converted);
  }

  NotificationContent getNotificationContent() {
    if (messageType != MessageType.NOTIFICATION) return null;
    if (content is NotificationContent) return content;
    Map<String, dynamic> converted = Map.from(content);
    return NotificationContent.fromJson(converted);
  }

  @override
  toString() => "MESSAGE($messageId): $content";
}

enum MessageType {
  TEXT, IMAGE, NOTIFICATION
}
MessageType _getType(String expr) {
  if (expr == 'TEXT') return MessageType.TEXT;
  else if (expr == 'IMAGE') return MessageType.IMAGE;
  else if (expr == 'NOTIFICATION') return MessageType.NOTIFICATION;
  return null;
}

class MessageTo {
  MessageTarget type;
  String token;

  MessageTo();

  factory MessageTo.fromJson(Map<String, dynamic> map) {
    MessageTo to = MessageTo();
    to.token = map['token'];
    to.type = _getTarget(map['type']);
    return to;
  }
}
enum MessageTarget {
  ROOM
}
MessageTarget _getTarget(String expr) {
  if (expr == 'ROOM') return MessageTarget.ROOM;
  return null;
}

class ImageContent {
  String imageUrl;
  String thumbnailUrl;

  ImageContent({
    @required this.imageUrl,
    @required this.thumbnailUrl
  }); 

  factory ImageContent.fromJson(Map<String, dynamic> map) =>
    ImageContent(
      imageUrl: map['image_url'],
      thumbnailUrl: map['thumb_url']
    );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> resp = Map();
    resp['image_url'] = imageUrl;
    resp['thumb_url'] = thumbnailUrl;
    return resp;
  }
}

class NotificationContent {
  NotificationType notificationType;
  Member member;
  String roomToken;

  NotificationContent({
    @required this.notificationType,
    @required this.member,
    @required this.roomToken
  });

  factory NotificationContent.fromJson(Map<String, dynamic> map) =>
    NotificationContent(
      notificationType: _parseType(map['notification_type'].toString()),
      member: Member.fromJson(map['member']),
      roomToken: map['room_token']
    );

  static NotificationType _parseType(String typeExpr) {
    if (typeExpr == 'JOIN_ROOM') return NotificationType.JOIN_ROOM;
    else if (typeExpr == 'LEAVE_ROOM') return NotificationType.LEAVE_ROOM;
    return null;
  }

  @override
  String toString() {
    return "${notificationType.toString()} - $roomToken";
  }
}

class RoomMessages {
  int _offset;
  int _notViewed;
  List<Message> _messages;
  List<Message> _queuedMessages;
  bool moreMessage;
  Map<String, int> _existMap;
  List<String> _bannedTokens;

  RoomMessages() {
    _offset = 0;
    _notViewed = 0;
    _messages = List();
    _queuedMessages = List();
    moreMessage = true;
    _existMap = Map();
    _bannedTokens = List();
  }

  List<Message> get messages {
    List<Message> filtered = _messages.where((m) {
      if (m.from == null) return true;
        
      if (_bannedTokens.where((t) => 
            t == m.from.token).length == 0) {
        return true;
      }
      return false;
    }).toList();
    return filtered;
  }

  int get offset => _offset;
  int get notViewed => _notViewed;

  void updateBannedTokens(List<String> bannedTokens) {
    _bannedTokens = bannedTokens;
  }

  Message findMessage(messageId) {
    List<Message> found = 
      _messages.where((m) => m.messageId == messageId).toList();
    if (found.length == 0) return null;
    return found[0];
  }

  void clearOffset() {
    _offset = 0;
  }

  void clearMessages() {
    _existMap.clear();
    _messages.clear();
  }

  void clearNotViewed() {
    _notViewed = 0;
  }

  void increaseNotViewed() {
    _notViewed++;
  }

  void appendMesasges(List<Message> newMessages) {
    newMessages.forEach((m) {
      if (_existMap[m.messageId] != null) return;
      _messages.add(m);
      _existMap[m.messageId] = 1;
    });
    _offset += newMessages.length;
  }

  void appendQueuedMessage(Message msg) {
    _queuedMessages.add(msg);
  }

  void dumpQueuedMessagesToMessage() {
    _queuedMessages.forEach((m) {
      if (_existMap[m.messageId] == null) {
        _messages.insert(0, m);
        _existMap[m.messageId] = 1;
      }
    });
    _queuedMessages.clear();
  }

  void changeMessageId(String prevId, String nextId) {
    _existMap.remove(prevId);
    _existMap[nextId] = 1;
    _messages.forEach((m) {
      if (m.messageId == prevId) {
        m.messageId = nextId;
      }
    });
  }

  void appendSingleMessage(Message msg) {
    if (_existMap[msg.messageId] != null) {
      var existMsg = _messages.where((m) => m.messageId == msg.messageId);
      print("EXIST MSG WITH MESSAGEID: ${msg.messageId}");
      print("LENGTH = ${existMsg.length}");

      if (existMsg.length > 0) {
        var msg = existMsg.toList()[0];
        if (msg.isSending == true) {
          msg.changeToSent();
          return;
        }
      }
    }
    _messages.insert(0, msg);
    _existMap[msg.messageId] = 1;
  }
}