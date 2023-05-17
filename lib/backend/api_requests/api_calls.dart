import 'dart:convert';
import 'dart:typed_data';

import '../../flutter_flow/flutter_flow_util.dart';

import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class LoginCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? password = '',
  }) {
    return ApiManager.instance.makeApiCall(
      callName: 'Login',
      apiUrl: 'https://optixcrm.com/api/account/usersignin',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'email': email,
        'password': password,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
    );
  }

  static dynamic userId(dynamic response) => getJsonField(
        response,
        r'''$.Result.User.Id''',
      );
  static dynamic companyId(dynamic response) => getJsonField(
        response,
        r'''$.Result.User.CompanyId''',
      );
  static dynamic firstName(dynamic response) => getJsonField(
        response,
        r'''$.Result.User.FirstName''',
      );
  static dynamic lastName(dynamic response) => getJsonField(
        response,
        r'''$.Result.User.LastName''',
      );
  static dynamic email(dynamic response) => getJsonField(
        response,
        r'''$.Result.User.Email''',
      );
  static dynamic password(dynamic response) => getJsonField(
        response,
        r'''$.Result.User.Password''',
      );
  static dynamic preferredLanguage(dynamic response) => getJsonField(
        response,
        r'''$.Result.User.PreferredLanguage''',
      );
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list);
  } catch (_) {
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar) {
  jsonVar ??= {};
  try {
    return json.encode(jsonVar);
  } catch (_) {
    return '{}';
  }
}
