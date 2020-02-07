import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

const String _imports = """
import 'dart:collection';
import 'package:flutter/material.dart';

import 'dart:collection';
import 'package:flutter/material.dart';

import '../auth/authentication_bloc/authentication_bloc.dart';
import '../auth/user_repository.dart';
import '../core/components/application_component.dart';
import '../core/components/page_component.dart';

import '../shared/component_constructor.dart';
import '../shared/internal_component.dart';

\${import}

""";

const String _code = """
class ComponentRegistry {
  final Map<String, ComponentConstructor> _registryMap = new HashMap();
  PageComponentConstructor _pageComponentConstructor;
  ApplicationComponentConstructor _applicationComponentConstructor;

  static ComponentRegistry _instance;

  ComponentRegistry._internal() {
    _init();
  }

  static ComponentRegistry registry() {
    if (_instance == null) {
      _instance = ComponentRegistry._internal();
    }

    return _instance;
  }

  Widget page({String id}) {
    Widget returnThis;
    try {
      returnThis = _pageComponentConstructor.createNew(id: id);
    } catch (_) {}
    if (returnThis != null) return returnThis;
    return _missingPage();
  }

  Widget application({String id}) {
    return _applicationComponentConstructor.createNew(id: id);
  }

  Widget component({String componentName, String id}) {
    Widget returnThis;
    try {
      ComponentConstructor componentConstructor = _registryMap[componentName];
      if (componentConstructor != null)
        returnThis = componentConstructor.createNew(id: id);
    } catch (_) {}
    if (returnThis != null) return returnThis;
    return _missingComponent();
  }

  Widget _missingComponent() {
    try {
      return Image(
          image: AssetImage('assets/images/component_not_available.png'));
    } catch (_) {
      return null;
    }
  }

  Widget _missingPage() {
    try {
      return Image(image: AssetImage('assets/images/page_not_available.png'));
    } catch (_) {
      return null;
    }
  }

  void register(
      {String componentName, ComponentConstructor componentConstructor}) {
    _registryMap[componentName] = componentConstructor;
  }

  void initialize(
      {ComponentConstructor pageComponentConstructor,
        ComponentConstructor applicationComponentConstructor}) {
    _pageComponentConstructor = pageComponentConstructor;
    _applicationComponentConstructor = applicationComponentConstructor;
  }

  void _init() {
    final GlobalKey<NavigatorState> navigatorKey =
    new GlobalKey<NavigatorState>();
    final UserRepository userRepository = UserRepository();
    AuthenticationBloc authenticationBloc =
    AuthenticationBloc(userRepository: userRepository);
    initialize(
      pageComponentConstructor: PageComponentConstructorDefault(
          navigatorKey: navigatorKey, authenticationBloc: authenticationBloc),
      applicationComponentConstructor: ApplicationComponentConstructorDefault(
          navigatorKey: navigatorKey,
          authenticationBloc: authenticationBloc,
          userRepository: userRepository),
    );
    
    \${register}
  }
}

""";

class ComponentRegistryGenerator extends CodeGeneratorMulti {
  ComponentRegistryGenerator(String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());

    StringBuffer _import = StringBuffer();
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.isExtension) {
        _import.writeln("import '../extensions/" + camelcaseToUnderscore(spec.modelSpecification.id) + "_component.dart';");
      }
    });
    codeBuffer.writeln(process(_imports, parameters: <String, String> { '\${import}': _import.toString() }));
    StringBuffer register = StringBuffer();
    register .writeln("register(componentName: \"internalWidgets\", componentConstructor: ListComponentFactory());");
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.isExtension) {
        register .writeln("register(componentName: \"" + firstLowerCase(spec.modelSpecification.id) + "s\", componentConstructor: " + spec.modelSpecification.id + "ComponentConstructorDefault());");
      }
    });
    codeBuffer.writeln(process(_code, parameters: <String, String> { '\${register}': register.toString() }));
    return codeBuffer.toString();

  }
}
