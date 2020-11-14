import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

String _imports = """
import 'package:eliud_core/tools/component_constructor.dart';
import 'package:eliud_core/core/app/app_bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eliud_core/tools/has_fab.dart';

""";

String _componentImports(String packageName, List<String> depends) => """
import 'package:$packageName/\${path}_list_bloc.dart';
import 'package:$packageName/\${path}_list.dart';
import 'package:$packageName/\${path}_dropdown_button.dart';
import 'package:$packageName/\${path}_list_event.dart';

""" + base_imports(packageName, repo: true, model: true, entity: true, depends: depends);

const String _ListFactoryCode = """
class ListComponentFactory implements ComponentConstructor {
  Widget createNew({String id, Map<String, String> parameters}) {
    return ListComponent(componentId: id);
  }
}

""";

const String _DropdownButtonFactoryCodeHeader = """
typedef DropdownButtonChanged(String value);

class DropdownButtonComponentFactory implements ComponentDropDown {
""";

const String _DropdownButtonSupportMethod = """
  bool supports(String id) {
""";

const String _DropdownButtonSupportMethodFooter = """
    return false;
  }
""";

const String _DropdownButtonFactoryCodeMethod = """
  Widget createNew({String id, Map<String, String> parameters, String value, DropdownButtonChanged trigger, bool optional}) {
""";

const String _DropdownButtonFactoryCodeComponent = """
      return DropdownButtonComponent(componentId: id, value: value, trigger: trigger, optional: optional);
""";

const String _DropdownButtonFactoryCodeFooter = """
    return null;
  }
}

""";

const String _ListComponentCodeHeader = """
class ListComponent extends StatelessWidget with HasFab {
  final String componentId;
  Widget widget;

  @override
  Widget fab(BuildContext context){
    if ((widget != null) && (widget is HasFab)) {
      HasFab hasFab = widget as HasFab;
      return hasFab.fab(context);
    }
    return null;
  }

  ListComponent({this.componentId}) {
    initWidget();
  }

  @override
  Widget build(BuildContext context) {
""";

const String _DropdownButtonComponentCodeHeader = """
typedef Changed(String value);

class DropdownButtonComponent extends StatelessWidget {
  final String componentId;
  final String value;
  final Changed trigger;
  final bool optional;

  DropdownButtonComponent({this.componentId, this.value, this.trigger, this.optional});

  @override
  Widget build(BuildContext context) {
""";

const String _SpecificListComponentCode = """
  Widget _\${lowerSpecific}Build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<\${upperSpecific}ListBloc>(
          create: (context) => \${upperSpecific}ListBloc(
            \${lowerSpecific}Repository: \${lowerSpecific}Repository(\${appIdVar}),
          )..add(Load\${upperSpecific}List()),
        )
      ],
      child: widget,
    );
  }
""";

const String _SpecificDropdownButtonComponentCode = """
  Widget _\${lowerSpecific}Build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<\${upperSpecific}ListBloc>(
          create: (context) => \${upperSpecific}ListBloc(
            \${lowerSpecific}Repository: \${lowerSpecific}Repository(\${appIdVar}),
          )..add(Load\${upperSpecific}List()),
        )
      ],
      child: \${upperSpecific}DropdownButtonWidget(value: value, trigger: trigger, optional: optional),
    );
  }
""";

const String _SpecificCodeFooter = """
}
""";

class InternalComponentCodeGenerator extends CodeGeneratorMulti {
  InternalComponentCodeGenerator(String fileName) : super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());
    codeBuffer.writeln(process(_imports));

    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        codeBuffer.writeln(process(_componentImports(ms.packageName, ms.depends),
            parameters: <String, String>{"\${path}": spec.path}));
      }
    });

    codeBuffer.writeln(process(_ListFactoryCode));

    codeBuffer.writeln(process(_DropdownButtonFactoryCodeHeader));
    codeBuffer.writeln(process(_DropdownButtonSupportMethod));
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        codeBuffer.writeln(
            spaces(4) + "if (id == \"" + firstLowerCase(ms.id) + "s\") return true;");
      }
    });
    codeBuffer.writeln(process(_DropdownButtonSupportMethodFooter));

    codeBuffer.writeln(process(_DropdownButtonFactoryCodeMethod));
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        codeBuffer.writeln(
            spaces(4) + "if (id == \"" + firstLowerCase(ms.id) + "s\")");
        codeBuffer.writeln(_DropdownButtonFactoryCodeComponent);
      }
    });
    codeBuffer.writeln(process(_DropdownButtonFactoryCodeFooter));

    codeBuffer.writeln(_code(modelSpecificationPlus, true));
    codeBuffer.writeln(_code(modelSpecificationPlus, false));

    return codeBuffer.toString();
  }

  String _code(modelSpecificationPlus, list) {
    StringBuffer codeBuffer = StringBuffer();
    if (list)
      codeBuffer.writeln(process(_ListComponentCodeHeader));
    else
      codeBuffer.writeln(process(_DropdownButtonComponentCodeHeader));
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        codeBuffer.writeln(spaces(4) +
            "if (componentId == '" +
            firstLowerCase(ms.id) +
            "s') return _" +
            firstLowerCase(ms.id) +
            "Build(context);");
      }
    });
    codeBuffer.writeln(spaces(4) +
        "return Text('Component with componentId == \$componentId not found');");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();

    if (list) {
      codeBuffer.writeln(spaces(2) + "Widget initWidget() {");
      modelSpecificationPlus.forEach((spec) {
        ModelSpecification ms = spec.modelSpecification;
        if (ms.generate.generateInternalComponent) {
          codeBuffer.writeln(spaces(4) +
              "if (componentId == '" +
              firstLowerCase(ms.id) +
              "s') widget = " +
              firstUpperCase(ms.id) +
              "ListWidget();");
        }
      });
      codeBuffer.writeln(spaces(2) + "}");
    }

    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      var appIdVar = ms.isAppModel ? "appID: AppBloc.appId(context)" : "";
      if (ms.generate.generateInternalComponent) {
        if (list)
          codeBuffer.writeln(process(_SpecificListComponentCode,
              parameters: <String, String>{
                "\${lowerSpecific}": firstLowerCase(ms.id),
                "\${upperSpecific}": ms.id,
                "\${appIdVar}" : appIdVar,
              }));
        else
          codeBuffer.writeln(process(_SpecificDropdownButtonComponentCode,
              parameters: <String, String>{
                "\${lowerSpecific}": firstLowerCase(ms.id),
                "\${upperSpecific}": ms.id,
                "\${appIdVar}" : appIdVar,
              }));
      }
    });
    codeBuffer.writeln(process(_SpecificCodeFooter));
    return codeBuffer.toString();
  }
}
