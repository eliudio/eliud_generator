import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _imports(String packageName) => """
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/package/packages.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/style/frontend/has_text.dart';

""";

String _specificImports(String packageName) => """
import 'package:$packageName/model/\${path}_list_bloc.dart';
import 'package:$packageName/model/\${path}_list_state.dart';
import 'package:$packageName/model/\${path}_model.dart';

""";

const String _code = """
typedef \${id}Changed(String? value);

class \${id}DropdownButtonWidget extends StatefulWidget {
  final AppModel app;
  final String? value;
  final \${id}Changed? trigger;
  final bool? optional;

  \${id}DropdownButtonWidget({ required this.app, this.value, this.trigger, this.optional, Key? key }): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return \${id}DropdownButtonWidgetState();
  }
}

class \${id}DropdownButtonWidgetState extends State<\${id}DropdownButtonWidget> {
  \${id}ListBloc? bloc;

  \${id}DropdownButtonWidgetState();

  @override
  void didChangeDependencies() {
    bloc = BlocProvider.of<\${id}ListBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (bloc != null) bloc!.close();
    super.dispose();
  }

\${childCode}

  @override
  Widget build(BuildContext context) {
    var accessState = AccessBloc.getState(context);
    return BlocBuilder<\${id}ListBloc, \${id}ListState>(builder: (context, state) {
      if (state is \${id}ListLoading) {
        return StyleRegistry.registry().styleWithApp(widget.app).adminListStyle().progressIndicator(widget.app, context);
      } else if (state is \${id}ListLoaded) {
        String? valueChosen;
        if (state.values!.indexWhere((v) => (v!.documentID == widget.value)) >= 0)
          valueChosen = widget.value;
        else
          if (widget.optional != null && widget.optional!) valueChosen = null;
          
        final values = state.values;
        final items = <DropdownMenuItem<String>>[];
        if (state.values!.isNotEmpty) {
          if (widget.optional != null && widget.optional!) {
            items.add(new DropdownMenuItem<String>(
                value: null,
                child: new Container(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  height: 100.0,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget> [ new Text("None") ],
                  ),
                )));
          }
          state.values!.forEach((element) {
            items.add(new DropdownMenuItem<String>(
                value: element!.documentID,
                child: new Container(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  height: 100.0,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widgets(element),
                  ),
                )));
          });
        }
        DropdownButton button = 
                    DropdownButton<String>(
                      isDense: false,
                      isExpanded: \${withImages},
                      items: items,
                      value: valueChosen,
                      hint: text(widget.app, context, 'Select a \${lid}'),
                      onChanged: !accessState.memberIsOwner(widget.app.documentID!) ? null : _onChange,
                    );
        if (\${withImages}) {
          return Container(height:48, child: button);
        } else {
          return button;
        }
      } else {
        return StyleRegistry.registry().styleWithApp(widget.app).adminListStyle().progressIndicator(widget.app, context);
      }
    });
  }

  void _onChange(String? value) {
    widget.trigger!(value);
  }
}
""";

const _imageString = """
  Center(
    // This causes the app to crash
    // child: AbstractPlatform.platform.getThumbnail(image:pm)
    // Alternative for now...
    child: Image.network(pm.imageURLThumbnail,)
  )
""";

class DropdownButtonCodeGenerator extends CodeGenerator {
  DropdownButtonCodeGenerator ({required ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(process(_imports(modelSpecifications.packageName)));
    headerBuffer.writeln(process(_specificImports(modelSpecifications.packageName), parameters: <String, String> { '\${path}': camelcaseToUnderscore(modelSpecifications.id) }));
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    StringBuffer childCodeBuffer = StringBuffer();

/*
    childCodeBuffer.writeln("List<Widget> widgets(" + modelSpecifications.id + "Model pm) {");
    childCodeBuffer.writeln("var widgets = <Widget>[];");
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
*/

    childCodeBuffer.writeln("List<Widget> widgets(" + modelSpecifications.id + "Model value) {");
    childCodeBuffer.writeln("var app = widget.app;");
    childCodeBuffer.writeln("var widgets = <Widget>[];");
    String? title = modelSpecifications.listFields.title;
    if (title != null) {
      childCodeBuffer.writeln("widgets.add($title);");
    }
    String? subTitle = modelSpecifications.listFields.subTitle;
    if (subTitle != null) {
      childCodeBuffer.writeln("widgets.add($subTitle);");
    }
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
