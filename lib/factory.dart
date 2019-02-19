import 'package:chatpot_app/storage/auth_accessor.dart';
import 'package:chatpot_app/apis/requester.dart';
import 'package:chatpot_app/storage/pref_auth_accessor.dart';
import 'package:chatpot_app/apis/default_requester.dart';

Map<String, dynamic> _instances;

void initFactory() {
  _instances = new Map<String, dynamic>();
  _instances['AuthAccessor'] = PrefAuthAccessor();
  _instances['MemberRequester'] = _initMemberRequester();
  _instances['RoomRequester'] = _initRoomRequseter();
}

Requester _initMemberRequester() => DefaultRequester(
  accessor: authAccessor(),
  baseUrl: 'http://dev-auth.chatpot.chat'
);

Requester _initRoomRequseter() => DefaultRequester(
  accessor: authAccessor(),
  baseUrl: 'http://dev-room.chatpot.chat'
);

AuthAccessor authAccessor() => _instances['AuthAccessor'];
Requester memberRequester() => _instances['MemberRequester'];
Requester roomRequester() => _instances['RoomRequester'];