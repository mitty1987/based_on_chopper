import "dart:async";
import "package:meta/meta.dart";
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:io';

import "interceptor.dart";
import "request.dart";
import 'response.dart';

typedef void SendProgressFunc(int send, int total);
typedef DioError ErrorConverter(DioError error);

/// Root object of chopper
/// Used to manager services, encode data, intercept request, response and error.
class ChopperClient {
  /// base url of each request to your api
  /// hostname of your api for example
  final String baseUrl;

  /// http client used to do request
  /// from `package:http/http.dart`
  final Dio dio;

  /// converter call on error request
  final ErrorConverter errorConverter;

  final Map<Type, ChopperService> _services = {};

  //final _requestController = StreamController<Request>.broadcast();
  //final _responseController = StreamController<Response>.broadcast();
  //final _responseErrorController = StreamController<Response>.broadcast();

  //final bool _clientIsInternal;
  final SendProgressFunc onSendProgress;

//  _parseAndDecode(String response) {
//    return jsonDecode(response);
//  }
//
//  parseJson(String text) {
//    return compute(_parseAndDecode, text);
//  }

  ChopperClient({
    this.baseUrl: "",
    BaseOptions ops,
    List<Interceptor> iterable,
    this.errorConverter,
    this.onSendProgress,
    HttpClientAdapter adapter,
    Iterable<ChopperService> services: const [],
  }) : dio = (ops != null) ? Dio(ops) : (Dio()
          ..options.connectTimeout = 15000
          ..options.receiveTimeout = 15000
          ..options.contentType = ContentType.parse("application/x-www-form-urlencoded"))
  {
    if (adapter != null) dio.httpClientAdapter = adapter;
    if (iterable != null) dio.interceptors.addAll(iterable);
    services.toSet().forEach((s) {
      s.client = this;
      _services[s.definitionType] = s;
    });
  }

  T service<T extends ChopperService>(Type type) {
    final s = _services[type];
    if (s == null) {
      throw Exception("Service of type '$type' not found.");
    }
    return s;
  }

  Future<MyResponse<Body>> _decodeResponse<Body, ToDecode>(
    MyResponse response,
    Converter withConverter,
  ) async {
    if (withConverter == null) return response;

    final converted = await withConverter.convertResponse<ToDecode>(response);

    if (converted == null) {
      throw Exception("No converter found for type $ToDecode");
    }

    return converted;
  }

  Observable<MyResponse<Body>> sendWarpMyResponse<Body>(Request request) {
    CancelToken token = CancelToken();
    return Observable(_request<Body>(request, token).asStream()).map<MyResponse<Body>>((resp) {
      MyResponse<Body> res = MyResponse<Body>(resp, resp.data);
      return res;
    }).doOnCancel(() {
      token.cancel();
    }).handleError((e) {
      throw errorConverter((e as DioError));
    }, test: (a) {
      return a is DioError;
    });
  }

  Observable<Body> send<Body>(Request request) {
    CancelToken token = CancelToken();
    return Observable(_request<Body>(request, token).asStream()).map<Body>((resp) {
      return resp.data;
    }).handleError((e) {
      throw errorConverter((e as DioError));
    }, test: (a) {
      return a is DioError;
    });
  }

  Future<Response<Body>> _request<Body>(Request request, CancelToken token) {
    Request req = request;
    Options options = req.options ?? Options();
    options.headers.addAll(req.headers);
    _preData(dynamic data) {
      if (data is List<int>) {
        options?.headers[HttpHeaders.contentLengthHeader] = data.length;
        return Stream.fromIterable(data.map((e) => [e]));
      } else {
        return data;
      }
    }

    switch (req.method) {
      case HttpMethod.Delete:
        return dio.deleteUri<Body>(req.buildUri(), data: req.body, options: options, cancelToken: token);
      case HttpMethod.Patch:
        return dio.patchUri<Body>(req.buildUri(), data: _preData(req.body), options: options, cancelToken: token,
            onSendProgress: (int sent, int total) {
          //print("$sent $total");
          if (onSendProgress != null) onSendProgress(sent, total);
        });
      case HttpMethod.Post:
        return dio.postUri<Body>(req.buildUri(), data: _preData(req.body), options: options, cancelToken: token,
            onSendProgress: (int sent, int total) {
          //print("$sent $total");
          if (onSendProgress != null) onSendProgress(sent, total);
        });
      case HttpMethod.Put:
        return dio.putUri<Body>(req.buildUri(), data: _preData(req.body), options: options, cancelToken: token,
            onSendProgress: (int sent, int total) {
          //print("$sent $total");
          if (onSendProgress != null) onSendProgress(sent, total);
        });
      default:
        {
          //print("GET: ${req.buildUri()}");
          return dio.getUri<Body>(req.buildUri(), options: options);
        }
    }
  }

  Observable get<Body>(
    String url, {
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'GET',
          url,
          baseUrl,
          headers: headers,
        ),
      );

  Observable post<Body>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'POST',
          url,
          baseUrl,
          body: body,
          parts: parts,
          headers: headers,
        ),
      );

  Observable put<Body>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'PUT',
          url,
          baseUrl,
          body: body,
          parts: parts,
          headers: headers,
        ),
      );

  Observable patch<Body>(
    String url, {
    dynamic body,
    List<PartValue> parts,
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'PATCH',
          url,
          baseUrl,
          body: body,
          parts: parts,
          headers: headers,
        ),
      );

  Observable delete<Body>(
    String url, {
    Map<String, String> headers,
  }) =>
      send(
        Request(
          'DELETE',
          url,
          baseUrl,
          headers: headers,
        ),
      );

  @Deprecated('use dispose')
  @mustCallSuper
  void close() {
    dispose();
  }

  /// dispose [ChopperClient] to clean memory
  @mustCallSuper
  void dispose() {
    //_requestController.close();
    //_responseController.close();
    //_responseErrorController.close();

    _services.forEach((_, s) => s.dispose());
    _services.clear();

    dio.clear();
  }

  /// Event stream of request just before http call
  /// all converters and interceptors have been run
//Stream<Request> get onRequest => _requestController.stream;

  /// Event stream of response
  /// all converters and interceptors have been run
//Stream<Response> get onResponse => _responseController.stream;

  /// Event stream of error response (status code <200 >=300)
  /// all converters and interceptors have been run
// Stream<Response> get onError => _responseErrorController.stream;
}

/// Used by generator to generate apis
abstract class ChopperService {
  ChopperClient client;

  Type get definitionType => null;

  @mustCallSuper
  void dispose() {
    client = null;
  }
}
