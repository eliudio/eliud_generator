import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _imports = """
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../tools/delete_snackbar.dart';
import '../tools/router_builders.dart';
import '../tools/etc.dart';
import '../tools/enums.dart';
import '../core/eliud.dart';

import '\${importprefix}_list_event.dart';
import '\${importprefix}_list_state.dart';
import '\${importprefix}_list_bloc.dart';
import '\${importprefix}_form.dart';
import '\${importprefix}_model.dart';
import '\${importprefix}_form.dart';

""";

String _listBody = """
class \${id}ListWidget extends StatelessWidget {
  \${id}ListWidget({ Key key }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<\${id}ListBloc, \${id}ListState>(builder: (context, state) {
      if (state is \${id}ListLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is \${id}ListLoaded) {
        final values = state.values;
        return new Scaffold(
          floatingActionButton: !Eliud.isAdmin() ? null : FloatingActionButton(
            heroTag: "\${id}FloatBtnTag",
            foregroundColor: RgbHelper.color(rgbo: Eliud.appModel().floatingButtonForegroundColor),
            backgroundColor: RgbHelper.color(rgbo: Eliud.appModel().floatingButtonBackgroundColor),
            child: Icon(Icons.add),
              onPressed: () {
              Navigator.of(context).push(
                pageRouteBuilder(page: BlocProvider.value(
                    value: BlocProvider.of<\${id}ListBloc>(context),
                    child: \${id}Form(
                        value: null,
                        formAction: FormAction.AddAction)
                )),
              );
            },
          ),
          body: Container(color: RgbHelper.color(rgbo: Eliud.appModel().listBackgroundColor), child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: RgbHelper.color(rgbo: Eliud.appModel().dividerColor)
              ),
              itemCount: values.length,
              itemBuilder: (context, index) {
                final value = values[index];
                return \${id}ListItem(
                  value: value,
                  onDismissed: (direction) {
                    BlocProvider.of<\${id}ListBloc>(context)
                        .add(Delete\${id}List(value: value));
                    Scaffold.of(context).showSnackBar(DeleteSnackBar(
                      message: "\${id} " + value.\${displayOnDelete},
                      onUndo: () => BlocProvider.of<\${id}ListBloc>(context)
                          .add(Add\${id}List(value: value)),
                    ));
                  },
                  onTap: () async {
                    final removedItem = await Navigator.of(context).push(
                      pageRouteBuilder(page: BlocProvider.value(
                            value: BlocProvider.of<\${id}ListBloc>(context),
                            child: \${id}Form(
                                value: value,
                                formAction: FormAction.UpdateAction))));
                    if (removedItem != null) {
                      Scaffold.of(context).showSnackBar(
                        DeleteSnackBar(
                      message: "\${id} " + value.\${displayOnDelete},
                          onUndo: () => BlocProvider.of<\${id}ListBloc>(context)
                              .add(Add\${id}List(value: value)),
                        ),
                      );
                    }
                  },
                );
              }),
        ));
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    });
  }
}

""";

class ListCodeGenerator extends CodeGenerator {
  ListCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    return process(_imports, parameters: <String, String>{
      "\${importprefix}": resolveImport(importThis: camelcaseToUnderscore(modelSpecifications.id)),
    });
  }

  String mainClass() {
    return process(_listBody, parameters: <String, String>{
      "\${id}": modelSpecifications.id,
      "\${displayOnDelete}": modelSpecifications?.displayOnDelete ?? "documentID",
    });
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(mainClass());

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
    codeBuffer.writeln(spaces(10) + "tag: '\${value.documentID}__" + modelSpecifications.id + "heroTag',");
    codeBuffer.writeln(spaces(10) + "child: Container(");
    codeBuffer.writeln(spaces(12) + "width: MediaQuery.of(context).size.width,");
    if (modelSpecifications.listFields.imageTitle) {
      codeBuffer.writeln(spaces(12) + "child: Center( child: ImageHelper.getImageFromImageModel(imageModel: value." + title + ", width: MediaQuery.of(context).size.width))");
    } else {
      codeBuffer.writeln(spaces(12) + "child: Center(child: Text(");
      codeBuffer.writeln(spaces(14) + "value." + title + ",");
      codeBuffer.writeln(
          spaces(14) + "style: TextStyle(color: RgbHelper.color(rgbo: Eliud.appModel().listTextItemColor)),");
      codeBuffer.writeln(spaces(12) + ")),");
    }
    codeBuffer.writeln(spaces(10) + "),");
    codeBuffer.writeln(spaces(8) + "),");
    String subTitle = modelSpecifications.listFields.subTitle;
    if (subTitle != null) {
      codeBuffer.writeln(spaces(8) + "subtitle: (value." + subTitle + " != null) && (value." + subTitle + ".isNotEmpty)");
      codeBuffer.write(spaces(12) + "? ");
      if (modelSpecifications.listFields.imageSubTitle) {
        codeBuffer.writeln("Center( child: ImageHelper.getThumbnailFromImageModel(imageModel: value, width: MediaQuery.of(context).size.width))");
      } else {
        codeBuffer.writeln("Center( child: Text(");
        codeBuffer.writeln(spaces(10) + "value." + subTitle + ",");
        codeBuffer.writeln(spaces(10) + "maxLines: 1,");
        codeBuffer.writeln(spaces(10) + "overflow: TextOverflow.ellipsis,");
        codeBuffer.writeln(
            spaces(10) + "style: TextStyle(color: RgbHelper.color(rgbo: Eliud.appModel().listTextItemColor)),");
        codeBuffer.writeln(spaces(8) + "))");
      }
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
