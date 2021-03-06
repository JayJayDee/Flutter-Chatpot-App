import 'package:meta/meta.dart';
import 'dart:async';
import 'package:chatpot_app/apis/requester.dart';
import 'package:chatpot_app/entities/report.dart';

class ReportApi {
  Requester _requester;

  ReportApi({
    @required Requester requester
  }) {
    _requester = requester;
  }

  Future<void> requestReport({
    @required String memberToken,
    @required String targetToken,
    @required String roomToken,
    @required ReportType reportType,
    String comment
  }) async {
    await _requester.requestWithAuth(
      url: '/abuse/report',
      method: HttpMethod.POST,
      body: {
        'member_token': memberToken,
        'target_token': targetToken,
        'room_token': roomToken,
        'report_type': _getReportTypeExpr(reportType),
        'comment': comment == null ? '' : comment
      }
    );
  }

  Future<List<ReportStatus>> requestMyReports({
    @required String memberToken
  }) async {
    List<dynamic> rawList = await _requester.requestWithAuth(
      url: "/abuse/$memberToken/reports",
      method: HttpMethod.GET
    );
    List<ReportStatus> list = 
      rawList.toList().map((elem) => ReportStatus.fromJson(elem)).toList();
    return list;
  }
}

String _getReportTypeExpr(ReportType type) {
  if (type == ReportType.HATE) return 'HATE';
  else if (type == ReportType.SEXUAL) return 'SEXUAL';
  return 'ETC';
}