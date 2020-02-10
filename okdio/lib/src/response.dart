import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

@immutable
class MyResponse<Body> {
  final Response base;
  final Body body;

  const MyResponse(this.base, this.body);

  MyResponse replace<BodyType>({Response base, BodyType body}) =>
      MyResponse<BodyType>(base ?? this.base, body ?? this.body);

  MyResponse<Body> replaceWithNull<Body>({Response base, Body body}) =>
      MyResponse(base ?? this.base, body);

  int get statusCode => base.statusCode;

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  Headers get headers => base.headers;

  Uint8List get bodyBytes => (body as List<int>).cast<int>();

  Map<String, dynamic> get extra => base.extra;

  Options get request => base.request;
}
