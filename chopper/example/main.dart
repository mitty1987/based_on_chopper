import 'dart:convert';
import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:chopper/src/interceptor.dart';
import 'definition.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dio/dio.dart';
import 'json/person.dart';

main() async {
  print(1);
  init();
  print(2);
  const bool inProduction = const bool.fromEnvironment("dart.vm.product"); //release == true
  print(inProduction);
  final chopper = ChopperClient(
      baseUrl: "http://mockserver",
      services: [
        // the generated service
        MyService.create()
      ],
      onSendProgress: (int sent, int total) {
        print("$sent, $total");
      },
      adapter: MockAdapter(),
      errorConverter: (DioError error) {
        print("Error Happend: type:${error.type}, status[${error.response?.statusCode}]");
        switch(error.type) {
          case DioErrorType.DEFAULT:
            error.message = "网络出错啦";
            break;
          case DioErrorType.CANCEL:
            error.message = "";
            break;
          case DioErrorType.CONNECT_TIMEOUT:
            error.message = "连接超时";
            break;
          case DioErrorType.RECEIVE_TIMEOUT:
            error.message = "网络超时";
            break;
          case DioErrorType.SEND_TIMEOUT:
            error.message = "网络超时";
            break;
          case DioErrorType.RESPONSE:
            int code = error.response.statusCode;
            if (code >= 400 && code < 500) {
              error.message = "客户端错误的请求";
            } else if (code >= 500 && code < 700) {
              error.message = "服务器发生错误";
            }
            break;
        }
        return error;
      },
      iterable: <Interceptor>[
        InterceptorsWrapper(onRequest: (RequestOptions options) {
          print("head test");
          options.headers["MyHead"] = "head test";
        }),
        LogInterceptor(
            responseBody: false,
            requestHeader: !inProduction,
            request: !inProduction,
            requestBody: !inProduction,
            responseHeader: !inProduction,
            error: !inProduction),
        //CookieManager(CookieJar())
      ]);
  print(4);
  var l = ()=>List<Person>();
  final myService = chopper.service<MyService>(MyService);

  final response = await myService.getResourceAll4(UploadFileInfo(File(""), "1"));
  response.listen((p) {
    print(p["name"].p.p2.name);
  }, onError: (e) {
    print("onError $e");
  });
//
//  final response2 = await myService.getResourceAll23();
//  response2.listen((p) {
//    print(p.body.name);
//    print(p.body.p2.name);
//    //print(p.body.p.p2.name);
//  }, onError: (e) {
//    print("onError $e");
//  });

//  final response4 = await myService.getResourceAll71();
//  response4.listen((p) {
//    print(p.p2[0].name);
//    //print(p[1].p2.name);
//    //print(p.body.p.p2.name);
//  }, onError: (e) {
//    print("onError $e");
//  });

//  final response3 = await myService.getResourceAll3();
//  response3.listen((p) {
//    print(p.body.name);
//    print(p.body.p2.name);
//    //print(p.body.p.p2.name);
//  }, onError: (e) {
//    print("onError $e");
//  });
//
//  myService.getResourceAll5().listen((d) {
//    print(d[0].name);
//  });
//
//  //Person<Person3, Per..n()son3>()..p=Person3();
//
//  List<int> l = [1, 2, 3];
//  print(l is List);


  chopper.dispose();
}

class MockAdapter extends HttpClientAdapter {
  static const String mockHost = "mockserver";
  static const String mockBase = "http://$mockHost";
  DefaultHttpClientAdapter _defaultHttpClientAdapter =
  DefaultHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>> requestStream, Future cancelFuture) async {
    Uri uri = options.uri;
    if (uri.host == mockHost) {
      print(uri.path);
      switch (uri.path) {
        case "/test":
          return ResponseBody.fromString(
            jsonEncode({
              "index": 0,
              "name": "mock",//{"path": uri.path}
              "p":{
                "index": 1,
                "name": "mock2----",//{"path": uri.path}
                 "p2":{
                    "index": 1,
                    "name": "mock3----2222222--",//{"path": uri.path}
                  }
              },
              "p2":{
                "index": 1,
                "name": "mock344444------",//{"path": uri.path}
              }
            }),
            200,
            DioHttpHeaders.fromMap({
              HttpHeaders.contentTypeHeader: ContentType.json,
            }),
          );
        case "/test2":
          return ResponseBody.fromString(
            jsonEncode({
              "name": {
                "p":{
                  "index": 1,
                  "name": "mock2----",//{"path": uri.path}
                  "p2":{
                    "index": 1,
                    "name": "mock3---vvvvv---",//{"path": uri.path}
                  }
                },
                "p2":{
                  "index": 1,
                  "name": "mock3------",//{"path": uri.path}
                }
              },//{"path": uri.path}
            }),
            200,
            DioHttpHeaders.fromMap({
              HttpHeaders.contentTypeHeader: ContentType.json,
            }),
          );
        case "/test12":
          return ResponseBody.fromString(
            jsonEncode({
              "index": 0,
              "name": "mock",//{"path": uri.path}

              "p2":null,
            }),
            200,
            DioHttpHeaders.fromMap({
              HttpHeaders.contentTypeHeader: ContentType.json,
            }),
          );
        case "/test42":
          return ResponseBody.fromString(
            jsonEncode({
              "name":{
                "index": 1,
                "name": "mock344444------",//{"path": uri.path}
                "hh":"---"
              }
            }),
            200,
            DioHttpHeaders.fromMap({
              HttpHeaders.contentTypeHeader: ContentType.json,
            }),
          );
        case "/test71":
          return ResponseBody.fromString(
            jsonEncode({
              "name":"",
              "p2":[{
                "name":"hhhh"
              }]
            }),
            200,
            DioHttpHeaders.fromMap({
              HttpHeaders.contentTypeHeader: ContentType.json,
            }),
          );
        case "/test4":
          return ResponseBody.fromString(
            jsonEncode([{
              "index": 0,
              "name": "mock",//{"path": uri.path}
              "p":{
                "index": 1,
                "name": "mocddddk344444------",//{"path": uri.path}
              },
              "p2":{
                "index": 1,
                "name": "mock344444------",//{"path": uri.path}
              }
            }, {
              "index": 0,
              "name": "4mock",//{"path": uri.path}
              "p":{
                "index": 1,
                "name": "3mocddddk344444------",//{"path": uri.path}
              },
              "p2":{
                "index": 1,
                "name": "3mock344444------",//{"path": uri.path}
              }
            }]),
            200,
            DioHttpHeaders.fromMap({
              HttpHeaders.contentTypeHeader: ContentType.json,
            }),
          );
        case "/download":
          return ResponseBody(
            File("./README.MD").openRead(),
            200,
            DioHttpHeaders.fromMap({
              HttpHeaders.contentLengthHeader: File("./README.MD").lengthSync(),
            }),
          );

        case "/token":
          {
            var t = "ABCDEFGHIJKLMN".split("")..shuffle();
            return ResponseBody.fromString(
              jsonEncode({
                "errCode": 0,
                "data": {"token": t.join()}
              }),
              200,
              DioHttpHeaders.fromMap({
                HttpHeaders.contentTypeHeader: ContentType.json,
              }),
            );
          }
        default:
          return ResponseBody.fromString("", 404, DioHttpHeaders());
      }
    }
    return _defaultHttpClientAdapter.fetch(
        options, requestStream, cancelFuture);
  }
}
