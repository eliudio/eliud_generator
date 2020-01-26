import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class FormCodeGenerator extends CodeGenerator {
  FormCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:eliud_model/shared/embedded_component.dart';");
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" +
        resolveImport(importThis: modelSpecifications.listBlocFileName()) +
        "';");
    headerBuffer.writeln("import '" +
        resolveImport(importThis: modelSpecifications.listEventFileName()) +
        "';");
    headerBuffer.writeln("import '" +
        resolveImport(importThis: modelSpecifications.modelFileName()) +
        "';");
    headerBuffer.writeln("import '" +
        resolveImport(importThis: modelSpecifications.formBlocFileName()) +
        "';");
    headerBuffer.writeln("import '" +
        resolveImport(importThis: modelSpecifications.formEventFileName()) +
        "';");
    headerBuffer.writeln("import '" +
        resolveImport(importThis: modelSpecifications.formStateFileName()) +
        "';");
    headerBuffer.writeln("import '../tools/enums.dart';");

    headerBuffer.writeln("import 'package:flutter/foundation.dart';");
    headerBuffer.writeln(
        "import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';");
    headerBuffer.writeln("import 'package:intl/intl.dart';");

    headerBuffer.writeln();
    return headerBuffer.toString();
  }



  String _xyzFrom() {
    StringBuffer codeBuffer = StringBuffer();
    String className = modelSpecifications.formClassName();
    codeBuffer.writeln("class " + className + " extends StatelessWidget {");
    codeBuffer.writeln(spaces(2) + "FormAction formAction;");
    codeBuffer
        .writeln(spaces(2) + modelSpecifications.modelClassName() + " value;");
    codeBuffer.writeln();

    codeBuffer.writeln(spaces(2) +
        className +
        "({Key key, @required this.formAction, @required this.value}) : super(key: key);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "return Scaffold(");
    codeBuffer.writeln(spaces(6) +
        "appBar: formAction == FormAction.UpdateAction ? AppBar(title: Text(\"Update\")) : AppBar(title: Text(\"Add\")),");
    codeBuffer.writeln(spaces(6) +
        "body: BlocProvider<" +
        modelSpecifications.id +
        "FormBloc >(");
    codeBuffer.writeln(spaces(10) +
        "create: (context) => " +
        modelSpecifications.id +
        "FormBloc()");
    codeBuffer.writeln(spaces(12) +
        "..add((Initialise" +
        modelSpecifications.id +
        "FormEvent(value: value))),");
    codeBuffer.writeln(spaces(6) +
        "child: My" +
        modelSpecifications.id +
        "Form(formAction: formAction),");
    codeBuffer.writeln(spaces(8) + "));");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _myXyzForm() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(
        "class My" + modelSpecifications.id + "Form extends StatefulWidget {");
    codeBuffer.writeln(spaces(2) + "final FormAction formAction;");
    codeBuffer.writeln();
    codeBuffer.writeln(
        spaces(2) + "My" + modelSpecifications.id + "Form({this.formAction});");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) +
        "_My" +
        modelSpecifications.id +
        "FormState createState() => _My" +
        modelSpecifications.id +
        "FormState(this.formAction);");
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
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
          // Support private data members for lookup / combo box
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
    });
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _xyzFormStateConstructor() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) +
        "_My" +
        modelSpecifications.id +
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
          // Initialise private data members for lookup / combo box
          break;
        case FormTypeField.Selection:
          codeBuffer.writeln(
              spaces(4) + "_" + field.fieldName + "SelectedRadioTile = 0;");
          break;
        case FormTypeField.List:
          // Initialise support private data members for list
          break;
        case FormTypeField.Unsupported:
          // Ignore
          break;
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
    codeBuffer.writeln(spaces(4) + "return BlocBuilder<" + modelSpecifications.id + "FormBloc, " + modelSpecifications.id +"FormState>(builder: (context, state) {");

    // state is ...Uninitialized
    codeBuffer.writeln(spaces(6) + "if (state is " + modelSpecifications.id + "FormUninitialized) return Center(");
    codeBuffer.writeln(spaces(8) + "child: CircularProgressIndicator(),");
    codeBuffer.writeln(spaces(6) + ");");
    codeBuffer.writeln();

    // state is ...FormLoaded
    codeBuffer.writeln(spaces(6) + "Size fullSize = MediaQuery.of(context).size;");
    codeBuffer.writeln(spaces(6) + "if (state is " + modelSpecifications.id + "FormLoaded) {");
    modelSpecifications.fields.forEach((field) {
      switch (field.formFieldType()) {
        case FormTypeField.EntryField:
          codeBuffer.writeln(spaces(8) +
              "_" +
              field.fieldName +
              "Controller.text = state.value." + field.fieldName + ".toString();");
          break;
        case FormTypeField.CheckBox:
          codeBuffer.writeln(
              spaces(8) + "_" + field.fieldName + "Selection = state.value." + field.fieldName +  ";");
          break;
        case FormTypeField.Lookup:
          // Initialise private data members for lookup / combo box
          break;
        case FormTypeField.Selection:
          codeBuffer.writeln(
              spaces(8) + "_" + field.fieldName + "SelectedRadioTile = state.value." + field.fieldName +  ".index;");
          break;
        case FormTypeField.List:
          // Initialise support private data members for list
          break;
        case FormTypeField.Unsupported:
          // Ignore
          break;
      }
    });
    codeBuffer.writeln(spaces(6) + "}");

    codeBuffer.writeln(spaces(6) + "if (state is " + modelSpecifications.id + "FormInitialized) {");
    codeBuffer.writeln(spaces(8) + "return Container(");
    codeBuffer.writeln(spaces(10) + "padding:");
    codeBuffer.writeln(spaces(10) + "const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),");
    codeBuffer.writeln(spaces(12) + "child: Form(");

    codeBuffer.writeln(spaces(12) + "child: ListView(");
    codeBuffer.writeln(spaces(14) + "padding: const EdgeInsets.all(8),");
    codeBuffer.writeln(spaces(14) + "children: <Widget>[");
    if (modelSpecifications.groups == null) {
      codeBuffer.writeln(_fields(modelSpecifications.fields));
    } else {
      if (modelSpecifications.hasUngroupedFields()) {
        codeBuffer.writeln(
            _groupedFieldsFor(
                "General", modelSpecifications.unGroupedFields()));
      }
      modelSpecifications.groups.forEach((group) {
        codeBuffer.writeln(
            _groupedFieldsFor(group.description ?? group.group, modelSpecifications.fieldsForGroups(group)));
      }
      );
    }
    codeBuffer.writeln(spaces(16) + "RaisedButton(");
    codeBuffer.writeln(spaces(18) + "onPressed: () {");
    codeBuffer.writeln(spaces(14 + 6) + "if (state is " + modelSpecifications.id + "FormError) {");
    codeBuffer.writeln(spaces(14 + 8) + "return null;");
    codeBuffer.writeln(spaces(14 + 6) + "} else {");
    codeBuffer.writeln(spaces(14 + 8) + "if (formAction == FormAction.UpdateAction) {");
    codeBuffer.writeln(spaces(14 + 10) + "BlocProvider.of<" + modelSpecifications.id + "ListBloc>(context).add(");
    codeBuffer.writeln(spaces(14 + 12) + "Update" + modelSpecifications.id + "List(value: "+ modelSpecifications.modelClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.writeln(spaces(14 + 16) + field.fieldName + ": state.value." + field.fieldName + ", ");
    });
    codeBuffer.writeln(spaces(14 + 10) + ")));");
    codeBuffer.writeln(spaces(14 + 8) + "} else {");
    codeBuffer.writeln(spaces(14 + 10) + "BlocProvider.of<" + modelSpecifications.id + "ListBloc>(context).add(");
    codeBuffer.writeln(spaces(14 + 12) + "Add" + modelSpecifications.id + "List(value: "+ modelSpecifications.modelClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.writeln(spaces(14 + 16) + field.fieldName + ": state.value." + field.fieldName + ", ");
    });
    codeBuffer.writeln(spaces(14 + 12) + ")));");
    codeBuffer.writeln(spaces(14 + 8) + "}");
    codeBuffer.writeln(spaces(14 + 8) + "Navigator.pop(context);");
    codeBuffer.writeln(spaces(14 + 8) + "return true;");
    codeBuffer.writeln(spaces(14 + 6) + "}");

    codeBuffer.writeln(spaces(18) + "},");
    codeBuffer.writeln(spaces(18) + "child: Text('Submit'),");
    codeBuffer.writeln(spaces(16) + "),");
    codeBuffer.writeln(spaces(14) + "],");
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

  String _groupedFieldHeader(String groupLabel) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(16) + "Container(");
    codeBuffer.writeln(spaces(18) + "alignment: Alignment.centerLeft,");
    codeBuffer.writeln(spaces(18) + "padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),");
    codeBuffer.writeln(spaces(18) + "child: Text('$groupLabel',");
    codeBuffer.writeln(spaces(22) + "style: TextStyle(");
    codeBuffer.writeln(spaces(26) + "color: Colors.red, fontWeight: FontWeight.bold)),");
    codeBuffer.writeln(spaces(16) + "),");
    return codeBuffer.toString();
  }

  String _groupedFieldFooter() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(16) + "const Divider(height: 1.0, thickness: 1.0, color: Colors.red),");
    return codeBuffer.toString();
  }

  String _field(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    switch (field.formFieldType()) {
      case FormTypeField.EntryField:
        codeBuffer.writeln(spaces(16) + "TextFormField(");
        if (field.fieldName == "documentID") {
          codeBuffer.writeln(spaces(18) + "readOnly: (formAction == FormAction.UpdateAction),");
        }
        codeBuffer.writeln(spaces(18) + "controller: _" + field.fieldName + "Controller,");
        codeBuffer.writeln(spaces(18) + "decoration: InputDecoration(");
        codeBuffer.write(spaces(20) + "icon: Icon(Icons.");
        if (field.iconName != null)
          codeBuffer.write(field.iconName);
        else
          codeBuffer.write("text_format");
        codeBuffer.writeln("),");
        codeBuffer.write(spaces(20) + "labelText: '");
        if (field.displayName == null)
          codeBuffer.write(field.fieldName);
        else
          codeBuffer.write(field.displayName);
        codeBuffer.writeln("',");
        if (field.remark != null)
          codeBuffer.writeln(spaces(20) + "hintText: \"" + field.remark + "\",");
        codeBuffer.writeln(spaces(18) + "),");
        if (field.isDouble()) codeBuffer.writeln(spaces(18) + "keyboardType: TextInputType.number,");
        if (field.isInt()) codeBuffer.writeln(spaces(18) + "keyboardType: TextInputType.number,");
        if (field.isString()) codeBuffer.writeln(spaces(18) + "keyboardType: TextInputType.text,");
        codeBuffer.writeln(spaces(18) + "autovalidate: true,");
        codeBuffer.writeln(spaces(18) + "validator: (_) {");
        codeBuffer.writeln(spaces(20) + "return state is " + firstUpperCase(field.fieldName) + modelSpecifications.id + "FormError ? state.message : null;");
        codeBuffer.writeln(spaces(18) + "},");
        codeBuffer.writeln(spaces(16) + "),");
        break;
      case FormTypeField.CheckBox:
        codeBuffer.writeln(spaces(16) + "CheckboxListTile(");
        codeBuffer.write(spaces(20) + "title: const Text('");
        if (field.displayName == null)
          codeBuffer.write(field.fieldName);
        else
          codeBuffer.write(field.displayName);
        codeBuffer.writeln("'),");
        codeBuffer.writeln(spaces(20) + "value: _" + firstLowerCase(field.fieldName) + "Selection,");
        codeBuffer.writeln(spaces(20) + "onChanged: (val) {");
//      codeBuffer.writeln(spaces(22) + "setState(() => print());");
        codeBuffer.writeln(spaces(22) + "setSelection" + firstUpperCase(field.fieldName) + "(val);");
        codeBuffer.writeln(spaces(20) + "}),");
        break;
      case FormTypeField.Lookup:
        break;
      case FormTypeField.Selection:
        int i = 0;
        field.enumValues.forEach((enumField) {
          codeBuffer.writeln(spaces(16) + "RadioListTile(");
          codeBuffer.writeln(spaces(20) + "value: $i,");
          codeBuffer.writeln(spaces(20) + "groupValue: _" + firstLowerCase(field.fieldName) + "SelectedRadioTile,");
          codeBuffer.writeln(spaces(20) + "title: Text(\"" + enumField + "\"),");
          codeBuffer.writeln(spaces(20) + "subtitle: Text(\"" + enumField + "\"),");
          codeBuffer.writeln(spaces(20) + "onChanged: (val) {");
          codeBuffer.writeln(spaces(22) + "setSelection" + firstUpperCase(field.fieldName) + "(val);");
          codeBuffer.writeln(spaces(20) + "},");
          codeBuffer.writeln(spaces(16) + "),");
          i++;
        });
        break;
      case FormTypeField.List:
        codeBuffer.writeln(spaces(16) + "new Container(");
        codeBuffer.writeln(spaces(20) + "height: (fullSize.height / 2.5), ");
        codeBuffer.writeln(spaces(20) + "child: EmbeddedComponentFactory." + firstLowerCase(field.fieldType) + "sList(state.value." + field.fieldName + ", _on" + field.fieldType + "sChanged)");
        codeBuffer.writeln(spaces(16) + "),");
        break;

    break;
      case FormTypeField.Unsupported:
        break;
    }
    return codeBuffer.toString();
  }

  String _groupedFieldsFor(String groupLabel, List<Field> fields) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(_groupedFieldHeader(groupLabel));
    codeBuffer.writeln(_fields(fields));
    codeBuffer.writeln(_groupedFieldFooter());
    return codeBuffer.toString();
  }

  String _fields(List<Field> fields) {
    StringBuffer codeBuffer = StringBuffer();
    fields.forEach((field) {
      if (!field.hidden)
      codeBuffer.writeln(_field(field));
    });
    return codeBuffer.toString();
  }

  String _xyzFormState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class _My" +
        modelSpecifications.id +
        "FormState extends State<My" +
        modelSpecifications.id +
        "Form> {");
    codeBuffer.writeln(_xyzFormStateMemberData());
    codeBuffer.writeln(_xyzFormStateFieldMemberData());
    codeBuffer.writeln(_xyzFormStateConstructor());
    codeBuffer.writeln(_xyzFormStateInitState());
    codeBuffer.writeln(_xyzFormStateBuild());
    codeBuffer.writeln(_xyzChangeds());
    codeBuffer.writeln(_dispose());
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _xyzOnChanged(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "void _on" + firstUpperCase(field.fieldName) + "Changed() {");
    codeBuffer.writeln(spaces(4) + "_myFormBloc.add(Changed" + modelSpecifications.id + firstUpperCase(field.fieldName) + "(value: _" + firstLowerCase(field.fieldName) + "Controller.text));");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _listChanged(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "void _on" + firstUpperCase(field.fieldName) + "Changed(value) {");
    codeBuffer.writeln(spaces(4) + "_myFormBloc.add(Changed" + modelSpecifications.id + firstUpperCase(field.fieldName) + "(value: value));");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _xyzSetEnumSelection(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "void setSelection" + firstUpperCase(field.fieldName) + "(int val) {");
    codeBuffer.writeln(spaces(4) + "setState(() {");
    codeBuffer.writeln(
        spaces(6) + "_" + field.fieldName + "SelectedRadioTile = val;");
    codeBuffer.writeln(spaces(4) + "});");
    codeBuffer.writeln(spaces(4) + "_myFormBloc.add(Changed" + modelSpecifications.id + firstUpperCase(field.fieldName) + "(value: to" + field.dartModelType() + "(val)));");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _xyzSetBooleanSelection(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "void setSelection" + firstUpperCase(field.fieldName) + "(bool val) {");
    codeBuffer.writeln(spaces(4) + "setState(() {");
    codeBuffer.writeln(
        spaces(6) + "_" + field.fieldName + "Selection = val;");
    codeBuffer.writeln(spaces(4) + "});");
    codeBuffer.writeln(spaces(4) + "_myFormBloc.add(Changed" + modelSpecifications.id + firstUpperCase(field.fieldName) + "(value: val));");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _xyzChangeds() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      switch (field.formFieldType()) {
        case FormTypeField.List:
          codeBuffer.writeln(_listChanged(field));
          break;
        case FormTypeField.EntryField:
          codeBuffer.writeln(_xyzOnChanged(field));
          break;
        case FormTypeField.CheckBox:
          codeBuffer.writeln(_xyzSetBooleanSelection(field));
          break;
        case FormTypeField.Lookup:
          break;
        case FormTypeField.Selection:
          codeBuffer.writeln(_xyzSetEnumSelection(field));
          break;
        case FormTypeField.Unsupported:
          break;
      }
    });
    return codeBuffer.toString();
  }

  String _dispose() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "void dispose() {");
    modelSpecifications.fields.forEach((field) {
      if (field.formFieldType() == FormTypeField.EntryField) {
        codeBuffer.writeln(spaces(4) +
            "_" +
            field.fieldName +
            "Controller.dispose();");
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
