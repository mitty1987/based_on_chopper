import "dart:async";
import 'package:okdio/okdio.dart';
import 'json/person.dart';
import 'package:dio/dio.dart';
import 'package:dson/dson.dart';
import 'package:rxdart/rxdart.dart';
part "definition.okdio.dart";

@ChopperApi(baseUrl: "")
abstract class MyService extends ChopperService {
  static MyService create([ChopperClient client]) => _$MyService(client);

//  @Get(path: "/{id}")
//  Observable<MyResponse<List<Map<String, dynamic>>>> getResource(
//    @Path() String id, @DioOptions() Options options, @Header("name") String name
//  );
//
//  @Get(path: "/{id}")
//  Observable<MyResponse<List<Person>>> getResource2(
//      @Path() String id, @DioOptions() Options options, @Header("name") String name
//      );
//
//  @Get(path: "")
//  Observable<MyResponse> getResourceAll();
//


  @multipart
  @Post(path: "/test2")
  Observable<Map<String, Person<Person2<Person3>, Person4>>> getResourceAll4(@Part() UploadFileInfo b, {@Field('file1') int a = 1, @Field('c1') int c});

//  @Get(path: "/test")
//  Observable<MyResponse<Person<Person2<Person3>, Person4>>> getResourceAll3();

//  @Get(path: "/test12")
//  Observable<MyResponse<Person2<Person4>>> getResourceAll23();
//
//  @Get(path: "/test42")
//  Observable<Map<String, Person<Person2<Person3>, Person4>>> getResourceAll42();

//  @Get(path: "/test3")
//  Observable<Map<String, Person>> getResourceAll41();
//
//  @Get(path: "/test421")
//  Observable<Map> getResourceAll421();

//  @Get(path: "/test411")
//  Observable<List<Person<Person2<Person3>, Person4>>> getResourceAll51();

//  @Get(path: "/test4")
//  Observable<List<Person<Person3, Person4>>> getResourceAll5();
//
//  @Get(path: "/test42")
//  Observable<Map<String, Person4>> getResourceAll52(@Header() String head);
//
//  @Get(path: "/test5")
//  Observable<List<Person3>> getResourceAll7();

  @Get(path: "/test71")
  Observable<Person2<List<Person4>>> getResourceAll71();

//  @Get(path: "/test6")
//  Observable<Person2> getResourceAll6();


//  final $mkType = [
//        () => Person<Person2<Person3>, Person4>(),
//    {
//      $key_Person_1: [
//            () => Person2<Person3>(),
//        {
//          $key_Person2_1: [() => Person3(), Person3]
//        }
//      ],
//      $key_Person_2: [() => Person4(), Person4]
//    }
//  ];

//
//  @Get(path: "/test")
//  Observable<MyResponse<List<Person>>> getResourceAll4();
//
//  @Get(path: "/version")
//  Observable<List<Person>> getResourceAll2(@Body() FormData data);//List<int>
//
//  @Get(path: "/", headers: const {"foo": "bar"})
//  Observable<Person> getMapResource(
//    @Query() String id
//  );
//
//  @Get(path: "/resources")
//  Observable<List<Person>> getListResources();
//
//  @Post(path: '/')
//  Observable<Map<String, dynamic>> postResourceUrlEncoded(
//    @Field('a') String toto,
//    @Field() String b,
//  );
//
//  @Post(path: '/multi')
//  @multipart
//  Observable<String> postResources(
//    @Part('1') Map a,
//    @Part('2') Map b,
//    @Part('3') String c,
//  );

//  @Post(path: '/file')
//  @multipart
//  Observable<Map> postFile(
//    @FileField('file') List<int> bytes,
//  );
}
