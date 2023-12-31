import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _imports(String packageName) => """
import 'package:eliud_core_main/model/app_model.dart';
//import 'package:eliud_core_model/package/packages.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:eliud_core_main/apis/style/style_registry.dart';
import 'package:eliud_core_main/apis/style/frontend/has_text.dart';
import 'package:eliud_core_main/apis/style/frontend/has_button.dart';
import 'package:eliud_core_helpers/query/query_tools.dart';
import 'package:eliud_core_main/tools/component/update_component.dart';

""";

String _specificImports(String packageName) => """
import 'package:$packageName/model/\${path}_list_bloc.dart';
import 'package:$packageName/model/\${path}_list_state.dart';
import 'package:$packageName/model/\${path}_list_event.dart';
import 'package:$packageName/model/\${path}_model.dart';
import 'package:eliud_core_main/apis/style/frontend/has_button.dart';
//import 'package:eliud_core_main/tools/component/update_component.dart';

""";

const String _code = """

typedef \${id}Changed(String? value, int? privilegeLevel,);

/* 
 * \${id}DropdownButtonWidget is the drop down widget to allow to select an instance of \${id}
 */
class \${id}DropdownButtonWidget extends StatefulWidget {
  final AppModel app;
  final int? privilegeLevel;
  final String? value;
  final \${id}Changed? trigger;
  final bool? optional;

  /* 
   * construct a \${id}DropdownButtonWidget
   */
  \${id}DropdownButtonWidget({ required this.app, this.privilegeLevel, this.value, this.trigger, this.optional, Key? key }): super(key: key);

  /* 
   * create state of \${id}DropdownButtonWidget
   */
  @override
  State<StatefulWidget> createState() {
    return _\${id}DropdownButtonWidgetState(value);
  }
}

class _\${id}DropdownButtonWidgetState extends State<\${id}DropdownButtonWidget> {
  \${id}ListBloc? bloc;
  String? value;

  _\${id}DropdownButtonWidgetState(this.value);

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
    //var accessState = AccessBloc.getState(context);
    return BlocBuilder<\${id}ListBloc, \${id}ListState>(builder: (context, state) {
      if (state is \${id}ListLoading) {
        return StyleRegistry.registry().styleWithApp(widget.app).adminListStyle().progressIndicator(widget.app, context);
      } else if (state is \${id}ListLoaded) {
        int? privilegeChosen = widget.privilegeLevel;
        if ((value != null) && (privilegeChosen == null)) {
          if (state.values != null) {
            \${privilegeChosenCode};
          }
        }
          
//        final values = state.values;
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
                    children: _widgets(element),
                  ),
                )));
          });
        }
        return ListView(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            children: [
          dropdownButton<int>(
            widget.app, context,
            isDense: false,
            isExpanded: false,
            items: [
              DropdownMenuItem<int>(
                value: 0,
                child: text(widget.app, context, 'No privilege Required'),
              ),
              DropdownMenuItem<int>(
                value: 1,
                child: text(widget.app, context, 'Level 1 privilege required'),
              ),
              DropdownMenuItem<int>(
                value: 2,
                child: text(widget.app, context, 'Level 2 privilege required'),
              ),
              DropdownMenuItem<int>(
                value: 3,
                child: text(widget.app, context, 'Must be owner'),
              ),
            ],
            value: privilegeChosen,
            hint: text(widget.app, context, 'Select a privilege'),
            onChanged: _onPrivilegeLevelChange,
          ),
          Row(children: [((\${withImages}) == true)
            ? Container(
                height: 48, 
                child: dropdownButton<String>(
                      widget.app, context,
                      isDense: false,
                      isExpanded: \${withImages},
                      items: items,
                      value: value,
                      hint: text(widget.app, context, 'Select a \${lid}'),
                      onChanged: _onValueChange,
                    )
                ) 
            : dropdownButton<String>(
                widget.app, context,
                isDense: false,
                isExpanded: \${withImages},
                items: items,
                value: value,
                hint: text(widget.app, context, 'Select a \${lid}'),
                onChanged: _onValueChange,
              ),
          if (value != null) Spacer(),
          if (value != null) 
            Align(alignment: Alignment.topRight, child: button(
              widget.app,
              context,
              icon: Icon(
                Icons.edit,
              ),
              label: 'Update',
              onPressed: () {
                updateComponent(context, widget.app, '\${lid}s', value, (newValue, _) {
                  setState(() {
                    value = value;
                  });
                });
              },
            ))
          ])
        ]);
      } else {
        return StyleRegistry.registry().styleWithApp(widget.app).adminListStyle().progressIndicator(widget.app, context);
      }
    });
  }

  void _onValueChange(String? value) {
    widget.trigger!(value, null);
  }

  void _onPrivilegeLevelChange(int? value) {
    BlocProvider.of<\${id}ListBloc>(context).add(\${id}ChangeQuery(
       newQuery: EliudQuery(theConditions: [
         EliudQueryCondition('conditions.privilegeLevelRequired', isEqualTo: value ?? 0),
         EliudQueryCondition('appId', isEqualTo: widget.app.documentID),]
       ),
     ));
     widget.trigger!(null, value);
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
  DropdownButtonCodeGenerator({required super.modelSpecifications});

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(process(_imports(modelSpecifications.packageName),
        parameters: <String, String>{
          '\${path}': camelcaseToUnderscore(modelSpecifications.id),
          '\${id}': modelSpecifications.id,
          '\${lid}': firstLowerCase(modelSpecifications.id),
        }));
    headerBuffer.writeln(process(
        _specificImports(modelSpecifications.packageName),
        parameters: <String, String>{
          '\${path}': camelcaseToUnderscore(modelSpecifications.id),
          '\${id}': modelSpecifications.id,
          '\${lid}': firstLowerCase(modelSpecifications.id),
        }));
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    StringBuffer childCodeBuffer = StringBuffer();

    childCodeBuffer.writeln(
        "List<Widget> _widgets(${modelSpecifications.id}Model value) {");
    childCodeBuffer.writeln("var app = widget.app;");
    childCodeBuffer.writeln("var widgets = <Widget>[];");
    String? title = modelSpecifications.listFields == null
        ? null
        : modelSpecifications.listFields!.title;
    childCodeBuffer.writeln("widgets.add($title);");
    String? subTitle = modelSpecifications.listFields == null
        ? null
        : modelSpecifications.listFields!.subTitle;
    if (subTitle != null) {
      childCodeBuffer.writeln("widgets.add($subTitle);");
    }
    childCodeBuffer.writeln("return widgets;");
    childCodeBuffer.writeln("}");

    String privilegeChosenCode;
    if (modelSpecifications.fields
        .where((element) => element.fieldName == 'conditions')
        .isNotEmpty) {
      privilegeChosenCode = '''
        var selectedValue = state.values!.firstWhere((v) => (v!.documentID == value), orElse: () => null);
        privilegeChosen = selectedValue != null && selectedValue.conditions != null && selectedValue.conditions!.privilegeLevelRequired != null ? selectedValue.conditions!.privilegeLevelRequired!.index : 0;
        ''';
    } else {
      privilegeChosenCode = 'privilegeChosen = 0';
    }

    codeBuffer.writeln(process(_code, parameters: <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
      '\${childCode}': childCodeBuffer.toString(),
      "\${withImages}": modelSpecifications.listFields == null
          ? ""
          : modelSpecifications.listFields!.hasImage().toString(),
      "\${privilegeChosenCode}": privilegeChosenCode,
    }));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listFileName();
  }
}
