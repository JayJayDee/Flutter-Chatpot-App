import 'package:meta/meta.dart';
import 'package:chatpot_app/entities/member.dart';
import 'package:chatpot_app/entities/room.dart';
import 'package:chatpot_app/entities/message.dart';

class TranslateParam {
  String key;
  String message;
  String from;
  
  TranslateParam({
    @required String key,
    @required String message,
    @required String from
  }) {
    this.key = key;
    this.message = message;
    this.from = from;
  }

  Map<String, String> toMap() {
    Map<String, String> respMap = Map();
    respMap['key'] = key;
    respMap['message'] = message;
    respMap['from'] = from;
    return respMap;
  }

  @override
  String toString() => "TRNSLATE_PARAM $key:$message";
}

class TranslateResp {
  String key;
  String translated;
  String hash;

  TranslateResp();

  factory TranslateResp.fromJson(Map<String, dynamic> map) {
    var res = TranslateResp();
    res.key = map['key'];
    res.translated = map['translated'];
    res.hash = map['hash'];
    return res;
  }

  @override
  toString() => "TRANSLATE_API_RESP: $key = $translated";
}

class SimpleJoinApiResp {
  Nick nick;
  String token;
  String passphrase;

  SimpleJoinApiResp();

  factory SimpleJoinApiResp.fromJson(Map<String, dynamic> map) {
    var res = SimpleJoinApiResp();
    res.nick = Nick.fromJson(map['nick']);
    res.token = map['token'];
    res.passphrase = map['passphrase'];
    return res;
  }

  @override
  toString() => "SIMPLEJOIN_API_RESP: $nick, $token";
}

class EmailJoinApiResp {
  Nick nick;
  String token;
  Avatar avatar;

  EmailJoinApiResp();

  factory EmailJoinApiResp.fromJson(Map<String, dynamic> map) {
    var res = EmailJoinApiResp();
    res.nick = Nick.fromJson(map['nick']);
    res.token = map['token'];
    res.avatar = Avatar.fromJson(map['avatar']);
    return res;
  }
}

class AuthApiResp {
  String sessionKey;
  String memberToken;

  AuthApiResp();

  factory AuthApiResp.fromJson(Map<String, dynamic> map) {
    var res = AuthApiResp();
    res.sessionKey = map['session_key'];
    res.memberToken = map['member_token'];
    return res;
  }

  @override
  toString() => "AUTH_API_RESP: $sessionKey";
}

class EmailAuthApiResp {
  String sessionKey;
  String memberToken;
  String passphrase;
  bool activated;

  EmailAuthApiResp();

  factory EmailAuthApiResp.fromJson(Map<String, dynamic> map) {
    var res = EmailAuthApiResp();
    res.sessionKey = map['session_key'];
    res.memberToken = map['member_token'];
    res.passphrase = map['passphrase'];
    res.activated = map['activated'];
    return res;
  }

  @override
  toString() => 
    "EMAIL_AUTH_API_RESP: SESSKEY[$sessionKey] MTOKEN[$memberToken] PASSPHRASE[$passphrase] ACTIVATED[$activated]";
}

enum RoomQueryOrder {
  REGDATE_DESC, ATTENDEE_DESC
}

class RoomListApiResp {
  int all;
  int size;
  List<Room> list;
  RoomListApiResp();
  
  factory RoomListApiResp.fromJson(Map<String, dynamic> map) {
    RoomListApiResp resp = RoomListApiResp();
    resp.all = map['all'];
    resp.size = map['size'];
    resp.list = [];

    List<dynamic> list = map['list'];
    List<Room> rooms = list.map((elem) => Room.fromJson(elem)).toList();
    resp.list = rooms;
    return resp;
  }

  @override
  toString() => "ROOM_API_RESP: $size $all";
}

class MessagesApiResp {
  List<Message> messages;
  int all;
  int offset;
  int size;

  MessagesApiResp();

  factory MessagesApiResp.fromJson(Map<String, dynamic> map) {
    MessagesApiResp resp = MessagesApiResp();
    resp.all = map['all'];
    resp.offset = map['offset'];
    resp.size = map['size'];
    resp.messages = [];

    List<dynamic> list = map['messages'];
    List<Message> messages = list.map((elem) => Message.fromJson(elem)).toList();
    resp.messages = messages;
    return resp;
  }

  @override
  toString() => "MESSAGES_API_RESP: $size $all";
}

class MessagePublishApiResp {
  String messageId;

  MessagePublishApiResp();

  factory MessagePublishApiResp.fromJson(Map<String, dynamic> map) {
    var resp = MessagePublishApiResp();
    resp.messageId = map['message_id'];
    return resp;
  }
}

class FeaturedRoomsResp {
  List<Room> recent;
  List<Room> crowded;

  FeaturedRoomsResp();

  factory FeaturedRoomsResp.fromJson(Map<String, dynamic> map) {
    var resp = FeaturedRoomsResp();
    List<dynamic> recents = map['recent'];
    List<dynamic> crowdes = map['crowded'];
    resp.recent = recents.map((elem) => Room.fromJson(elem)).toList();
    resp.crowded = crowdes.map((elem) => Room.fromJson(elem)).toList();
    return resp;
  }
}

class AssetUploadResp {
  String orig;
  String thumbnail;

  AssetUploadResp();

  factory AssetUploadResp.fromJson(Map<String, dynamic> map) {
    var resp = AssetUploadResp();
    resp.orig = map['orig'];
    resp.thumbnail = map['thumbnail'];
    return resp;
  } 
}

class MyAssetResp {
  String orig;
  String thumbnail;
  int memeId;

  MyAssetResp();

  factory MyAssetResp.fromJson(Map<String, dynamic> map) {
    var resp = MyAssetResp();
    resp.orig = map['orig'];
    resp.thumbnail = map['thumbnail'];
    resp.memeId = map['meme_id'];
    return resp;
  } 
}


enum ActivationStatus {
  IDLE, SENT, CONFIRMED
}

class ActivationStatusResp {
  String email;
  ActivationStatus status;
  bool passwordRequired;

  ActivationStatusResp();

  factory ActivationStatusResp.fromJson(Map<String, dynamic> map) {
    var resp = ActivationStatusResp();
    resp.email = map['email'];
    var statusExpr = map['status'];
    if (statusExpr == 'IDLE') resp.status = ActivationStatus.IDLE;
    else if (statusExpr == 'SENT') resp.status = ActivationStatus.SENT;
    else if (statusExpr == 'CONFIRMED') resp.status = ActivationStatus.CONFIRMED;
    resp.passwordRequired = map['password_required'];
    return resp;
  }

  @override
  toString() => "ActivationStatusResp: $status $email";
}

class PasswordChangeResp {
  String passphrase;

  PasswordChangeResp();

  factory PasswordChangeResp.fromJson(Map<String, dynamic> map) {
    var resp = PasswordChangeResp();
    resp.passphrase = map['passphrase'];
    return resp;
  }
}

class NickGachaResp {
  Nick prevNick;
  Nick newNick;

  NickGachaResp();
  
  factory NickGachaResp.fromJson(Map<String, dynamic> map) {
    var resp = NickGachaResp();
    resp.prevNick = Nick.fromJson(map['previous']);
    resp.newNick = Nick.fromJson(map['new']);
    return resp;
  }
}

class AvatarGachaResp {
  Avatar prevAvatar;
  Avatar newAvatar;

  AvatarGachaResp();
  
  factory AvatarGachaResp.fromJson(Map<String, dynamic> map) {
    var resp = AvatarGachaResp();
    resp.prevAvatar = Avatar.fromJson(map['previous']);
    resp.newAvatar = Avatar.fromJson(map['new']);
    return resp;
  }
}


enum RegionType {
  FOREIGNER, ALL
}
enum RouletteMatchStatus {
  WAITING, MATCHED
}

class RouletteStatus {
  String requestId;
  RegionType regionType;
  RouletteMatchStatus matchStatus;
  String roomToken;
  DateTime regDate;

  RouletteStatus();

  factory RouletteStatus.fromJson(Map<String, dynamic> map) {
    var resp = RouletteStatus();
    resp.requestId = map['request_id'];
    
    if (map['region_type'] == 'FOREIGNER') {
      resp.regionType = RegionType.FOREIGNER;
    } else {
      resp.regionType = RegionType.ALL;
    }

    if (map['match_status'] == 'WAITING') {
      resp.matchStatus = RouletteMatchStatus.WAITING;
    } else {
      resp.matchStatus = RouletteMatchStatus.MATCHED;
    }

    if (map['room_token'] != null) {
      resp.roomToken = map['room_token'];
    }

    int timestamp = map['reg_date'];
    resp.regDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return resp;
  }
}


enum ServiceStatusType {
  GREEN, RED
}

class ServiceStatus {
  ServiceStatusType type;
  String cause;
  String minimumVersion;

  ServiceStatus();

  factory ServiceStatus.fromJson(Map<String, dynamic> map) {
    ServiceStatus status = ServiceStatus();
    if (map['status'] == 'GREEN') {
      status.type = ServiceStatusType.GREEN;
    } else {
      status.type = ServiceStatusType.RED;
    }

    if (map['cause'] != null) {
      status.cause = map['cause'];
    }

    if (map['minimum_version'] != null) {
      status.minimumVersion = map['minimum_version'];
    }

    return status;
  }
}