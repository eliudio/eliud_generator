import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator_multi.dart';

const String _imports = """
import '../shared/repository_singleton.dart';

import 'component_constructor.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
""";

const String _componentImports = """
import '../\${path}.list.bloc.dart';
import '../\${path}.list.dart';
import '../\${path}.dropdown_button.dart';
import '../\${path}.list.event.dart';

""";

const String _ListFactoryCode = """
class ListComponentFactory implements ComponentConstructor {
  Widget createNew({String id}) {
    return ListComponent(componentId: id);
  }
}

""";

const String _DropdownButtonFactoryCode = """
typedef DropdownButtonChanged(String value);

class DropdownButtonComponentFactory implements ComponentConstructor {
  Widget createNew({String id, String value, DropdownButtonChanged trigger}) {
    return DropdownButtonComponent(componentId: id, value: value, trigger: trigger);
  }
}

""";

const String _ListComponentCodeHeader = """
class ListComponent extends StatelessWidget {
  final String componentId;

  ListComponent({this.componentId});

  @override
  Widget build(BuildContext context) {
""";

const String _DropdownButtonComponentCodeHeader = """
typedef Changed(String value);

class DropdownButtonComponent extends StatelessWidget {
  final String componentId;
  final String value;
  final Changed trigger;

  DropdownButtonComponent({this.componentId, this.value, this.trigger});

  @override
  Widget build(BuildContext context) {
""";


const String _SpecificListComponentCode = """
  Widget _\${lowerSpecific}Build() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<\${upperSpecific}ListBloc>(
          create: (context) => \${upperSpecific}ListBloc(
            \${lowerSpecific}Repository: RepositorySingleton.\${lowerSpecific}Repository,
          )..add(Load\${upperSpecific}List()),
        )
      ],
      child: \${upperSpecific}ListWidget(),
    );
  }
""";

const String _SpecificDropdownButtonComponentCode = """
  Widget _\${lowerSpecific}Build() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<\${upperSpecific}ListBloc>(
          create: (context) => \${upperSpecific}ListBloc(
            \${lowerSpecific}Repository: RepositorySingleton.\${lowerSpecific}Repository,
          )..add(Load\${upperSpecific}List()),
        )
      ],
      child: \${upperSpecific}DropdownButtonWidget(value: value, trigger: trigger, ),
    );
  }
""";

const String _SpecificCodeFooter = """
}
""";

class InternalComponentCodeGenerator extends CodeGeneratorMulti {
  InternalComponentCodeGenerator(String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());
    codeBuffer.writeln(process(_imports));

    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        codeBuffer.writeln(process(_componentImports, parameters: <String, String> { "\${path}": spec.path }));
      }
    });

    codeBuffer.writeln(process(_ListFactoryCode));
    codeBuffer.writeln(process(_DropdownButtonFactoryCode));

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
        codeBuffer.writeln(spaces(4) + "if (componentId == \"" + firstLowerCase(ms.id) + "s\") return _" + firstLowerCase(ms.id) + "Build();");
      }
    });
    codeBuffer.writeln(spaces(4) + "return Image(image: AssetImage('assets/images/component_not_available.png'));");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        if (list)
          codeBuffer.writeln(process(_SpecificListComponentCode, parameters: <String, String> { "\${lowerSpecific}": firstLowerCase(ms.id), "\${upperSpecific}": ms.id }));
        else
          codeBuffer.writeln(process(_SpecificDropdownButtonComponentCode, parameters: <String, String> { "\${lowerSpecific}": firstLowerCase(ms.id), "\${upperSpecific}": ms.id }));
      }
    });
    codeBuffer.writeln(process(_SpecificCodeFooter));
    return codeBuffer.toString();
  }
}
