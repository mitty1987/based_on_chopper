
void main() {
//  final sample = {
//    'foo': 'bar',
//  };
//
//  final res = {
//    'result': 'ok',
//  };
//  group('JSON', () {
//    final buildClient = (bool json, Dio dio) => ChopperClient(
//          services: [
//            // the generated service
//            HttpTestService.create(),
//          ],
//          client: dio,
//          converter: json ? JsonConverter() : FormUrlEncodedConverter(),
//        );
//
//    test('default json', () async {
//      final httpClient = MockClient((http.Request req) async {
//        expect(req.url.toString(), equals('/test/map'));
//        expect(req.headers['content-type'], 'application/json; charset=utf-8');
//        expect(req.body, equals(json.encode(sample)));
//        return http.Response(
//          json.encode(res),
//          200,
//          headers: {'content-type': 'application/json; charset=utf-8'},
//        );
//      });
//
//      final chopper = buildClient(
//        true,
//        httpClient,
//      );
//
//      final result = await chopper
//          .service<HttpTestService>(HttpTestService)
//          .mapTest(sample);
//
//      expect(result.body, equals(res));
//
//      httpClient.close();
//    });
//
//    test('force json', () async {
//      final httpClient = MockClient((http.Request req) async {
//        expect(req.url.toString(), equals('/test/map/json'));
//        expect(req.headers['content-type'], 'application/json; charset=utf-8');
//        expect(req.headers['customConverter'], 'true');
//        expect(req.body, equals(json.encode(sample)));
//        return http.Response(
//          json.encode(res),
//          200,
//          headers: {'content-type': 'application/json; charset=utf-8'},
//        );
//      });
//
//      final chopper = buildClient(
//        false,
//        Dio(),
//      );
//
//      final result = await chopper
//          .service<HttpTestService>(HttpTestService)
//          .forceJsonTest(sample);
//
//      expect(result.body, equals(res));
//
//      httpClient.close();
//    });
//  });
}
