import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _imports = """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

""";

const String _specificImports = """
import '\${path}.list.bloc.dart';
import '\${path}.list.state.dart';
import '\${path}.model.dart';

""";

const String _code = """
typedef \${id}Changed(String value);

class \${id}DropdownButtonWidget extends StatelessWidget {
  final String value;
  final \${id}Changed trigger;

  \${id}DropdownButtonWidget({ this.value, this.trigger, Key key }): super(key: key);

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<\${id}ListBloc, \${id}ListState>(builder: (context, state) {
      if (state is \${id}ListLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is \${id}ListLoaded) {
        String valueChosen;
        if (state.values.indexWhere((v) => (v.documentID == value)) >= 0)
          valueChosen = value;

        final values = state.values;
        return DropdownButton<String>(
            items: state.values.isNotEmpty
                ? state.values.map((\${id}Model pm) => DropdownMenuItem(value: pm.documentID, child: Text(pm.documentID))).toList()
                : const [],
            value: valueChosen,
            hint: Text('Select a \${lid}'),
            onChanged: _onChange,
          );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    });
  }

  void _onChange(String value) {
    trigger(value);
  }
}
""";

class DropdownButtonCodeGenerator extends CodeGenerator {
  DropdownButtonCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(process(_imports));
    headerBuffer.writeln(process(_specificImports, parameters: <String, String> { '\${path}': camelcaseToUnderscore(modelSpecifications.id) }));
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_code, parameters: <String, String> { '\${id}': modelSpecifications.id, '\${lid}': firstLowerCase(modelSpecifications.id) }));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listFileName();
  }
}
