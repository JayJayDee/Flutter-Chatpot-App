import 'package:chatpot_app/locales/root_locale_converter.dart';

class ErrorMessageLocales {
  String language;
  RootLocaleConverter root;

  ErrorMessageLocales({
    this.language,
    this.root
  });

  String messageFromErrorCode(String code) {
    if (code == 'ROOM_MAXIMUM_EXCEED') return this.maximumAttendeeExceeded;
    else if (code == 'ROOM_ALREADY_JOINED') return this.roomAlreadyJoined;
    else if (code == 'DUPLICATED_ENTRY') return this.duplicatedEmail;
    else if (code == 'DUPLICATED_EMAIL') return this.duplicatedEmail;
    else if (code == 'AUTH_FAILED') return this.authFailed;
    else if (code == 'CURRENT_PASSWORD_INVALID') return this.invalidPreviousPassword;
    else if (code == 'MEMBER_NOT_EXIST') return this.memberNotExist;
    else if (code == 'SIMPLE_ACCOUNT_PWCHANGE_DENIED') return this.simpleAccountTriesPwChange;
    else if (code == 'INVALID_MAX_ATTENDEE') return this.invalidMaxAttendee;
    else if (code == 'NETWORK_ERROR') return this.networkError;
    return uncatchedCode(code);
  }

  String get invalidMaxAttendee {
    if (language == 'ko') return '채팅방 인원은 최소 2명에서 최대 10명 까지 설정할 수 있습니다.';
    else if (language == 'ja') return 'チャットルームには2〜10人を設定できます。';
    return 'You can set 2 to 10 people in your chat room.';
  }

  String get roomAlreadyJoined {
    if (language == 'ko') return '이미 참여한 채팅방입니다.';
    else if (language == 'ja') return 'もうチャットルームです。';
    return "It's already been my chat room.";
  }

  String get maximumAttendeeExceeded {
    if (language == 'ko') return '이미 채팅방의 최대 인원수에 도달하였습니다.';
    else if (language == 'ja') return 'すでに最大参加人数に達しています。';
    return "The room you selected has reached the maximum number of attendees";
  }

  String get duplicatedEmail {
    if (language == 'ko') return '이미 사용중인 이메일 주소입니다';
    else if (language == 'ja') return '既に使用されている電子メールアドレス';
    return 'This email address is already in use';
  }

  String get authFailed {
    if (language == 'ko') return '''로그인에 실패하였습니다.
이메일과 비밀번호를 확인해 주세요.''';
    else if (language == 'ja') return '''ログインに失敗しました。
メールアドレスとパスワードを確認してください。''';
    return '''Login failed.
Please check your email and password.''';
  }

  String get memberNotExist {
    if (language == 'ko') return '존재하지 않는 회원입니다.';
    else if (language == 'ja') return 'このメンバーは存在しません。';
    return 'This member does not exist.';
  }

  String get simpleAccountTriesPwChange {
    if (language == 'ko') return '간편 로그인 타입의 회원은 비밀번호를 변경할 수 없습니다.';
    else if (language == 'ja') return '単純ログインタイプのメンバーは自分のパスワードを変更できません。';
    return 'Members of the simple login type can not change their password.';
  }

  String get invalidPreviousPassword {
    if (language == 'ko') return '기존 비밀번호가 일치하지 않습니다.';
    else if (language == 'ja') return '以前のパスワードが一致しません。';
    return 'Previous passwords do not match.';
  }

  String get networkError {
    if (language == 'ko') return '네트워크 에러가 발생했습니다. 나중에 앱을 다시 시작해 보세요.';
    else if (language == 'ja') return 'ネットワークエラーが発生しました。 後でアプリを再起動してください。';
    return 'Network error occured. Please restart the app later.';
  }

  String uncatchedCode(String code) {
    if (language == 'ko') return "알 수 없는 에러가 발생했습니다: $code";
    else if (language == 'ja') return "不明なエラーが発生しました：$code";
    return "An unknown error occurred: $code";
  }
}