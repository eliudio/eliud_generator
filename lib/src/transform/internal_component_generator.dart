import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator_multi.dart';

class InternalComponentCodeGenerator extends CodeGeneratorMulti {
  InternalComponentCodeGenerator(String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());
    codeBuffer.writeln("import '../shared/repository_singleton.dart';");
    codeBuffer.writeln();
    codeBuffer.writeln("import 'component_constructor.dart';");
    codeBuffer.writeln();
    codeBuffer.writeln("import 'package:flutter/material.dart';");
    codeBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    codeBuffer.writeln();

    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        codeBuffer.writeln("import '../" + spec.path + ".list.bloc.dart';");
        codeBuffer.writeln("import '../" + spec.path + ".list.dart';");
        codeBuffer.writeln("import '../" + spec.path + ".list.event.dart';");
        codeBuffer.writeln();
      }
    });

    codeBuffer.writeln("class InternalComponentFactory implements ComponentConstructor {");
    codeBuffer.writeln(spaces(2) + "Widget createNew({String id}) {");
    codeBuffer.writeln(spaces(4) + "return InternalComponent(componentId: id);");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    codeBuffer.writeln("class InternalComponent extends StatelessWidget {");
    codeBuffer.writeln(spaces(2) + "final String componentId;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "InternalComponent({this.componentId});");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
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
        codeBuffer.writeln(spaces(2) + "Widget _" + firstLowerCase(ms.id) + "Build() {");
        codeBuffer.writeln(spaces(4) + "return MultiBlocProvider(");
        codeBuffer.writeln(spaces(6) + "providers: [");
        codeBuffer.writeln(spaces(8) + "BlocProvider<" + ms.id + "ListBloc>(");
        codeBuffer.writeln(spaces(10) + "create: (context) => " + ms.id + "ListBloc(");
        codeBuffer.writeln(spaces(12) + firstLowerCase(ms.id) + "Repository: RepositorySingleton." + firstLowerCase(ms.id) + "Repository,");
        codeBuffer.writeln(spaces(10) + ")..add(Load" + ms.id + "List()),");
        codeBuffer.writeln(spaces(8) + ")");
        codeBuffer.writeln(spaces(6) + "],");
        codeBuffer.writeln(spaces(6) + "child: " + ms.id + "ListWidget(),");
        codeBuffer.writeln(spaces(4) + ");");
        codeBuffer.writeln(spaces(2) + "}");
        codeBuffer.writeln();
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("}");
    return codeBuffer.toString();

  }
}
