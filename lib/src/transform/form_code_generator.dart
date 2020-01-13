import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class FormCodeGenerator extends CodeGenerator {
  FormCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.listBlocFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.modelFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formBlocFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formEventFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formStateFileName()) + "';");
    headerBuffer.writeln("import '../tools/enums.dart';");

    headerBuffer.writeln("import 'package:flutter/foundation.dart';");
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln("import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';");
    headerBuffer.writeln("import 'package:intl/intl.dart';");

    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  // TODO: Chop this into different methods!
  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String idTag = firstLowerCase(modelSpecifications.id) + "Id";
    String className = modelSpecifications.formClassName();
    codeBuffer.writeln("class " + className + " extends StatelessWidget {");
    codeBuffer.writeln(spaces(2) + "FormAction formAction;");
    codeBuffer.writeln(spaces(2) + modelSpecifications.modelClassName() + " value;");
    codeBuffer.writeln();

    codeBuffer.writeln(spaces(2) + className + "({Key key, @required this.formAction, @required this.value}) : super(key: key);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "return Scaffold(");
    codeBuffer.writeln(spaces(6) + "appBar: formAction == FormAction.UpdateAction ? AppBar(title: Text(\"Update\")) : AppBar(title: Text(\"Add\")),");
    codeBuffer.writeln(spaces(6) + "body: BlocProvider<" + modelSpecifications.id + "FormBloc >(");
    codeBuffer.writeln(spaces(10) + "create: (context) => " + modelSpecifications.id + "FormBloc()");
    codeBuffer.writeln(spaces(12) + "..add((Initialise" + modelSpecifications.id + "FormEvent(value: value))),");
    codeBuffer.writeln(spaces(6) + "child: My" + modelSpecifications.id + "Form(formAction: formAction),");
    codeBuffer.writeln(spaces(8) + "));");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class My" + modelSpecifications.id + "Form extends StatefulWidget {");
    codeBuffer.writeln(spaces(2) + "final FormAction formAction;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "My" + modelSpecifications.id + "Form({this.formAction});");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "_My" + modelSpecifications.id + "FormState createState() => _My" + modelSpecifications.id + "FormState(this.formAction);");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class _My" + modelSpecifications.id + "FormState extends State<My" + modelSpecifications.id + "Form> {");
    codeBuffer.writeln(spaces(2) + "final FormAction formAction;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "FormBloc _myFormBloc;");
    codeBuffer.writeln();

    modelSpecifications.fields.forEach((field) {
      switch (field.formFieldType()) {
        case FormTypeField.EntryField:
          codeBuffer.writeln(spaces(2) + "final TextEditingController _" + field.fieldName + "Controller = TextEditingController();");
          break;
        case FormTypeField.CheckBox:
          codeBuffer.writeln(spaces(2) + "bool _" + field.fieldName  + "Selection;");
          break;
        case FormTypeField.Lookup:
          // Support private data members for lookup / combo box
          break;
        case FormTypeField.Selection:
          codeBuffer.writeln(spaces(2) + "int _" + field.fieldName  + "SelectedRadioTile;");
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

    codeBuffer.writeln(spaces(2) + "_My" + modelSpecifications.id + "FormState(this.formAction);");
    codeBuffer.writeln();

    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "void initState() {");
    codeBuffer.writeln(spaces(4) + "super.initState();");
    codeBuffer.writeln(spaces(4) + "_myFormBloc = BlocProvider.of<" + modelSpecifications.id + "FormBloc>(context);");

    /*
    modelSpecifications.fields.forEach((field) {
      switch (field.formFieldType()) {
        case FormTypeField.EntryField:
          codeBuffer.writeln(spaces(2) + field.fieldName + "Controller.addListener(_on" + field.fieldName + "Changed);");
          break;
        case FormTypeField.CheckBox:
          codeBuffer.writeln(spaces(2) + field.fieldName  + "Selection = false;");
          break;
        case FormTypeField.Lookup:
          // Initialise private data members for lookup / combo box
          break;
        case FormTypeField.Selection:
          codeBuffer.writeln(spaces(2) + field.fieldName  + "SelectedRadioTile = 0;");
          break;
        case FormTypeField.List:
          // Initialise support private data members for list
          break;
        case FormTypeField.Unsupported:
          // Ignore
          break;
      }
    });
    codeBuffer.writeln();
    */

    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();

    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "throw UnimplementedError();");
    codeBuffer.writeln(spaces(2) + "}");

    codeBuffer.writeln("}");

    codeBuffer.writeln();
    return codeBuffer.toString();
  }


  @override
  String theFileName() {
    return modelSpecifications.formFileName();
  }
}
