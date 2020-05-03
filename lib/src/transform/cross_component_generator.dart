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

class CrossComponent extends StatefulWidget {
  final String extension;
  String value;
  final Changed trigger;

  CrossComponent({this.extension, this.value, this.trigger});

  @override
  State<StatefulWidget> createState() {
    return new CrossComponentState();
  }
}

class CrossComponentState extends State<CrossComponent> {

  CrossComponentState();

  @override
  Widget build(BuildContext context) {
    if ((widget.extension == null) || (widget.extension == ""))
      return Container(
        color: Colors.white
      );
    if (widget.extension == "internalWidgets") {
      var dropDownItems = allInternalComponents
          .map((widgetName) => new DropdownMenuItem(value: widgetName, child: new Text(widgetName)))
          .toList();

      String choice;
      if (allInternalComponents.indexWhere((widgetName) => (widgetName == widget.value)) >= 0)
        choice = widget.value;

      return Center(child: new DropdownButton(
          value: choice,
          items: dropDownItems,
          hint: Text("Select internal widget"),
          onChanged: widget.trigger));
    } else {
      Widget selection = DropdownButtonComponentFactory().createNew(
          id: widget.extension, value: widget.value, trigger: widget.trigger);
      if (selection == null) {
        widget.value = null;
        widget.trigger(null);
        return Text("No selection available");
      }
      else return selection;
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
    codeBuffer.writeln(process(_code));
    return codeBuffer.toString();

  }
}
