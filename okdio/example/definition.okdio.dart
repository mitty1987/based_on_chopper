// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'definition.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

class _$MyService extends MyService {
  _$MyService([ChopperClient client]) {
    if (client == null) return;
    this.client = client;
  }

  final definitionType = MyService;

  Observable<Map<String, Person<Person2<Person3>, Person4>>> getResourceAll4(
      UploadFileInfo b,
      {int a = 1,
      int c}) {
    final $url = '/test2';
    final Map<String, dynamic> $body = {'file1': a, 'c1': c};
    final $parts = {'b': b};
    $body.addAll($parts);
    final $formData = FormData.from($body);
    $body.removeWhere((k, v) => v == null);
    final $request = Request('POST', $url, client.baseUrl, body: $formData);
    var $keyPerson1 = "";
    PersonClassMirror.fields.forEach((k, v) {
      if (v.annotations?.any((a) => (a is AnT && a.index == 1)) ?? false) {
        $keyPerson1 = k;
      }
    });
    var $keyPerson21 = "";
    Person2ClassMirror.fields.forEach((k, v) {
      if (v.annotations?.any((a) => (a is AnT && a.index == 1)) ?? false) {
        $keyPerson21 = k;
      }
    });
    var $keyPerson2 = "";
    PersonClassMirror.fields.forEach((k, v) {
      if (v.annotations?.any((a) => (a is AnT && a.index == 2)) ?? false) {
        $keyPerson2 = k;
      }
    });
    final $mkType = [
      () => Map<String, Person<Person2<Person3>, Person4>>(),
      [
        String,
        [
          () => Person<Person2<Person3>, Person4>(),
          {
            $keyPerson1: [
              () => Person2<Person3>(),
              {$keyPerson21: Person3}
            ],
            $keyPerson2: Person4
          }
        ]
      ]
    ];
    final $send = client.send<String>($request);
    return $send.map((data) => fromJson(data, $mkType));
  }

  Observable<Person2<List<Person4>>> getResourceAll71() {
    final $url = '/test71';
    final $request = Request('GET', $url, client.baseUrl);
    var $keyPerson21 = "";
    Person2ClassMirror.fields.forEach((k, v) {
      if (v.annotations?.any((a) => (a is AnT && a.index == 1)) ?? false) {
        $keyPerson21 = k;
      }
    });
    final $mkType = [
      () => Person2<List<Person4>>(),
      {
        $keyPerson21: [() => List<Person4>(), Person4]
      }
    ];
    final $send = client.send<String>($request);
    return $send.map((data) => fromJson(data, $mkType));
  }
}
