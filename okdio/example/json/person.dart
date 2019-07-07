library example.object_to_json;
import 'package:okdio/okdio.dart';
import 'package:dson/dson.dart';

part 'person.g.dart';

@serializable
class Person<T, T2> extends _$PersonSerializable<T, T2> {
   int index;
   String name;
   @ignore
   int version;
   @AnT(1)
   T p;
   @AnT(2)
   T2 p2;
//   Person();
//   factory Person.fromJson(String s, cos) =>
//     fromJson(s, [() => Person<Person2<Person3>>(), {'p': [() => Person2<Person3>(), {"p2": [() => Person3(), Person3]}]}]);

  @override//keys.forEach((key) => this[key] = map[key]);
  addAll(Map map) {
    if (map!=null)
      keys.forEach((key) => this[key] = map[key]);
  }

   n(int index) {
     var $key_1 = "";
     PersonClassMirror.fields.forEach((k, v) {
       if (v.annotations?.any((a) => a == AnT(index)) ?? false) {
         $key_1 = k;
       }
     });
   }
}

//part 'person.g.dart';
@serializable
class Person2<T2> extends _$Person2Serializable<T2>{
  int index;
  String name;
  int version;
  @AnT(1)
  T2 p2;
}

@serializable
class Person3 extends _$Person3Serializable{
  int index;
  String name;
  int version;
}

@serializable
class Person4 extends _$Person4Serializable{
  int index;
  String name;
  int version;
  @override//keys.forEach((key) => this[key] = map[key]);
  addAll(Map map) {
    if (map!=null)
      keys.forEach((key) => this[key] = map[key]);
  }
}

init() => _initMirrors();

void main(){}
