

//void main() {
//  group('Form', () {
//    final sample = {
//      'foo': 'bar',
//    };
//
//    group('Form', () {
//      final buildClient =
//          (http.Client httpClient, {bool json: false}) => ChopperClient(
//                services: [
//                  // the generated service
//                  HttpTestService.create(),
//                ],
//                client: httpClient,
//                converter: FormUrlEncodedConverter(),
//              );
//
//      test('form-urlencoded default', () async {
//        final httpClient = MockClient((http.Request req) async {
//          expect(req.url.toString(), equals('/test/map'));
//          expect(
//            req.headers['content-type'],
//            'application/x-www-form-urlencoded; charset=utf-8',
//          );
//          expect(req.body, 'foo=bar');
//          return http.Response('ok', 200);
//        });
//
//        final chopper = buildClient(httpClient);
//
//        final result = await chopper
//            .service<HttpTestService>(HttpTestService)
//            .mapTest(sample);
//
//        expect(result.body, equals('ok'));
//
//        httpClient.close();
//      });
//    });
//  });
//}
