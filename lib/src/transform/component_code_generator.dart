import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _code = """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core_main/apis/style/style_registry.dart';
import 'abstract_repository_singleton.dart';
import 'package:eliud_core_main/widgets/alert_widget.dart';
import 'package:eliud_core_main/tools/main_abstract_repository_singleton.dart';
import 'package:eliud_core_main/model/app_model.dart';

/*
 * Abstract\${id}Component is the base class to extend / implement in case you need to implement a component
 */
abstract class Abstract\${id}Component extends StatelessWidget {
  static String componentName = "\${lid}s";
  final AppModel app;
  final String \${lid}Id;

  /*
   * Construct Abstract\${id}Component
   */
  Abstract\${id}Component({Key? key, required this.app, required this.\${lid}Id}): super(key: key);

  /*
   * build the component
   */
  @override
  Widget build(BuildContext context) {
    return BlocProvider<\${id}ComponentBloc> (
          create: (context) => \${id}ComponentBloc(
            \${lid}Repository: \${lid}Repository(appId: app.documentID)!)
        ..add(Fetch\${id}Component(id: \${lid}Id)),
      child: _\${lid}BlockBuilder(context),
    );
  }

  Widget _\${lid}BlockBuilder(BuildContext context) {
    return BlocBuilder<\${id}ComponentBloc, \${id}ComponentState>(builder: (context, state) {
      if (state is \${id}ComponentLoaded) {
        return yourWidget(context, state.value);
      } else if (state is \${id}ComponentPermissionDenied) {
        return Icon(
          Icons.highlight_off,
          color: Colors.red,
          size: 30.0,
        );
      } else if (state is \${id}ComponentError) {
        return AlertWidget(app: app, title: 'Error', content: state.message);
      } else {
        return Center(
          child: StyleRegistry.registry().styleWithApp(app).frontEndStyle().progressIndicatorStyle().progressIndicator(app, context),
        );
      }
    });
  }

  /*
   * Implement this method to provide your widget
   */
  Widget yourWidget(BuildContext context, \${id}Model value);
}
""";

class ComponentCodeGenerator extends CodeGenerator {
  ComponentCodeGenerator({required super.modelSpecifications});

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();

    headerBuffer.writeln();
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.componentBlocFileName()}"));
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.componentEventFileName()}"));
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.modelFileName()}"));
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.repositoryFileName()}"));
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.componentStateFileName()}"));

    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_code, parameters: <String, String>{
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
