// GENERATED CODE - DO NOT MODIFY BY HAND

part of example.object_to_json;

// **************************************************************************
// DsonGenerator
// **************************************************************************

abstract class _$PersonSerializable<T, T2> extends SerializableMap {
  int get index;
  String get name;
  int get version;
  T get p;
  T2 get p2;
  set index(int v);
  set name(String v);
  set version(int v);
  set p(T v);
  set p2(T2 v);
  dynamic addAll(Map map);
  dynamic n(int index);

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'name':
        return name;
      case 'version':
        return version;
      case 'p':
        return p;
      case 'p2':
        return p2;
      case 'addAll':
        return addAll;
      case 'n':
        return n;
    }
    throwFieldNotFoundException(__key, 'Person');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'index':
        index = __value;
        return;
      case 'name':
        name = __value;
        return;
      case 'version':
        version = __value;
        return;
      case 'p':
        p = __value;
        return;
      case 'p2':
        p2 = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Person');
  }

  Iterable<String> get keys => PersonClassMirror.fields.keys;
}

abstract class _$Person2Serializable<T2> extends SerializableMap {
  int get index;
  String get name;
  int get version;
  T2 get p2;
  set index(int v);
  set name(String v);
  set version(int v);
  set p2(T2 v);

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'name':
        return name;
      case 'version':
        return version;
      case 'p2':
        return p2;
    }
    throwFieldNotFoundException(__key, 'Person2');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'index':
        index = __value;
        return;
      case 'name':
        name = __value;
        return;
      case 'version':
        version = __value;
        return;
      case 'p2':
        p2 = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Person2');
  }

  Iterable<String> get keys => Person2ClassMirror.fields.keys;
}

abstract class _$Person3Serializable extends SerializableMap {
  int get index;
  String get name;
  int get version;
  set index(int v);
  set name(String v);
  set version(int v);

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'name':
        return name;
      case 'version':
        return version;
    }
    throwFieldNotFoundException(__key, 'Person3');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'index':
        index = __value;
        return;
      case 'name':
        name = __value;
        return;
      case 'version':
        version = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Person3');
  }

  Iterable<String> get keys => Person3ClassMirror.fields.keys;
}

abstract class _$Person4Serializable extends SerializableMap {
  int get index;
  String get name;
  int get version;
  set index(int v);
  set name(String v);
  set version(int v);
  dynamic addAll(Map map);

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'name':
        return name;
      case 'version':
        return version;
      case 'addAll':
        return addAll;
    }
    throwFieldNotFoundException(__key, 'Person4');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'index':
        index = __value;
        return;
      case 'name':
        name = __value;
        return;
      case 'version':
        version = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Person4');
  }

  Iterable<String> get keys => Person4ClassMirror.fields.keys;
}

// **************************************************************************
// MirrorsGenerator
// **************************************************************************

_Person__Constructor([positionalParams, namedParams]) => new Person();

const $$Person_fields_index = const DeclarationMirror(name: 'index', type: int);
const $$Person_fields_name =
    const DeclarationMirror(name: 'name', type: String);
const $$Person_fields_version = const DeclarationMirror(
    name: 'version', type: int, annotations: const [ignore]);
const $$Person_fields_p = const DeclarationMirror(
    name: 'p', type: dynamic, annotations: const [const AnT(1)]);
const $$Person_fields_p2 = const DeclarationMirror(
    name: 'p2', type: dynamic, annotations: const [const AnT(2)]);

const PersonClassMirror =
    const ClassMirror(name: 'Person', constructors: const {
  '': const FunctionMirror(name: '', $call: _Person__Constructor)
}, fields: const {
  'index': $$Person_fields_index,
  'name': $$Person_fields_name,
  'version': $$Person_fields_version,
  'p': $$Person_fields_p,
  'p2': $$Person_fields_p2
}, getters: const [
  'index',
  'name',
  'version',
  'p',
  'p2'
], setters: const [
  'index',
  'name',
  'version',
  'p',
  'p2'
], methods: const {
  'addAll': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'map',
          type: const [
            Map,
            const [dynamic, dynamic]
          ],
          isRequired: true)
    ],
    name: 'addAll',
    returnType: dynamic,
  ),
  'n': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'index', type: int, isRequired: true)
    ],
    name: 'n',
    returnType: dynamic,
  )
});

_Person2__Constructor([positionalParams, namedParams]) => new Person2();

const $$Person2_fields_index =
    const DeclarationMirror(name: 'index', type: int);
const $$Person2_fields_name =
    const DeclarationMirror(name: 'name', type: String);
const $$Person2_fields_version =
    const DeclarationMirror(name: 'version', type: int);
const $$Person2_fields_p2 = const DeclarationMirror(
    name: 'p2', type: dynamic, annotations: const [const AnT(1)]);

const Person2ClassMirror =
    const ClassMirror(name: 'Person2', constructors: const {
  '': const FunctionMirror(name: '', $call: _Person2__Constructor)
}, fields: const {
  'index': $$Person2_fields_index,
  'name': $$Person2_fields_name,
  'version': $$Person2_fields_version,
  'p2': $$Person2_fields_p2
}, getters: const [
  'index',
  'name',
  'version',
  'p2'
], setters: const [
  'index',
  'name',
  'version',
  'p2'
]);

_Person3__Constructor([positionalParams, namedParams]) => new Person3();

const $$Person3_fields_index =
    const DeclarationMirror(name: 'index', type: int);
const $$Person3_fields_name =
    const DeclarationMirror(name: 'name', type: String);
const $$Person3_fields_version =
    const DeclarationMirror(name: 'version', type: int);

const Person3ClassMirror =
    const ClassMirror(name: 'Person3', constructors: const {
  '': const FunctionMirror(name: '', $call: _Person3__Constructor)
}, fields: const {
  'index': $$Person3_fields_index,
  'name': $$Person3_fields_name,
  'version': $$Person3_fields_version
}, getters: const [
  'index',
  'name',
  'version'
], setters: const [
  'index',
  'name',
  'version'
]);

_Person4__Constructor([positionalParams, namedParams]) => new Person4();

const $$Person4_fields_index =
    const DeclarationMirror(name: 'index', type: int);
const $$Person4_fields_name =
    const DeclarationMirror(name: 'name', type: String);
const $$Person4_fields_version =
    const DeclarationMirror(name: 'version', type: int);

const Person4ClassMirror =
    const ClassMirror(name: 'Person4', constructors: const {
  '': const FunctionMirror(name: '', $call: _Person4__Constructor)
}, fields: const {
  'index': $$Person4_fields_index,
  'name': $$Person4_fields_name,
  'version': $$Person4_fields_version
}, getters: const [
  'index',
  'name',
  'version'
], setters: const [
  'index',
  'name',
  'version'
], methods: const {
  'addAll': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'map',
          type: const [
            Map,
            const [dynamic, dynamic]
          ],
          isRequired: true)
    ],
    name: 'addAll',
    returnType: dynamic,
  )
});

// **************************************************************************
// InitMirrorsGenerator
// **************************************************************************

_initMirrors() {
  initClassMirrors({
    Person: PersonClassMirror,
    Person2: Person2ClassMirror,
    Person3: Person3ClassMirror,
    Person4: Person4ClassMirror
  });

  getClassMirrorFromGenericInstance = (instance) => instance is Person
      ? PersonClassMirror
      : instance is Person2 ? Person2ClassMirror : null;
}
