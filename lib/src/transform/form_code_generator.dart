import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/group.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _imports = """
import 'package:eliud_model/core/global_data.dart';
import 'package:eliud_model/shared/abstract_repository_singleton.dart';
import 'package:eliud_model/shared/action_model.dart';
import 'package:eliud_model/core/navigate/router.dart';
import 'package:eliud_model/tools/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:intl/intl.dart';

import '../tools/enums.dart';

import '../shared/internal_component.dart';
import '../shared/embedded_component.dart';
import '../shared/bespoke_formfields.dart';
import '../shared/abstract_repository_singleton.dart';

import '../core/eliud.dart';
import '../tools/etc.dart';

""";

const String _specificImports = """
import '\${path}_list_bloc.dart';
import '\${path}_list_event.dart';
import '\${path}_model.dart';
import '\${path}_form_bloc.dart';
import '\${path}_form_event.dart';
import '\${path}_form_state.dart';

""";

const String _xyzFormString = """
class \${className}Form extends StatelessWidget {
  FormAction formAction;
  \${id}Model value;
  ActionModel submitAction;

  \${className}Form({Key key, @required this.formAction, @required this.value, this.submitAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (formAction == FormAction.ShowData) {
      return BlocProvider<\${id}FormBloc >(
            create: (context) => \${id}FormBloc(
                                       \${constructorParameters}
                                                )..add(Initialise\${id}FormEvent(value: value)),
  
        child: My\${className}Form(submitAction: submitAction, formAction: formAction),
          );
    } if (formAction == FormAction.ShowPreloadedData) {
      return BlocProvider<\${id}FormBloc >(
            create: (context) => \${id}FormBloc(
                                       \${constructorParameters}
                                                )..add(Initialise\${id}FormNoLoadEvent(value: value)),
  
        child: My\${className}Form(submitAction: submitAction, formAction: formAction),
          );
    } else {
      return Scaffold(
        appBar: formAction == FormAction.UpdateAction ?
                AppBar(
                    title: Text("\${updateTitle}", style: TextStyle(color: RgbHelper.color(rgbo: GlobalData.app().formAppBarTextColor))),
                    flexibleSpace: Container(
                        decoration: BoxDecorationHelper.boxDecoration(GlobalData.app().formAppBarBackground)),
                  ) :
                AppBar(
                    title: Text("\${addTitle}", style: TextStyle(color: RgbHelper.color(rgbo: GlobalData.app().formAppBarTextColor))),
                    flexibleSpace: Container(
                        decoration: BoxDecorationHelper.boxDecoration(GlobalData.app().formAppBarBackground)),
                ),
        body: BlocProvider<\${id}FormBloc >(
            create: (context) => \${id}FormBloc(
                                       \${constructorParameters}
                                                )..add((formAction == FormAction.UpdateAction ? Initialise\${id}FormEvent(value: value) : InitialiseNew\${id}FormEvent())),
  
        child: My\${className}Form(submitAction: submitAction, formAction: formAction),
          ));
    }
  }
}

""";

const String _myXyzFormString = """
class My\${className}Form extends StatefulWidget {
  final FormAction formAction;
  final ActionModel submitAction;

  My\${className}Form({this.formAction, this.submitAction});

  _My\${className}FormState createState() => _My\${className}FormState(this.formAction);
}

""";

const _groupFieldHeaderString = """
        \${condition} children.add(Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Text('\${label}',
                      style: TextStyle(
                          color: RgbHelper.color(rgbo: GlobalData.app().formGroupTitleColor), fontWeight: FontWeight.bold)),
                ));
""";

const _otherChangedString = """
  void _on\${upperFieldName}Changed(value) {
    _myFormBloc.add(Changed\${id}\${upperFieldName}(value: value));
    \${setState}
  }

""";

const _xyzSetEnumSelectionString = """
  void setSelection\${upperFieldName}(int val) {
    setState(() {
      _\${lowerFieldName}SelectedRadioTile = val;
    });
    _myFormBloc.add(Changed\${id}\${upperFieldName}(value: to\${fieldType}(val)));
  }

""";

const _xyzSetBooleanSelectionString = """
  void setSelection\${upperFieldName}(bool val) {
    setState(() {
      _\${lowerFieldName}Selection = val;
    });
    _myFormBloc.add(Changed\${id}\${upperFieldName}(value: val));
  }
""";

const _xyzLookupChangedString = """
  void _on\${upperFieldName}Selected(String val) {
    setState(() {
      _\${lowerFieldName} = val;
    });
    _myFormBloc.add(Changed\${id}\${upperFieldName}(value: val));
  }

""";

const String _readOnlyMethodMember = """
  bool _readOnly(\${id}FormInitialized state) {
    return (formAction == FormAction.ShowData) || (formAction == FormAction.ShowPreloadedData) || (state.value.documentID != GlobalData.member().documentID);
  }
  
""";

const String _readOnlyMethod = """
  bool _readOnly(\${id}FormInitialized state) {
    return (formAction == FormAction.ShowData) || (formAction == FormAction.ShowPreloadedData) || (!GlobalData.memberIsOwner());
  }
  
""";

class RealFormCodeGenerator extends CodeGenerator {
  final String className;
  final String title;
  final String buttonLabel;

  RealFormCodeGenerator(this.className, { this.title, this.buttonLabel, ModelSpecification modelSpecifications })
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(process(_imports));
    headerBuffer.writeln(process(_specificImports, parameters: <String, String>{
      '\${path}': camelcaseToUnderscore(modelSpecifications.id)
    }));
    return headerBuffer.toString();
  }

  String _xyzFrom() {
    StringBuffer constructorParameters = StringBuffer();
    if (withRepository()) {
      constructorParameters.writeln("formAction: formAction,");
    }

    return process(_xyzFormString, parameters: <String, String>{
      "\${className}": className,
      "\${id}": modelSpecifications.id,
      "\${lid}": firstLowerCase(modelSpecifications.id),
      "\${constructorParameters}": constructorParameters.toString(),
      "\${updateTitle}": title == null ? "Update " + modelSpecifications.id : title,
      "\${addTitle}": title == null ? "Add " + modelSpecifications.id : title,
    });
  }

  String _myXyzForm() {
    return process(_myXyzFormString, parameters: <String, String>{
      "\${className}": className,
      "\${id}": modelSpecifications.id,
      "\${lid}": firstLowerCase(modelSpecifications.id)
    });
  }

  String _xyzFormStateMemberData() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "final FormAction formAction;");
    codeBuffer
        .writeln(spaces(2) + modelSpecifications.id + "FormBloc _myFormBloc;");
    return codeBuffer.toString();
  }

  String _xyzFormStateFieldMemberData() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.bespokeFormField == null) {
        switch (field.formFieldType()) {
          case FormTypeField.EntryField:
            codeBuffer.writeln(spaces(2) +
                "final TextEditingController _" +
                field.fieldName +
                "Controller = TextEditingController();");
            break;
          case FormTypeField.CheckBox:
            codeBuffer
                .writeln(spaces(2) + "bool _" + field.fieldName + "Selection;");
            break;
          case FormTypeField.Lookup:
            codeBuffer.writeln(spaces(2) + "String _" + field.fieldName + ";");
            break;
          case FormTypeField.Selection:
            codeBuffer.writeln(
                spaces(2) + "int _" + field.fieldName + "SelectedRadioTile;");
            break;
          case FormTypeField.List:
            // Support private data members for list
            break;
          case FormTypeField.Unsupported:
            // Ignore
            break;
        }
      }
    });
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _xyzFormStateConstructor() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) +
        "_My" +
        className +
        "FormState(this.formAction);");
    return codeBuffer.toString();
  }

  String _xyzFormStateInitState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "void initState() {");
    codeBuffer.writeln(spaces(4) + "super.initState();");
    codeBuffer.writeln(spaces(4) +
        "_myFormBloc = BlocProvider.of<" +
        modelSpecifications.id +
        "FormBloc>(context);");
    modelSpecifications.fields.forEach((field) {
      if (field.bespokeFormField == null) {
        switch (field.formFieldType()) {
          case FormTypeField.EntryField:
            codeBuffer.writeln(spaces(4) +
                "_" +
                field.fieldName +
                "Controller.addListener(_on" +
                firstUpperCase(field.fieldName) +
                "Changed);");
            break;
          case FormTypeField.CheckBox:
            codeBuffer.writeln(
                spaces(4) + "_" + field.fieldName + "Selection = false;");
            break;
          case FormTypeField.Lookup:
            break;
          case FormTypeField.Selection:
            codeBuffer.writeln(
                spaces(4) + "_" + field.fieldName + "SelectedRadioTile = 0;");
            break;
          case FormTypeField.List:
            break;
          case FormTypeField.Unsupported:
            // Ignore
            break;
        }
      }
    });
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _xyzFormStateBuild() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");

    // start blocbuilder
    codeBuffer.writeln(spaces(4) +
        "return BlocBuilder<" +
        modelSpecifications.id +
        "FormBloc, " +
        modelSpecifications.id +
        "FormState>(builder: (context, state) {");

    // state is ...Uninitialized
    codeBuffer.writeln(spaces(6) +
        "if (state is " +
        modelSpecifications.id +
        "FormUninitialized) return Center(");
    codeBuffer.writeln(spaces(8) + "child: CircularProgressIndicator(),");
    codeBuffer.writeln(spaces(6) + ");");
    codeBuffer.writeln();

    // state is ...FormLoaded
    codeBuffer.writeln(
        spaces(6) + "if (state is " + modelSpecifications.id + "FormLoaded) {");
    modelSpecifications.fields.forEach((field) {
      if (field.bespokeFormField == null) {
        switch (field.formFieldType()) {
          case FormTypeField.EntryField:
            codeBuffer.writeln(
                spaces(8) + "if (state.value." + field.fieldName + " != null)");
            codeBuffer.writeln(spaces(10) +
                "_" +
                field.fieldName +
                "Controller.text = state.value." +
                field.fieldName +
                ".toString();");
            codeBuffer.writeln(
                spaces(8) + "else");
            codeBuffer.writeln(spaces(10) +
                "_" +
                field.fieldName +
                "Controller.text = \"\";");
            break;
          case FormTypeField.CheckBox:
            codeBuffer.writeln(
                spaces(8) + "if (state.value." + field.fieldName + " != null)");
            codeBuffer.writeln(spaces(8) +
                "_" +
                field.fieldName +
                "Selection = state.value." +
                field.fieldName +
                ";");
            codeBuffer.writeln(
                spaces(8) + "else");
            codeBuffer.writeln(spaces(8) +
                "_" +
                field.fieldName +
                "Selection = false;");
            break;
          case FormTypeField.Lookup:
            codeBuffer.writeln(
                spaces(8) + "if (state.value." + field.fieldName + " != null)");
            codeBuffer.writeln(spaces(10) +
                "_" +
                field.fieldName +
                "= state.value." +
                field.fieldName +
                ".documentID;");
            codeBuffer.writeln(
                spaces(8) + "else");
            codeBuffer.writeln(spaces(10) +
                "_" +
                field.fieldName +
                "= \"\";");
            break;
          case FormTypeField.Selection:
            codeBuffer.writeln(
                spaces(8) + "if (state.value." + field.fieldName + " != null)");
            codeBuffer.writeln(spaces(10) +
                "_" +
                field.fieldName +
                "SelectedRadioTile = state.value." +
                field.fieldName +
                ".index;");
            codeBuffer.writeln(
                spaces(8) + "else");
            codeBuffer.writeln(spaces(10) +
                "_" +
                field.fieldName +
                "SelectedRadioTile = 0;");
            break;
          case FormTypeField.List:
            // Initialise support private data members for list
            break;
          case FormTypeField.Unsupported:
            // Ignore
            break;
        }
      }
    });
    codeBuffer.writeln(spaces(6) + "}");

    codeBuffer.writeln(spaces(6) +
        "if (state is " +
        modelSpecifications.id +
        "FormInitialized) {");

    codeBuffer.writeln(spaces(8) + "List<Widget> children = List();");

    if (modelSpecifications.groups == null) {
      codeBuffer.writeln(_fields(modelSpecifications.fields));
    } else {
      if (modelSpecifications.hasUngroupedFields()) {
        codeBuffer.writeln(_groupedFieldsFor(
            "General", null, modelSpecifications.unGroupedFields()));
      }
      modelSpecifications.groups.forEach((group) {
        codeBuffer.writeln(_groupedFieldsFor(group.description ?? group.group, group.conditional,
            modelSpecifications.fieldsForGroups(group)));
      });
    }
    codeBuffer.writeln(spaces(8) + "if ((formAction != FormAction.ShowData) && (formAction != FormAction.ShowPreloadedData))");
    codeBuffer.writeln(spaces(10) + "children.add(RaisedButton(");
    codeBuffer.writeln(spaces(18) + "color: RgbHelper.color(rgbo: GlobalData.app().formSubmitButtonColor),");
    codeBuffer.writeln(spaces(18) + "onPressed: _readOnly(state) ? null : () {");
    codeBuffer.writeln(spaces(14 + 6) +
        "if (state is " +
        modelSpecifications.id +
        "FormError) {");
    codeBuffer.writeln(spaces(14 + 8) + "return null;");
    codeBuffer.writeln(spaces(14 + 6) + "} else {");
    codeBuffer.writeln(
        spaces(14 + 8) + "if (formAction == FormAction.UpdateAction) {");
    codeBuffer.writeln(spaces(14 + 10) +
        "BlocProvider.of<" +
        modelSpecifications.id +
        "ListBloc>(context).add(");
    codeBuffer.writeln(spaces(14 + 12) +
        "Update" +
        modelSpecifications.id +
        "List(value: state.value.copyWith(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.writeln(spaces(14 + 16) +
          field.fieldName +
          ": state.value." +
          field.fieldName +
          ", ");
    });
    codeBuffer.writeln(spaces(14 + 10) + ")));");
    codeBuffer.writeln(spaces(14 + 8) + "} else {");
    codeBuffer.writeln(spaces(14 + 10) +
        "BlocProvider.of<" +
        modelSpecifications.id +
        "ListBloc>(context).add(");
    codeBuffer.writeln(spaces(14 + 12) +
        "Add" +
        modelSpecifications.id +
        "List(value: " +
        modelSpecifications.modelClassName() +
        "(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.writeln(spaces(14 + 16) +
          field.fieldName +
          ": state.value." +
          field.fieldName +
          ", ");
    });
    codeBuffer.writeln(spaces(14 + 12) + ")));");
    codeBuffer.writeln(spaces(14 + 8) + "}");

    codeBuffer.writeln(spaces(14 + 8) + "if (widget.submitAction != null) {");
    codeBuffer.writeln(spaces(14 + 10) + "Router.navigateTo(context, widget.submitAction);");
    codeBuffer.writeln(spaces(14 + 8) + "} else {");
    codeBuffer.writeln(spaces(14 + 10) + "Navigator.pop(context);");
    codeBuffer.writeln(spaces(14 + 8) + "}");

    codeBuffer.writeln(spaces(14 + 8) + "return true;");
    codeBuffer.writeln(spaces(14 + 6) + "}");

    codeBuffer.writeln(spaces(18) + "},");
    String label = buttonLabel == null ? 'Submit' : buttonLabel;
    codeBuffer.writeln(spaces(18) + "child: Text('" + label + "', style: TextStyle(color: RgbHelper.color(rgbo: GlobalData.app().formSubmitButtonTextColor))),");
    codeBuffer.writeln(spaces(16) + "));");

    codeBuffer.writeln();
    codeBuffer.writeln(spaces(8) + "return Container(");
    codeBuffer.writeln(spaces(10) + "color: ((formAction == FormAction.ShowData) || (formAction == FormAction.ShowPreloadedData)) ? Colors.transparent : null,");
    codeBuffer.writeln(spaces(10) + "decoration: ((formAction == FormAction.ShowData) || (formAction == FormAction.ShowPreloadedData)) ? null : BoxDecorationHelper.boxDecoration(GlobalData.app().formBackground),");
    codeBuffer.writeln(spaces(10) + "padding:");
    codeBuffer.writeln(spaces(10) +
        "const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),");
    codeBuffer.writeln(spaces(12) + "child: Form(");

    codeBuffer.writeln(spaces(12) + "child: ListView(");
    codeBuffer.writeln(spaces(14) + "padding: const EdgeInsets.all(8),");
    codeBuffer.writeln(spaces(14) + "physics: ((formAction == FormAction.ShowData) || (formAction == FormAction.ShowPreloadedData)) ? NeverScrollableScrollPhysics() : null,");
    codeBuffer.writeln(spaces(14) + "shrinkWrap: ((formAction == FormAction.ShowData) || (formAction == FormAction.ShowPreloadedData)),");
    codeBuffer.writeln(spaces(14) + "children: children");
    codeBuffer.writeln(spaces(12) + "),");
    codeBuffer.writeln(spaces(10) + ")");
    codeBuffer.writeln(spaces(8) + ");");

    codeBuffer.writeln(spaces(6) + "} else {");
    codeBuffer.writeln(spaces(8) + "return CircularProgressIndicator();");
    codeBuffer.writeln(spaces(6) + "}");
    // close blocbuilder
    codeBuffer.writeln(spaces(4) + "});");

    // close method
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _groupedFieldHeader(String groupLabel, String condition) {
    String conditionStr = "";
    if (condition != null) conditionStr = "if " + condition;
    return process(_groupFieldHeaderString,
        parameters: <String, String> {
          "\${label}": groupLabel,
          "\${condition}": conditionStr
          }
        );
  }

  String _groupedFieldFooter() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(8) +
        "children.add(Container(height: 20.0));");
    codeBuffer.writeln(spaces(8) +
        "children.add(Divider(height: 1.0, thickness: 1.0, color: RgbHelper.color(rgbo: GlobalData.app().dividerColor)));");
    return codeBuffer.toString();
  }

  String _fieldStart(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    if (field.conditional != null) {
      codeBuffer.writeln(
          spaces(8) + "if (" + field.conditional + ") children.add(");
    } else {
      codeBuffer.writeln(spaces(8) + "children.add(");
    }
    return codeBuffer.toString();
  }

  String _fieldEnd() {
    return spaces(10) + ");";
  }

  String _field(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    if (field.bespokeFormField == null) {
      switch (field.formFieldType()) {
        case FormTypeField.EntryField:
          codeBuffer.writeln(_fieldStart(field));
          codeBuffer.writeln(spaces(16) + "TextFormField(");
          codeBuffer.writeln(spaces(16) + "style: TextStyle(color: RgbHelper.color(rgbo: GlobalData.app().formFieldTextColor)),");
          if (field.fieldName == "documentID") {
            if (modelSpecifications.id == "Member")
              codeBuffer.writeln(spaces(18) +
                  "readOnly: true,");
            else
              codeBuffer.writeln(spaces(18) +
                  "readOnly: (formAction == FormAction.UpdateAction),");
          } else {
            codeBuffer.writeln(spaces(18) + "readOnly: _readOnly(state),");
          }
          codeBuffer.writeln(
              spaces(18) + "controller: _" + field.fieldName + "Controller,");
          codeBuffer.writeln(spaces(18) + "decoration: InputDecoration(");
          codeBuffer.write(spaces(20) + "enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: RgbHelper.color(rgbo: GlobalData.app().formFieldTextColor))),");
          codeBuffer.write(spaces(20) + "focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: RgbHelper.color(rgbo: GlobalData.app().formFieldFocusColor))),");
          codeBuffer.write(spaces(20) + "icon: Icon(Icons.");
          if (field.iconName != null)
            codeBuffer.write(field.iconName);
          else
            codeBuffer.write("text_format");
          codeBuffer.writeln(", color: RgbHelper.color(rgbo: GlobalData.app().formFieldHeaderColor)),");
          codeBuffer.write(spaces(20) + "labelText: '");
          if (field.displayName == null)
            codeBuffer.write(field.fieldName);
          else
            codeBuffer.write(field.displayName);
          codeBuffer.writeln("',");
          if (field.remark != null)
            codeBuffer
                .writeln(spaces(20) + "hintText: \"" + field.remark + "\",");
          codeBuffer.writeln(spaces(18) + "),");
          if (field.isDouble())
            codeBuffer
                .writeln(spaces(18) + "keyboardType: TextInputType.number,");
          if (field.isInt())
            codeBuffer
                .writeln(spaces(18) + "keyboardType: TextInputType.number,");
          if (field.isString())
            codeBuffer
                .writeln(spaces(18) + "keyboardType: TextInputType.text,");
          codeBuffer.writeln(spaces(18) + "autovalidate: true,");
          codeBuffer.writeln(spaces(18) + "validator: (_) {");
          codeBuffer.writeln(spaces(20) +
              "return state is " +
              firstUpperCase(field.fieldName) +
              modelSpecifications.id +
              "FormError ? state.message : null;");
          codeBuffer.writeln(spaces(18) + "},");
          codeBuffer.writeln(spaces(16) + "),");
          codeBuffer.writeln(_fieldEnd());
          break;
        case FormTypeField.CheckBox:
          codeBuffer.writeln(_fieldStart(field));
          codeBuffer.writeln(spaces(16) + "CheckboxListTile(");
          codeBuffer.write(spaces(20) + "title: Text('");
          if (field.displayName == null)
            codeBuffer.write(field.fieldName);
          else
            codeBuffer.write(field.displayName);
          codeBuffer.writeln("', style: TextStyle(color: RgbHelper.color(rgbo: GlobalData.app().formFieldTextColor))),");
          codeBuffer.writeln(spaces(20) +
              "value: _" +
              firstLowerCase(field.fieldName) +
              "Selection,");
          codeBuffer.writeln(spaces(20) + "onChanged: _readOnly(state) || !GlobalData.memberIsOwner() ? null : (val) {");
          //      codeBuffer.writeln(spaces(22) + "setState(() => print());");
          codeBuffer.writeln(spaces(22) +
              "setSelection" +
              firstUpperCase(field.fieldName) +
              "(val);");
          codeBuffer.writeln(spaces(20) + "}),");
          codeBuffer.writeln(_fieldEnd());
          break;
        case FormTypeField.Lookup:
          codeBuffer.writeln(_fieldStart(field));
          bool optionalValue = field.optional;
          codeBuffer.writeln(spaces(16) +
              "DropdownButtonComponentFactory().createNew(id: \"" +
              firstLowerCase(field.fieldType) +
              "s\", value: _" +
              firstLowerCase(field.fieldName) +
              ", trigger: " + "_on" + firstUpperCase(field.fieldName) + "Selected" +
              ", optional: $optionalValue),");
          codeBuffer.writeln(_fieldEnd());
          break;
        case FormTypeField.Selection:
          int i = 0;
          field.enumValues.forEach((enumField) {
            codeBuffer.writeln(_fieldStart(field));
            codeBuffer.writeln(spaces(16) + "RadioListTile(");
            codeBuffer.writeln(spaces(20) + "value: $i,");
            codeBuffer.writeln(spaces(20) + "activeColor: RgbHelper.color(rgbo: GlobalData.app().formFieldTextColor),");
            codeBuffer.writeln(spaces(20) +
                "groupValue: _" +
                firstLowerCase(field.fieldName) +
                "SelectedRadioTile,");
            codeBuffer
                .writeln(spaces(20) + "title: Text(\"" + enumField + "\", style: TextStyle(color: RgbHelper.color(rgbo: GlobalData.app().formFieldTextColor))),");
            codeBuffer
                .writeln(spaces(20) + "subtitle: Text(\"" + enumField + "\", style: TextStyle(color: RgbHelper.color(rgbo: GlobalData.app().formFieldTextColor))),");
            codeBuffer.writeln(spaces(20) + "onChanged: !GlobalData.memberIsOwner() ? null : (val) {");
            codeBuffer.writeln(spaces(22) +
                "setSelection" +
                firstUpperCase(field.fieldName) +
                "(val);");
            codeBuffer.writeln(spaces(20) + "},");
            codeBuffer.writeln(spaces(16) + "),");
            codeBuffer.writeln(_fieldEnd());
            i++;
          });
          break;
        case FormTypeField.List:
          codeBuffer.writeln(_fieldStart(field));
          codeBuffer.writeln(spaces(16) + "new Container(");
          codeBuffer.writeln(spaces(20) + "height: (fullScreenHeight(context) / 2.5), ");
          codeBuffer.writeln(spaces(20) +
              "child: EmbeddedComponentFactory." +
              firstLowerCase(field.fieldType) +
              "sList(state.value." +
              field.fieldName +
              ", _on" +
              firstUpperCase(field.fieldName) +
              "Changed)");
          codeBuffer.writeln(spaces(16) + ")");
          codeBuffer.writeln(_fieldEnd());
          break;

          break;
        case FormTypeField.Unsupported:
          break;
      }
    } else {
      if (field.bespokeFormField.contains("(")) {
        codeBuffer.writeln(_fieldStart(field));
        codeBuffer.writeln(spaces(16) + field.bespokeFormField + "");
        codeBuffer.writeln(_fieldEnd());
      } else {
        codeBuffer.writeln(_fieldStart(field));
        codeBuffer.writeln(spaces(16) +
            field.bespokeFormField +
            "(" +
            "state.value." +
            field.fieldName +
            ", _on" +
            firstUpperCase(field.fieldName) +
            "Changed)");
        codeBuffer.writeln(_fieldEnd());
      }
    }
    return codeBuffer.toString();
  }

  String _groupedFieldsFor(String groupLabel, String condition, List<Field> fields) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(_groupedFieldHeader(groupLabel, condition ));
    codeBuffer.writeln(_fields(fields));
    codeBuffer.writeln(_groupedFieldFooter());
    return codeBuffer.toString();
  }

  String _fields(List<Field> fields) {
    StringBuffer codeBuffer = StringBuffer();
    fields.forEach((field) {
      if (!field.hidden) codeBuffer.writeln(_field(field));
    });
    return codeBuffer.toString();
  }

  String _xyzFormState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class _My" +
        className +
        "FormState extends State<My" +
        className +
        "Form> {");
    codeBuffer.writeln(_xyzFormStateMemberData());
    codeBuffer.writeln(_xyzFormStateFieldMemberData());
    codeBuffer.writeln(_xyzFormStateConstructor());
    codeBuffer.writeln(_xyzFormStateInitState());
    codeBuffer.writeln(_xyzFormStateBuild());
    codeBuffer.writeln(_xyzChangeds());
    codeBuffer.writeln(_dispose());
    codeBuffer.writeln(_readOnly());
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _readOnly() {
    if (modelSpecifications.id == "Member")
      return process(_readOnlyMethodMember, parameters: <String, String>{
        "\${id}": modelSpecifications.id,
      });
    else
      return process(_readOnlyMethod, parameters: <String, String>{
        "\${id}": modelSpecifications.id,
      });
  }

  String _xyzOnChanged(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) +
        "void _on" +
        firstUpperCase(field.fieldName) +
        "Changed() {");
    codeBuffer.writeln(spaces(4) +
        "_myFormBloc.add(Changed" +
        modelSpecifications.id +
        firstUpperCase(field.fieldName) +
        "(value: _" +
        firstLowerCase(field.fieldName) +
        "Controller.text));");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _otherChanged(Field field) {
    String setState = "";
    if (field.formFieldType() == FormTypeField.List) {
      setState = "setState(() {});";
    }
    return process(_otherChangedString, parameters: <String, String>{
      "\${upperFieldName}": firstUpperCase(field.fieldName),
      "\${id}": modelSpecifications.id,
      "\${setState}": setState
    });
  }

  String _xyzSetEnumSelection(Field field) {
    return process(_xyzSetEnumSelectionString, parameters: <String, String>{
      "\${lowerFieldName}": firstLowerCase(field.fieldName),
      "\${upperFieldName}": firstUpperCase(field.fieldName),
      "\${id}": modelSpecifications.id,
      "\${fieldType}": field.dartModelType()
    });
  }

  String _xyzSetBooleanSelection(Field field) {
    return process(_xyzSetBooleanSelectionString, parameters: <String, String>{
      "\${lowerFieldName}": firstLowerCase(field.fieldName),
      "\${upperFieldName}": firstUpperCase(field.fieldName),
      "\${id}": modelSpecifications.id
    });
  }

  String _xyzLookupChanged(Field field) {
    return process(_xyzLookupChangedString, parameters: <String, String>{
      "\${lowerFieldName}": firstLowerCase(field.fieldName),
      "\${upperFieldName}": firstUpperCase(field.fieldName),
      "\${id}": modelSpecifications.id
    });
  }

  String _xyzChangeds() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.bespokeFormField == null) {
        switch (field.formFieldType()) {
          case FormTypeField.List:
            codeBuffer.writeln(_otherChanged(field));
            break;
          case FormTypeField.EntryField:
            codeBuffer.writeln(_xyzOnChanged(field));
            break;
          case FormTypeField.CheckBox:
            codeBuffer.writeln(_xyzSetBooleanSelection(field));
            break;
          case FormTypeField.Lookup:
            codeBuffer.writeln(_xyzLookupChanged(field));
            break;
          case FormTypeField.Selection:
            codeBuffer.writeln(_xyzSetEnumSelection(field));
            break;
          case FormTypeField.Unsupported:
            break;
        }
      } else {
        codeBuffer.writeln(_otherChanged(field));
      }
    });
    return codeBuffer.toString();
  }

  String _dispose() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "void dispose() {");
    modelSpecifications.fields.forEach((field) {
      if (field.bespokeFormField == null) {
        if (field.formFieldType() == FormTypeField.EntryField) {
          codeBuffer.writeln(
              spaces(4) + "_" + field.fieldName + "Controller.dispose();");
        }
      }
    });
    codeBuffer.writeln(spaces(4) + "super.dispose();");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(_xyzFrom());
    codeBuffer.writeln(_myXyzForm());
    codeBuffer.writeln(_xyzFormState());
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.formFileName();
  }
}

class FormCodeGenerator extends CodeGenerator {
  final RealFormCodeGenerator realFormCodeGenerator;

  FormCodeGenerator({ModelSpecification modelSpecifications})
      : realFormCodeGenerator = RealFormCodeGenerator(modelSpecifications.id, modelSpecifications: modelSpecifications),
        super(modelSpecifications: modelSpecifications);

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(realFormCodeGenerator.body());
    if (modelSpecifications.views != null) {
      modelSpecifications.views.forEach((view) {
        List<Field> fields = List();
        view.fields.forEach((fieldName) {
          // search in the list of view.
          Field newField = modelSpecifications.fields.firstWhere((field) => field.fieldName == fieldName);
          if (newField != null) {
            fields.add(newField);
          }
        });

        List<Group> groups = List();
        view.groups.forEach((groupName) {
          // search in the list of view.
          Group newGroup = modelSpecifications.groups.firstWhere((group) => group.group == groupName);
          if (newGroup != null) {
            groups.add(newGroup);
          }
        });

        if (fields.length > 0) {
          ModelSpecification newModelSpec = modelSpecifications.copyWith(
              fields: fields, groups: groups);
          codeBuffer.writeln(RealFormCodeGenerator(
              modelSpecifications.id + view.name,
              modelSpecifications: newModelSpec,
              title: view.title,
              buttonLabel: view.buttonLabel,
          ).body());
        } else {
          print("view " + view.name + " has no fields matching the specifications");
        }
      });
    }
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.formFileName();
  }

  @override
  String commonImports() {
    return realFormCodeGenerator.commonImports();
  }
}
