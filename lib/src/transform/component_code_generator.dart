import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _code = """
abstract class Abstract\${id}Component extends StatelessWidget {
  static String componentName = "\${lid}s";
  final String? \${lid}ID;

  Abstract\${id}Component({this.\${lid}ID});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<\${id}ComponentBloc> (
          create: (context) => \${id}ComponentBloc(
            \${lid}Repository: get\${id}Repository(context))
        ..add(Fetch\${id}Component(id: \${lid}ID)),
      child: _\${lid}BlockBuilder(context),
    );
  }

  Widget _\${lid}BlockBuilder(BuildContext context) {
    return BlocBuilder<\${id}ComponentBloc, \${id}ComponentState>(builder: (context, state) {
      if (state is \${id}ComponentLoaded) {
        if (state.value == null) {
          return alertWidget(title: 'Error', content: 'No \${id} defined');
        } else {
          return yourWidget(context, state.value);
        }
      } else if (state is \${id}ComponentPermissionDenied) {
        return Icon(
          Icons.highlight_off,
          color: Colors.red,
          size: 30.0,
        );
      } else if (state is \${id}ComponentError) {
        return alertWidget(title: 'Error', content: state.message);
      } else {
        return Center(
          child: StyleRegistry.registry().styleWithContext(context).frontEndStyle().progressIndicatorStyle().progressIndicator(context),
        );
      }
    });
  }

  Widget yourWidget(BuildContext context, \${id}Model? value);
  Widget alertWidget({ title: String, content: String});
  \${id}Repository get\${id}Repository(BuildContext context);
}
""";

class ComponentCodeGenerator extends CodeGenerator {
  ComponentCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln("import 'package:eliud_core/style/style_registry.dart';");
    headerBuffer.writeln();
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.componentBlocFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.componentEventFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.modelFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.repositoryFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.componentStateFileName()));

    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_code,
        parameters: <String, String> {
          '\${id}': modelSpecifications.id,
          '\${lid}': firstLowerCase(modelSpecifications.id),
        }));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.componentFileName();
  }
}
