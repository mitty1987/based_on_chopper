import 'dart:async';
import 'dart:convert';
import "package:meta/meta.dart";
import 'package:logging/logging.dart';

import 'request.dart';
import 'response.dart';
import 'utils.dart';

@immutable
abstract class ResponseInterceptor {
  FutureOr<MyResponse> onResponse(MyResponse response);
}

@immutable
abstract class RequestInterceptor {
  FutureOr<Request> onRequest(Request request);
}

@immutable
abstract class Converter {
  FutureOr<Request> convertRequest(Request request);
  FutureOr<MyResponse> convertResponse<ConvertedResponseType>(MyResponse response);
}

@immutable
class HeadersInterceptor implements RequestInterceptor {
  final Map<String, String> headers;

  const HeadersInterceptor(this.headers);

  Future<Request> onRequest(Request request) async =>
      applyHeaders(request, headers);
}

typedef FutureOr<MyResponse> ResponseInterceptorFunc<Value>(
    MyResponse<Value> response);
typedef FutureOr<Request> RequestInterceptorFunc(Request request);

/// Interceptor that print a curl request
/// thanks @edwardaux
class CurlInterceptor implements RequestInterceptor {
  Future<Request> onRequest(Request request) async {
    //final baseRequest = await request.toHttpRequest();
    final method = request.method;
    final url = request.buildUri().toString();
    final headers = request.headers;
    var curl = '';
    curl += 'curl';
    curl += ' -v';
    curl += ' -X $method';
    headers.forEach((k, v) {
      curl += ' -H \'$k: $v\'';
    });
    // this is fairly naive, but it should cover most cases
    final body = request.body;
    if (body != null && body.isNotEmpty) {
      curl += ' -d \'$body\'';
    }
    curl += ' $url';
    chopperLogger.info(curl);
    return request;
  }
}

class HttpLoggingInterceptor
    implements RequestInterceptor, ResponseInterceptor {
  final _log = Logger('Chopper');

  @override
  FutureOr<Request> onRequest(Request request) async {
   // final base = await request.toHttpRequest();
    _log.info('--> ${request.method} ${request.buildUri()}');
    request.headers.forEach((k, v) {
      _log.info('$k: $v');
    });

    var bytes = '';
    final body = request.body;
    if (body != null && body.isNotEmpty) {
      _log.info(body);
      bytes = ' (${((body as List<int>).cast<int>()).length}-byte body)';
    }

    _log.info('--> END ${request.method}$bytes');
    return request;
  }

  @override
  FutureOr<MyResponse> onResponse(MyResponse response) {
    final base = response.base.request;
    _log.info('<-- ${response.statusCode} ${base.path}');

    response.base.headers.forEach((k, v) {
      _log.info('$k: $v');
    });

    var bytes;
    if (response.base.data != null && response.base.data.isNotEmpty) {
      _log.info(response.base.data);
      bytes = ' (${((response.base.data as List<int>).cast<int>()).length}-byte body)';
    }

    _log.info('--> END ${base.method}$bytes');
    return response;
  }
}

@immutable
class JsonConverter implements Converter {
  @override
  Request convertRequest(Request request) => applyHeader(
        request,
        contentTypeKey,
        jsonHeaders,
      ).replace(
        body: json.encode(request.body),
      );

  @override
  MyResponse convertResponse<ConvertedResponseType>(MyResponse response) {
    var contentType = response.headers[contentTypeKey];
    var body = response.body;
    if (contentType != null && contentType.contains(jsonHeaders)) {
      // If we're decoding JSON, there's some ambiguity in https://tools.ietf.org/html/rfc2616
      // about what encoding should be used if the content-type doesn't contain a 'charset'
      // parameter. See https://github.com/dart-lang/http/issues/186. In a nutshell, without
      // an explicit charset, the Dart http library will fall back to using ISO-8859-1, however,
      // https://tools.ietf.org/html/rfc8259 says that JSON must be encoded using UTF-8. So,
      // we're going to explicitly decode using UTF-8... if we don't do this, then we can easily
      // end up with our JSON string containing incorrectly decoded characters.
      body = utf8.decode(response.bodyBytes);
    }
    return response.replace(
      body: _tryDecodeJson(body),
    );
  }

  dynamic _tryDecodeJson(String data) {
    try {
      return json.decode(data);
    } catch (e) {
      chopperLogger.warning(e);
      return data;
    }
  }
}

class FormUrlEncodedConverter implements Converter {
  @override
  Request convertRequest(Request request) => applyHeader(
        request,
        contentTypeKey,
        formEncodedHeaders,
      );

  @override
  MyResponse convertResponse<ConvertedResponseType>(MyResponse response) =>
      response;
}
