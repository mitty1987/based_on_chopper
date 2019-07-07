///@nodoc
import 'dart:async';
//import 'dart:mirrors';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dart_style/dart_style.dart';

import 'package:source_gen/source_gen.dart';
import 'package:code_builder/code_builder.dart';
import 'package:okdio/okdio.dart' as chopper;

const _clientVar = 'client';
const _baseUrlVar = "baseUrl";
const _parametersVar = "\$params";
const _headersVar = "\$headers";
const _requestVar = "\$request";
const _bodyVar = '\$body';
const _partsVar = '\$parts';
const _urlVar = "\$url";
const _options = "\$options";

class ChopperGenerator extends GeneratorForAnnotation<chopper.ChopperApi> {
  @override
  FutureOr<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      final friendlyName = element.displayName;
      throw new InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: 'Remove the [ChopperApi] annotation from `$friendlyName`.',
      );
    }

    return _buildImplementionClass(annotation, element);
  }

  bool _extendsChopperService(InterfaceType t) => _typeChecker(chopper.ChopperService).isExactlyType(t);

  Field _buildDefinitionTypeMethod(String superType) => Field(
        (m) => m
          ..name = 'definitionType'
          ..modifier = FieldModifier.final$
          ..assignment = Code(superType),
      );

  String _buildImplementionClass(
    ConstantReader annotation,
    ClassElement element,
  ) {
    if (element.allSupertypes.any(_extendsChopperService) == false) {
      final friendlyName = element.displayName;
      throw new InvalidGenerationSourceError(
        'Generator cannot target `$friendlyName`.',
        todo: '`$friendlyName` need to extends the [ChopperService] class.',
      );
    }

    final friendlyName = element.name;
    final name = '_\$${friendlyName}';
    final baseUrl = annotation?.peek(_baseUrlVar)?.stringValue ?? '';

    final classBuilder = new Class((c) {
      c
        ..name = name
        ..constructors.addAll([
          _generateConstructor(),
        ])
        ..methods.addAll(_parseMethods(element, baseUrl))
        ..fields.add(_buildDefinitionTypeMethod(friendlyName))
        ..extend = refer(friendlyName);
    });

    final emitter = new DartEmitter();
    return new DartFormatter().format('${classBuilder.accept(emitter)}');
  }

  Constructor _generateConstructor() => Constructor((c) {
        c.optionalParameters.add(Parameter((p) {
          p.name = _clientVar;
          p.type = refer('${chopper.ChopperClient}');
        }));

        c.body = Code(
          'if ($_clientVar == null) return;this.$_clientVar = $_clientVar;',
        );
      });

  Iterable<Method> _parseMethods(ClassElement element, String baseUrl) => element.methods.where((MethodElement m) {
        final methodAnnot = _getMethodAnnotation(m);
        return methodAnnot != null && m.isAbstract && m.returnType.name == "Observable";
      }).map((MethodElement m) => _generateMethod(m, baseUrl));

  Method _generateMethod(MethodElement m, String baseUrl) {
    final method = _getMethodAnnotation(m);
    final multipart = _hasAnnotation(m, chopper.Multipart);
    final factoryConverter = _getFactoryConverterAnotation(m);

    final body = _getAnnotation(m, chopper.Body);
    final paths = _getAnnotations(m, chopper.Path);
    final queries = _getAnnotations(m, chopper.Query);
    final fields = _getAnnotations(m, chopper.Field);
    final parts = _getAnnotations(m, chopper.Part);
    final options = _getAnnotation(m, chopper.DioOptions);
    final fileFields = _getAnnotations(m, chopper.FileField);

    final headers = _generateHeaders(m, method);
    final url = _generateUrl(method, paths, baseUrl);
    final responseType = _getResponseType(m.returnType);
    final responseInnerType = _getResponseInnerType(m.returnType) ?? responseType;

    return new Method((b) {
      b.name = m.displayName;
      b.returns = new Reference(m.returnType.displayName);
      b.requiredParameters.addAll(m.parameters.where((p) => p.isNotOptional).map((p) => new Parameter((pb) => pb
        ..name = p.name
        ..type = new Reference(p.type.displayName))));

      b.optionalParameters.addAll(m.parameters.where((p) => p.isOptionalPositional).map((p) => new Parameter((pb) => pb
        ..name = p.name
        ..type = new Reference(p.type.displayName))));

      b.optionalParameters.addAll(m.parameters.where((p) => p.isNamed).map((p) => new Parameter((pb) {
        pb
          ..named = true
          ..name = p.name
          ..type = new Reference(p.type.displayName);
        if (p.defaultValueCode != null) {
          pb.defaultTo = Reference(p.defaultValueCode).code;
        }
      })));

      final blocks = [
        url.assignFinal(_urlVar).statement,
      ];

      if (queries.isNotEmpty) {
        blocks.add(_genereteMap(queries).assignFinal(_parametersVar).statement);
      }

      if (headers != null) {
        blocks.add(headers);
      }

      final hasOptions = options.isNotEmpty;
      if (hasOptions) {
        blocks.add(
          refer(options.keys.first).assignFinal(_options).statement,
        );
      }

      final hasBody = body.isNotEmpty || fields.isNotEmpty;
      if (hasBody) {
        if (body.isNotEmpty) {
          blocks.add(
            refer(body.keys.first).assignFinal(_bodyVar, Reference("Map<String, dynamic>")).statement,
          );
        } else {
          blocks.add(
            _genereteMap(fields).assignFinal(_bodyVar, Reference("Map<String, dynamic>")).statement,
          );
        }
      }

      final hasParts = multipart == true && (parts.isNotEmpty || fileFields.isNotEmpty);
      if (hasParts) {
        //blocks.add(_genereteList(parts, fileFields).assignFinal(_partsVar).statement);
        blocks.add(_genereteMap(parts).assignFinal(_partsVar).statement);
        if (hasBody) {
          blocks.add(refer("$_bodyVar.addAll").call([refer(_partsVar)]).statement);
          blocks.add(refer("FormData.from").call([refer(_bodyVar)]).assignFinal("\$formData").statement);
        } else {
          blocks.add(refer("FormData.from").call([refer(_partsVar)]).assignFinal("\$formData").statement);
        }
      }
      if (hasBody) {
        //$body.removeWhere((k, v) => v == null);
        blocks.add(refer("$_bodyVar.removeWhere").call([refer("(k, v) => v == null")]).statement);
      }
      blocks.add(_generateRequest(method,
              hasBody: hasBody,
              useQueries: queries.isNotEmpty,
              useHeaders: headers != null,
              hasParts: hasParts,
              useOptions: hasOptions)
          .assignFinal(_requestVar)
          .statement);

      final namedArguments = <String, Expression>{};

      final requestFactory = factoryConverter?.peek('request');
      if (requestFactory != null) {
        final el = requestFactory.objectValue.type.element;
        if (el is FunctionTypedElement) {
          namedArguments['requestConverter'] = refer(_factoryForFunction(el));
        }
      }

      final responseFactory = factoryConverter?.peek('response');
      if (responseFactory != null) {
        final el = responseFactory.objectValue.type.element;
        if (el is FunctionTypedElement) {
          namedArguments['responseConverter'] = refer(_factoryForFunction(el));
        }
      }

      if (responseType == null) throw Exception("return type can't be null.");

      var typeArguments = <Reference>[];
      bool isMyResponse = responseType.name == "MyResponse";
      DartType rType = isMyResponse ? _getResponseType(responseType) : responseType;
      if (_isNormalType(rType)) {
        if (!rType.isDynamic) typeArguments.add(refer(rType.displayName));
      } else {
        typeArguments.add(refer("String"));
        //print("$responseType, $rType: ${_mkJsonType(rType)}"); codeTypeSearch
        codeTypeSearch.clear();
        var tt = _mkJsonType(rType).assignFinal("\$mkType");
        codeTypeSearch.forEach((k, v) {
          blocks.addAll(v);
        });
        blocks.add(tt.statement);
      }

      //print(_isNormalType(rType));

      if (!responseType.isDynamic) {
        //print("${responseType.name }--${responseType.displayName}");
//        if (responseType.name == "MyResponse") {
//          //namedArguments['isMyResponse'] = literalBool(true);
//          rType = _getResponseType(responseType);
//          //print("${rType.name }--${rType.displayName}");
//          if (rType != null && responseType.name != responseType.displayName) {
//            typeArguments = _checkType(rType, responseInnerType);
//          }
//        } else {
//          typeArguments = _checkType(responseType, responseInnerType);
//          rType = responseType;
//        }
//        return $send.map((data) {
//          return MyResponse(data.base, fromJson(data.body, $mkType));
//        });
      }
      blocks.add(
        refer(isMyResponse ? "client.sendWarpMyResponse" : "client.send")
            .assignFinal("\$send")
            .call([refer(_requestVar)], namedArguments, typeArguments).statement,
      );

      if (_isNormalType(rType))
        blocks.add(refer("\$send").returned.statement);
      else {
        blocks.add(refer("\$send.map")
            .call([
              (MethodBuilder()
                    ..lambda = true
                    ..requiredParameters.add(Parameter((p) {
                      p.name = "data";
                    }))
                    ..body = Block.of([
                      isMyResponse
                          ? refer("MyResponse").newInstance([
                              refer("data.base"),
                              refer("fromJson").call([refer("data.body"), refer("\$mkType")])
                            ]).code
                          : refer("fromJson").call([refer("data"), refer("\$mkType")]).code
                    ]))
                  .build()
                  .closure
            ])
            .returned
            .statement);
      }

      b.body = new Block.of(blocks);

      //Observable(name().asStream()).map((p) {
      //      Person.fromJson(p.data);
      //    });
      //blocks.add(refer("Observable").call([refer("\$send.asStream").call([])]).assignFinal("\$ob").statement);
      //print(responseType.name);
      //print(responseType.displayName);
      //print(b.name);

//      return $send.map((response) {
//        final list2 = List<Person>();
//        response.body.forEach((f) {
//          list2.add(Person.fromJson(f));
//        });
//        return MyResponse<List<Person>>(response.base, list2);
//      });

//      return $send.map((response) {
//        //final list = (response.body as List);
//        final list2 = List<Person>();
//        response.forEach((f) {
//          list2.add(Person.fromJson(f));
//        });
//        return list2;
//      });

//      return $send.map((re) {
//        String $key1 = "";
//        PersonClassMirror.fields.forEach((k, v) {
//          if (getIsIgnoredFromDeclaration(v)) {
//            $key1 = k;
//          }
//        });
//        String $key2 = "";
//        Person2ClassMirror.fields.forEach((k, v) {
//          if (getIsIgnoredFromDeclaration(v)) {
//            $key2 = k;
//          }
//        });
      //{"name":{"index":1,"name":"mock344444------"}}
//      [Closure: () => Map<String, Person4>, [String, Person4]]
//        //fromJson('{"person1": {"id": 1, "name": "John Doe"}}',
/////                                               [() => Map<String, Person>(), [String, Person]]);
//        //[() => List<Person>(), Person]
//        //Person
//        final $$data = fromJson(re.body,
//            [() => Person<Person2<Person3>>(), {$key1: [() => Person2<Person3>(), {$key2: [() => Person3(), Person3]}]}]);
//        return MyResponse(re.base, $$data);
//      });
      //[String, {a: [Person2<Person3>, {a: [Person3, Person3]}]}]
      //print(_genericOf(_getResponseInnerType(m.returnType)));
      //print(_getResponseInnerType(m.returnType));
//      if (responseInnerType != null &&
//          !responseInnerType.isDynamic &&
//          responseInnerType.name != "Map" &&
//          responseInnerType.name != "List" &&
//          responseInnerType.name != "String" &&
//          responseInnerType.name != "MyResponse") {
//        var mb = MethodBuilder();
//        //mb.lambda = true;
//        mb.requiredParameters.add(Parameter((p) {
//          p.name = "response";
//        }));
//        if (responseType.name == "List") {
//          mb.body = Block.of([
//            //refer("response.data").asA(refer("List")).assignFinal("list").statement,
//            refer("List").newInstance([], {}, [refer(responseInnerType.name)]).assignFinal("list2").statement,
//            refer("response.forEach").call([
//              (MethodBuilder()
//                ..requiredParameters.add(Parameter((p) {
//                  p.name = "f";
//                }))
//                ..body = Block.of([
//                  refer("list2.add").call([
//                    refer("${responseInnerType.displayName}.fromJson").call([refer("f")])
//                  ]).statement
//                ]))
//                  .build()
//                  .closure
//            ]).statement,
//            refer("list2").returned.statement
//          ]);
//        } else if (responseType.name == "MyResponse" && rType?.name == "List") {
//          mb.body = Block.of([
//            //refer("response.data").asA(refer("List")).assignFinal("list").statement,
//            refer("List").newInstance([], {}, [refer(responseInnerType.name)]).assignFinal("list2").statement,
//            refer("response.body.forEach").call([
//              (MethodBuilder()
//                ..requiredParameters.add(Parameter((p) {
//                  p.name = "f";
//                }))
//                ..body = Block.of([
//                  refer("list2.add").call([
//                    refer("${responseInnerType.displayName}.fromJson").call([refer("f")])
//                  ]).statement
//                ]))
//                  .build()
//                  .closure
//            ]).statement,
//            refer("MyResponse")
//                .newInstance([refer("response.base"), refer("list2")], {}, [refer(rType?.displayName)])
//                .returned
//                .statement
//          ]);
//        } else {
////          return $send.map((response) {
////            return Person.fromJson(response);
////          });
//          mb.body = Block.of([
//            refer("${responseInnerType.displayName}.fromJson").call([refer("response")]).returned.statement
//          ]);
//        }
//
//        var re = refer("\$send.map").call([mb.build().closure]);
//        if (responseType.name == "List") {
//          //blocks.add(re.property("toList").call([]).property("asObservable").call([]).returned.statement);
//          blocks.add(re.returned.statement);
//        } else {
//          blocks.add(re.returned.statement);
//        }
//      } else {
//        blocks.add(refer("\$send").returned.statement);
//      }
      //blocks.add(refer("client.send").call([refer(_requestVar)], namedArguments, typeArguments).returned.statement);
    });
  }

  bool _isNormalType(DartType type) {
    //assert(type.name == "MyResponse");
    if (type.name == "MyResponse") throw Exception("Inner type can't be MyResponse");
    if (type.isDynamic || type.displayName == "Map" || type.displayName == "List" || type.displayName == "String") {
      return true;
    }
    return false;
  }

  var codeTypeSearch = Map<String, List<Code>>();

  _mkJsonType(DartType type) {
    //print("_mkJsonType =$type,  $index ${type.name}--${type.displayName}--${(type as InterfaceType).typeArguments}");
    if (type.name == type.displayName) {
      var ts = (type as InterfaceType).typeArguments;
      if (ts != null && ts.length > 0) {
        return literalList([refer("()=>${type.toString()}()"), refer(type.name)]);
      }
      return refer(type.name);
    } else if (type.name == "Map") {
      var ts = [];
      (type as InterfaceType).typeArguments.forEach((t) {
        ts.add(_mkJsonType(t));
      });
      return literalList([refer("()=>${type.displayName}()"), literalList(ts)]);
    } else if (type.name == "List") {
      var t = (type as InterfaceType).typeArguments.first;
      return literalList([refer("()=>${type.displayName}()"), _mkJsonType(t)]);
    } else {
      var tss = (type as InterfaceType).typeArguments;
      //print(tss);
      if (tss.length > 1) {
        var ts = {};
        for (int i = 0; i < tss.length; i++) {
          ts[refer(_mkCodeType(type, i + 1))] = _mkJsonType(tss[i]);
        }
        return literalList([refer("()=>${type.displayName}()"), literalMap(ts)]);
      } else if (tss.length == 1) {
        var name = _mkCodeType(type, 1);
        return literalList([
          refer("()=>${type.displayName}()"),
          literalMap({refer(name): _mkJsonType(tss[0])})
        ]);
      } else {
        return _mkJsonType(type);
      }
    }
  }

  _mkJsonType2(DartType type, int index, DartType p) {
    //print("_mkJsonType =$type,  $index ${type.name}--${type.displayName}--${(type as InterfaceType).typeArguments}");
    if (type.name == type.displayName && index <= 0) {
      var ts = (type as InterfaceType).typeArguments;
      if (ts != null && ts.length > 0) {
        return literalList([refer("()=>${type.toString()}()"), refer(type.name)]);
      }
      return refer(type.name);
    }
    if (type.name == "Map") {
      var ts = [];
      (type as InterfaceType).typeArguments.forEach((t) {
        //if (!t.isDynamic)
        ts.add(_mkJsonType2(t, -1, null));
      });
      return literalList([refer("()=>${type.displayName}()"), literalList(ts)]);
    } else if (type.name == "List") {
      var t = (type as InterfaceType).typeArguments.first;
      return literalList([refer("()=>${type.displayName}()"), _mkJsonType2(t, -1, null)]);
    } else {
      var tss = (type as InterfaceType).typeArguments;
      print(tss);
      var ts = {};
      if (tss.length > 1) {
        for (int i = 0; i < tss.length; i++) {
          print("遍历：$i, ${tss[i]}");
          ts[refer(_mkCodeType(type, i + 1))] = _mkJsonType2(tss[i], -1, null);
          //ts.add(_mkJsonType(tss[i], i+1, type));
        }
      }
      //print("ts:===$tss, $type, $ts $index");
      if (index <= 0) {
        if (tss.length == 0) {
          //print(type.displayName);
          return refer(type.displayName);
        }
        return literalList(
            [refer("()=>${type.displayName}()"), tss.length == 1 ? _mkJsonType2(tss[0], 1, type) : literalMap(ts)]);
      }
      var name = _mkCodeType(p, index);
      print("name====$p, $index");
      // [() => Person<Person2<Person3>>(), {$key1: [() => Person2<Person3>(), {$key2: [() => Person3(), Person3]}]}]
      if (tss.length == 0) {
        return literalMap({
          //refer("()=>${type.displayName}()")
          refer(name): literalList([refer("()=>${type.displayName}()"), refer(type.name)])
        });
      }
      return literalMap({
        refer(name): literalList(
            [refer("()=>${type.displayName}()"), tss.length == 1 ? _mkJsonType2(tss[0], 1, type) : literalMap(ts)])
      });
    }
  }

  String _mkCodeType(DartType p, int index) {
    var key = "${p.name}ClassMirror";
    var name = "\$key${p.name}$index";
    if (!codeTypeSearch.containsKey("$key-$index")) {
      codeTypeSearch["$key-$index"] = <Code>[
        refer("\"\"").assignVar(name).statement,
        refer("$key.fields.forEach").call([
          (MethodBuilder()
                ..requiredParameters.addAll([
                  Parameter((p) {
                    p.name = "k";
                  }),
                  Parameter((p) {
                    p.name = "v";
                  })
                ])
                ..body = Block.of([
                  refer('''
                  if(v.annotations?.any((a) => (a is AnT && a.index == $index)) ?? false) {
                    $name = k;
                  }
                  ''').code
                ]))
              .build()
              .closure
        ]).statement,
      ];
    }
    return name;
  }

  _mke(type) {
    print("JsonParse: type = $type");
    if (type is List) {}
  }

  List<Reference> _checkType(DartType rType, DartType responseInnerType) {
    final typeArguments = <Reference>[];
    if (!responseInnerType.isDynamic &&
        responseInnerType.name != "Map" &&
        responseInnerType.name != "List" &&
        responseInnerType.name != "String" &&
        responseInnerType.name != "MyResponse") {
      if (rType == responseInnerType) {
        typeArguments.add(refer("Map"));
      } else {
        typeArguments.add(refer(rType.name));
      }
    } else {
      typeArguments.add(refer(rType.displayName));
    }
    typeArguments.add(refer(responseInnerType.displayName));
    return typeArguments;
  }

  String _factoryForFunction(FunctionTypedElement function) {
    if (function.enclosingElement is ClassElement) {
      return '${function.enclosingElement.name}.${function.name}';
    }
    return function.name;
  }

  Map<String, ConstantReader> _getAnnotation(MethodElement m, Type type) {
    var annot;
    String name;
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (annot != null && a != null) {
        throw new Exception("Too many $type annotation for '${m.displayName}");
      } else if (annot == null && a != null) {
        annot = a;
        name = p.displayName;
      }
    }
    if (annot == null) return {};
    return {name: new ConstantReader(annot)};
  }

  Map<ParameterElement, ConstantReader> _getAnnotations(MethodElement m, Type type) {
    var annot = <ParameterElement, ConstantReader>{};
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (a != null) {
        annot[p] = new ConstantReader(a);
      }
    }
    return annot;
  }

  TypeChecker _typeChecker(Type type) => new TypeChecker.fromRuntime(type);

  ConstantReader _getMethodAnnotation(MethodElement method) {
    for (final type in _methodsAnnotations) {
      final annot = _typeChecker(type).firstAnnotationOf(method, throwOnUnresolved: false);
      if (annot != null) return new ConstantReader(annot);
    }
    return null;
  }

  ConstantReader _getFactoryConverterAnotation(MethodElement method) {
    final annot = _typeChecker(chopper.FactoryConverter).firstAnnotationOf(method, throwOnUnresolved: false);
    if (annot != null) return new ConstantReader(annot);
    return null;
  }

  bool _hasAnnotation(MethodElement method, Type type) {
    final annot = _typeChecker(type).firstAnnotationOf(method, throwOnUnresolved: false);

    return annot != null;
  }

  final _methodsAnnotations = const [
    chopper.Get,
    chopper.Post,
    chopper.Delete,
    chopper.Put,
    chopper.Patch,
    chopper.Method
  ];

  DartType _genericOf(DartType type) {
    return type is InterfaceType && type.typeArguments.isNotEmpty ? type.typeArguments.first : null;
  }

  DartType _getResponseType(DartType type) {
    return _genericOf(type);
  }

//  DartType _getResponseInnerType(DartType type) {
//    final generic = _genericOf(type);
//
//    if (generic == null || _typeChecker(Map).isExactlyType(type) || _typeChecker(BuiltMap).isExactlyType(type))
//      return type;
//
//    if (generic.isDynamic) return null;
//
//    if (_typeChecker(List).isExactlyType(type) || _typeChecker(BuiltList).isExactlyType(type)) return generic;
//
//    return _getResponseInnerType(generic);
//  }

  DartType _getResponseInnerType(DartType type) {
    final generic = _genericOf(type);

    if (generic == null || _typeChecker(Map).isExactlyType(type) || _typeChecker(BuiltMap).isExactlyType(type))
      return type;

    if (generic.isDynamic) return null;

    if (_typeChecker(List).isExactlyType(type) || _typeChecker(BuiltList).isExactlyType(type)) return generic;

    return _getResponseInnerType(generic);
  }

  Expression _generateUrl(
    ConstantReader method,
    Map<ParameterElement, ConstantReader> paths,
    String baseUrl,
  ) {
    String value = "${method.read("path").stringValue}";
    paths.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      value = value.replaceFirst("{$name}", "\$${p.displayName}");
    });

    if (value.startsWith('http://') || value.startsWith('https://')) {
      // if the request's url is already a fully qualified URL, we can use
      // as-is and ignore the baseUrl
      return literal(value);
    } else {
      if (!baseUrl.endsWith('/') && !value.startsWith('/') && value != "") {
        return literal('$baseUrl/$value');
      }

      return literal('$baseUrl$value');
    }
  }

  Expression _generateRequest(
    ConstantReader method, {
    bool hasBody: false,
    bool hasParts: false,
    bool useQueries: false,
    bool useHeaders: false,
    bool useOptions: false,
  }) {
    final params = <Expression>[
      literal(method.peek("method").stringValue),
      refer(_urlVar),
      refer('$_clientVar.$_baseUrlVar'),
    ];

    final namedParams = <String, Expression>{};

    if (hasBody || hasParts) {
      //$_formData
      namedParams['body'] = hasParts ? refer("\$formData") : refer(_bodyVar);
    }

    if (hasParts) {
      //namedParams['parts'] = refer(_partsVar);
      //namedParams['multipart'] = literalBool(true);
    }

    if (useQueries) {
      namedParams["parameters"] = refer(_parametersVar);
    }

    if (useHeaders) {
      namedParams["headers"] = refer(_headersVar);
    }

    if (useOptions) {
      namedParams["options"] = refer(_options);
    }

    //namedParams["options"] = refer("options");

    return refer("Request").newInstance(params, namedParams);
  }

  Expression _genereteMap(Map<ParameterElement, ConstantReader> queries) {
    final map = {};
    queries.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      map[literal(name)] = refer(p.displayName);
    });

    return literalMap(map);
  }

  Expression _genereteList(
    Map<ParameterElement, ConstantReader> parts,
    Map<ParameterElement, ConstantReader> fileFields,
  ) {
    final list = [];
    parts.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      final params = <Expression>[
        literal(name),
        refer(p.displayName),
      ];

      list.add(refer('PartValue<${p.type.displayName}>').newInstance(params));
    });
    fileFields.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      final params = <Expression>[
        literal(name),
        refer(p.displayName),
      ];

      list.add(refer('PartFile<${p.type.displayName}>').newInstance(params));
    });
    return literalList(list);
  }

  Code _generateHeaders(MethodElement m, ConstantReader method) {
    final map = {};

    final annotations = _getAnnotations(m, chopper.Header);

    annotations.forEach((p, ConstantReader r) {
      final name = r.peek("name")?.stringValue ?? p.displayName;
      map[literal(name)] = refer(p.displayName);
    });

    final methodAnnotations = method.peek("headers").mapValue;

    methodAnnotations.forEach((k, v) {
      map[literal(k.toStringValue())] = literal(v.toStringValue());
    });

    if (map.isEmpty) {
      return null;
    }

    return literalMap(map).assignFinal(_headersVar).statement;
  }
}

Builder chopperGeneratorFactoryBuilder({String header}) => new PartBuilder(
      [new ChopperGenerator()],
      ".okdio.dart",
      header: header,
    );
