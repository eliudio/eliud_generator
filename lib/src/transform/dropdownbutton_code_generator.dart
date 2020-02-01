import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _imports = """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:cached_network_image/cached_network_image.dart';

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

\${childCode}

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
        DropdownButton button = 
                    DropdownButton<String>(
                      isDense: false,
                      isExpanded: \${withImages},
                      items: state.values.isNotEmpty
                          ? state.values.map((\${id}Model pm) => DropdownMenuItem(value: pm.documentID, 
                            child: 
                              new Container(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                height: 100.0,
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: widgets(pm),
                                ),
                              )
                            )).toList()
                          : const [],
                      value: valueChosen,
                      hint: Text('Select a \${lid}'),
                      onChanged: _onChange,
                    );
        if (\${withImages}) {
          return Container(height:48, child: Center(child: button));
        } else {
          return Center(child: button);
        }
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

const _imageString = """
  Center(
    child: CachedNetworkImage(
      placeholder: (context, url) => CircularProgressIndicator(),
      imageUrl:pm.\${fieldName},
    ),
  )
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
    StringBuffer childCodeBuffer = StringBuffer();

    childCodeBuffer.writeln("List<Widget> widgets(" + modelSpecifications.id + "Model pm) {");
    childCodeBuffer.writeln("List<Widget> widgets = List();");
    childCodeBuffer.write("if (pm." + modelSpecifications.listFields.title + " != null) ");
    childCodeBuffer.write("widgets.add(");
    if (modelSpecifications.listFields.imageTitle) {
      childCodeBuffer.write(process(_imageString, parameters: <String, String> { '\${fieldName}': modelSpecifications.listFields.title }));
    } else {
      childCodeBuffer.write("new Text(pm." + modelSpecifications.listFields.title + ")");
    }
    childCodeBuffer.writeln(");");
    childCodeBuffer.write("if (pm." + modelSpecifications.listFields.subTitle + " != null) ");
    childCodeBuffer.write("widgets.add(");
    if (modelSpecifications.listFields.imageSubTitle) {
      childCodeBuffer.write(process(_imageString, parameters: <String, String> { '\${fieldName}': modelSpecifications.listFields.subTitle }));
    } else {
      childCodeBuffer.write("new Text(pm."  + modelSpecifications.listFields.subTitle + ")");
    }
    childCodeBuffer.writeln(");");
    childCodeBuffer.writeln("return widgets;");
    childCodeBuffer.writeln("}");
    codeBuffer.writeln(process(_code,
        parameters: <String, String> {
          '\${id}': modelSpecifications.id,
          '\${lid}': firstLowerCase(modelSpecifications.id),
          '\${childCode}' : childCodeBuffer.toString(),
          "\${withImages}": modelSpecifications.listFields.hasImage().toString()
        }));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listFileName();
  }
}
