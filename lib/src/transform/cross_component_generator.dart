import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator_multi.dart';

const String _imports = """
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'internal_component.dart';

""";

const String _code = """
typedef Changed(String value);

class CrossComponent extends StatelessWidget {
  static const List<String> extensions = [ \${extensions} ];
  final String extension;
  final String value;
  final Changed trigger;

  const CrossComponent({Key key, this.extension, this.value, this.trigger}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value == null) return null;
    if (value == "internalWidget") {
      var dropDownItems = allInternalComponents
          .map((widgetName) => new DropdownMenuItem(value: widgetName, child: new Text(widgetName)))
          .toList();

      String choice;
      if (allInternalComponents.indexWhere((widgetName) => (widgetName == value)) >= 0)
        choice = value;

      return new DropdownButton(
          value: value,
          items: dropDownItems,
          hint: Text("Select internal widget"),
          onChanged: trigger);
    } else {
      return DropdownButtonComponentFactory().createNew(
          id: extension, value: value, trigger: trigger);
    }
  }
}

""";

class CrossComponentCodeGenerator extends CodeGeneratorMulti {
  CrossComponentCodeGenerator(String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());
    codeBuffer.writeln(process(_imports));
    StringBuffer extensions = StringBuffer();
    modelSpecificationPlus.forEach((spec) {
      if (spec.modelSpecification.generate.isExtension()) {
        extensions.write("\"" + spec.modelSpecification.id + "\", ");
      }
    });
    extensions.write("\"internalWidget\"");
    codeBuffer.writeln(process(_code, parameters: <String, String> { "\${extensions}": extensions.toString()}));
    return codeBuffer.toString();

  }
}
