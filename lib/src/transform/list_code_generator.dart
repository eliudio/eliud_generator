import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class ListCodeGenerator extends CodeGenerator {
  ListCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.listBlocFileName()) + "';");
    headerBuffer.writeln("import '../tools/delete_snackbar.dart';");
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter/foundation.dart';");
    headerBuffer.writeln("import 'package:flutter/widgets.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.listEventFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.listStateFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.modelFileName()) + "';");
    headerBuffer.writeln("import '../tools/enums.dart';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + modelSpecifications.id + "ListWidget extends StatelessWidget {");
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "ListWidget({ Key key }): super(key: key);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "return BlocBuilder<" + modelSpecifications.id + "ListBloc, " + modelSpecifications.id + "ListState>(builder: (context, state) {");
    codeBuffer.writeln(spaces(6) + "if (state is " + modelSpecifications.id + "ListLoading) {");
    codeBuffer.writeln(spaces(8) + "return Center(");
    codeBuffer.writeln(spaces(10) + "child: CircularProgressIndicator(),");
    codeBuffer.writeln(spaces(8) + ");");
    codeBuffer.writeln(spaces(6) + "} else if (state is " + modelSpecifications.id + "ListLoaded) {");
    codeBuffer.writeln(spaces(8) + "final values = state.values;");
    codeBuffer.writeln(spaces(8) + "return new Scaffold(");
    codeBuffer.writeln(spaces(10) + "floatingActionButton: FloatingActionButton(");
    codeBuffer.writeln(spaces(12) + "foregroundColor: Colors.white,");
    codeBuffer.writeln(spaces(12) + "backgroundColor: Colors.black,");
    codeBuffer.writeln(spaces(12) + "child: Icon(Icons.add),");
    codeBuffer.writeln(spaces(14) + "onPressed: () {");
    codeBuffer.writeln(spaces(14) + "Navigator.of(context).push(");
    codeBuffer.writeln(spaces(16) + "MaterialPageRoute(builder: (_) {");
    codeBuffer.writeln(spaces(18) + "return BlocProvider.value(");
    codeBuffer.writeln(spaces(22) + "value: BlocProvider.of<" + modelSpecifications.id + "ListBloc" + ">(context),");
    codeBuffer.writeln(spaces(22) + "child: " + modelSpecifications.formClassName() + "(");
    codeBuffer.writeln(spaces(24) + "value: " + modelSpecifications.modelClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      if (field.defaultValue != null) {
        codeBuffer.write(spaces(33) + field.fieldName + ": ");
        if ((field.isInt()) || (field.isDouble())) {
          codeBuffer.write(field.defaultValue);
        } else if (field.isString()) {
          codeBuffer.write("\"" + field.defaultValue + "\"");
        }
        codeBuffer.writeln(", ");
      } else {
        if (field.array)
          codeBuffer.writeln(spaces(33) + field.fieldName + ": [],");
        if (field.isInt()) {
          codeBuffer.writeln(spaces(33) + field.fieldName + ": 0,");
        } else if (field.isDouble()) {
            codeBuffer.writeln(spaces(33) + field.fieldName + ": 0.0,");
        } else if (field.isString()) {
          codeBuffer.writeln(spaces(33) + field.fieldName + ": \"\",");
        }
      }
    });
    codeBuffer.writeln(spaces(31) + "), ");
    codeBuffer.writeln(spaces(24) + "formAction: FormAction.AddAction)");
    codeBuffer.writeln(spaces(22) + ");");
    codeBuffer.writeln(spaces(16) + "}),");
    codeBuffer.writeln(spaces(14) + ");");
    codeBuffer.writeln(spaces(12) + "},");
    codeBuffer.writeln(spaces(10) + "),");
    codeBuffer.writeln(spaces(10) + "body: ListView.builder(");
    codeBuffer.writeln(spaces(14) + "itemCount: values.length,");
    codeBuffer.writeln(spaces(14) + "itemBuilder: (context, index) {");
    codeBuffer.writeln(spaces(16) + "final value = values[index];");
    codeBuffer.writeln(spaces(16) + "return " + modelSpecifications.id + "ListItem(");
    codeBuffer.writeln(spaces(18) + "value: value,");
    codeBuffer.writeln(spaces(18) + "onDismissed: (direction) {");
    codeBuffer.writeln(spaces(20) + "BlocProvider.of<" + modelSpecifications.id + "ListBloc>(context)");
    codeBuffer.writeln(spaces(24) + ".add(Delete" + modelSpecifications.id + "List(value: value));");
    codeBuffer.writeln(spaces(20) + "Scaffold.of(context).showSnackBar(DeleteSnackBar(");
    codeBuffer.write(spaces(22) + "message: \"" + modelSpecifications.id + " \" + value.");
    if (modelSpecifications.displayOnDelete != null)
      codeBuffer.write(modelSpecifications.displayOnDelete);
    else
      codeBuffer.write("documentID");
    codeBuffer.writeln(",");
    codeBuffer.writeln(spaces(22) + "onUndo: () => BlocProvider.of<" + modelSpecifications.id + "ListBloc>(context)");
    codeBuffer.writeln(spaces(26) + ".add(Add" + modelSpecifications.id + "List(value: value)),");
    codeBuffer.writeln(spaces(20) + "));");
    codeBuffer.writeln(spaces(18) + "},");
    codeBuffer.writeln(spaces(18) + "onTap: () async {");
    codeBuffer.writeln(spaces(20) + "final removedItem = await Navigator.of(context).push(");
    codeBuffer.writeln(spaces(22) + "MaterialPageRoute(builder: (_) {");
    codeBuffer.writeln(spaces(24) + "return BlocProvider.value(");
    codeBuffer.writeln(spaces(28) + "value: BlocProvider.of<" + modelSpecifications.id + "ListBloc>(context),");
    codeBuffer.writeln(spaces(28) + "child: " + modelSpecifications.id + "Form(");
    codeBuffer.writeln(spaces(32) + "value: value,");
    codeBuffer.writeln(spaces(32) + "formAction: FormAction.UpdateAction));");
    codeBuffer.writeln(spaces(22) + "}),");
    codeBuffer.writeln(spaces(20) + ");");
    codeBuffer.writeln(spaces(20) + "if (removedItem != null) {");
    codeBuffer.writeln(spaces(22) + "Scaffold.of(context).showSnackBar(");
    codeBuffer.writeln(spaces(24) + "DeleteSnackBar(");

    codeBuffer.write(spaces(22) + "message: \"" + modelSpecifications.id + " \" + value.");
    if (modelSpecifications.displayOnDelete != null)
      codeBuffer.write(modelSpecifications.displayOnDelete);
    else
      codeBuffer.write("documentID");
    codeBuffer.writeln(",");
    codeBuffer.writeln(spaces(26) + "onUndo: () => BlocProvider.of<" + modelSpecifications.id + "ListBloc>(context)");
    codeBuffer.writeln(spaces(30) + ".add(Add" + modelSpecifications.id + "List(value: value)),");
    codeBuffer.writeln(spaces(24) + "),");
    codeBuffer.writeln(spaces(22) + ");");
    codeBuffer.writeln(spaces(20) + "}");
    codeBuffer.writeln(spaces(18) + "},");
    codeBuffer.writeln(spaces(16) + ");");
    codeBuffer.writeln(spaces(14) + "}),");
    codeBuffer.writeln(spaces(8) + ");");

    codeBuffer.writeln(spaces(6) + "} else {");
    codeBuffer.writeln(spaces(8) + "return Center(");
    codeBuffer.writeln(spaces(10) + "child: CircularProgressIndicator(),");
    codeBuffer.writeln(spaces(8) + ");");
    codeBuffer.writeln(spaces(6) + "}");
    codeBuffer.writeln(spaces(4) + "});");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "ListItem extends StatelessWidget {");
    codeBuffer.writeln(spaces(2) + "final DismissDirectionCallback onDismissed;");
    codeBuffer.writeln(spaces(2) + "final GestureTapCallback onTap;");
    codeBuffer.writeln(spaces(2) + "final " + modelSpecifications.modelClassName() + " value;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "ListItem({");
    codeBuffer.writeln(spaces(4) + "Key key,");
    codeBuffer.writeln(spaces(4) + "@required this.onDismissed,");
    codeBuffer.writeln(spaces(4) + "@required this.onTap,");
    codeBuffer.writeln(spaces(4) + "@required this.value,");
    codeBuffer.writeln(spaces(2) + "}) : super(key: key);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "return Dismissible(");
    codeBuffer.writeln(spaces(6) + "key: Key('__" + modelSpecifications.id + "_item_\${value.documentID}'),");
    codeBuffer.writeln(spaces(6) + "onDismissed: onDismissed,");
    codeBuffer.writeln(spaces(6) + "child: ListTile(");
    codeBuffer.writeln(spaces(8) + "onTap: onTap,");
    codeBuffer.writeln(spaces(8) + "title: Hero(");
    String title = modelSpecifications.listFields?.title ?? "documentID";
    codeBuffer.writeln(spaces(10) + "tag: '\${value.documentID}__heroTag',");
    codeBuffer.writeln(spaces(10) + "child: Container(");
    codeBuffer.writeln(spaces(12) + "width: MediaQuery.of(context).size.width,");
    codeBuffer.writeln(spaces(12) + "child: Text(");
    codeBuffer.writeln(spaces(14) + "value." + title + ",");
    codeBuffer.writeln(spaces(14) + "style: Theme.of(context).textTheme.title,");
    codeBuffer.writeln(spaces(12) + "),");
    codeBuffer.writeln(spaces(10) + "),");
    codeBuffer.writeln(spaces(8) + "),");
    String subTitle = modelSpecifications.listFields.subTitle;
    if (subTitle != null) {
      codeBuffer.writeln(spaces(8) + "subtitle: (value." + subTitle + " != null) && (value." + subTitle + ".isNotEmpty)");
      codeBuffer.writeln(spaces(12) + "? Text(");
      codeBuffer.writeln(spaces(10) + "value." + subTitle + ",");
      codeBuffer.writeln(spaces(10) + "maxLines: 1,");
      codeBuffer.writeln(spaces(10) + "overflow: TextOverflow.ellipsis,");
      codeBuffer.writeln(
          spaces(10) + "style: Theme.of(context).textTheme.subhead,");
      codeBuffer.writeln(spaces(8) + ")");
      codeBuffer.writeln(spaces(12) + ": null,");
    }
    codeBuffer.writeln(spaces(6) + "),");
    codeBuffer.writeln(spaces(4) + ");");

    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listFileName();
  }
}
