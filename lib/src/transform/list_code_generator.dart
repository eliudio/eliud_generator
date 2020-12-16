import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _imports(String packageName) => """
import 'package:eliud_core/core/access/bloc/access_bloc.dart';
import 'package:eliud_core/core/access/bloc/access_state.dart';
import 'package:eliud_core/core/access/bloc/access_state.dart';
import 'package:eliud_core/core/widgets/progress_indicator.dart';

import 'package:eliud_core/core/global_data.dart';
import 'package:eliud_core/tools/has_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/tools/screen_size.dart';
import 'package:eliud_core/model/background_model.dart';
import 'package:eliud_core/tools/delete_snackbar.dart';
import 'package:eliud_core/tools/router_builders.dart';
import 'package:eliud_core/tools/etc.dart';
import 'package:eliud_core/tools/enums.dart';
import 'package:eliud_core/eliud.dart';

import 'package:$packageName/model/\${importprefix}_list_event.dart';
import 'package:$packageName/model/\${importprefix}_list_state.dart';
import 'package:$packageName/model/\${importprefix}_list_bloc.dart';
import 'package:$packageName/model/\${importprefix}_model.dart';

import 'package:eliud_core/model/app_model.dart';

""";

String _importForms = """
import '\${importprefix}_form.dart';
""";

String _onTap = """
                      final removedItem = await Navigator.of(context).push(
                        pageRouteBuilder(accessState.app, page: BlocProvider.value(
                              value: BlocProvider.of<\${id}ListBloc>(context),
                              child: getForm(value, FormAction.UpdateAction))));
                      if (removedItem != null) {
                        Scaffold.of(context).showSnackBar(
                          DeleteSnackBar(
                        message: "\${id} " + value.\${displayOnDelete},
                            onUndo: () => BlocProvider.of<\${id}ListBloc>(context)
                                .add(Add\${id}List(value: value)),
                          ),
                        );
                      }
""";


class ListCodeGenerator extends CodeGenerator {
  ListCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_imports(modelSpecifications.packageName), parameters: <String, String>{
      "\${importprefix}": camelcaseToUnderscore(modelSpecifications.id)
    }));
    if (modelSpecifications.generate.generateForm) {
      codeBuffer.writeln(process(_importForms, parameters: <String, String>{
        "\${importprefix}": camelcaseToUnderscore(modelSpecifications.id),
      }));
    }
    extraImports(codeBuffer, ModelSpecification.IMPORT_KEY_ALTERNATIVE_LIST_WIDGETS);
    return codeBuffer.toString();
  }

  String mainClass() {
    Map<String, String> parameters = <String, String>{
      "\${id}": modelSpecifications.id,
      "\${displayOnDelete}": modelSpecifications?.displayOnDelete ?? "documentID",
      "\${allowAddItemsCondition}" : modelSpecifications.id != "Member" ? "" : "&& false",
    };

    String tap;
    if (modelSpecifications.generate.generateForm) {
      tap = process(_onTap, parameters: parameters);
    } else {
      tap = "";
    }

    String _formVariations = "";
    if (modelSpecifications.views != null) {
      modelSpecifications.views.forEach((element) {
        _formVariations = _formVariations + spaces(6) + "if (widget.form == \"" +
            modelSpecifications.id + element.name + "Form\") return " +
            modelSpecifications.id + element.name +
            "Form(value: value, formAction: action);\n";
      });
    }
    _formVariations = _formVariations + spaces(6) + "return null;";

    String _listItemVariations = "";
    if (modelSpecifications.listWidgets != null) {
      modelSpecifications.listWidgets.forEach((element) {
        _listItemVariations = _listItemVariations + spaces(10) + "if (widget.listItemWidget == \"" + element.listItemWidget + "\") return " + element.listItemWidget + "(value: value);\n";
      });
    }

    parameters["\${onTap}"] = tap;
    parameters["\${_formVariations}"] = _formVariations;
    parameters["\${_listItemVariations}"] = _listItemVariations;
    return process(_listBody, parameters: parameters);
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(mainClass());

    codeBuffer.writeln("class " + modelSpecifications.id + "ListItem extends StatelessWidget {");
    codeBuffer.writeln(spaces(2) + "final DismissDirectionCallback onDismissed;");
    codeBuffer.writeln(spaces(2) + "final GestureTapCallback onTap;");
    codeBuffer.writeln(spaces(2) + "final AppModel app;");
    codeBuffer.writeln(spaces(2) + "final " + modelSpecifications.modelClassName() + " value;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "ListItem({");
    codeBuffer.writeln(spaces(4) + "Key key,");
    codeBuffer.writeln(spaces(4) + "@required this.onDismissed,");
    codeBuffer.writeln(spaces(4) + "@required this.onTap,");
    codeBuffer.writeln(spaces(4) + "@required this.value,");
    codeBuffer.writeln(spaces(4) + "@required this.app,");
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
    codeBuffer.writeln(spaces(12) + "width: fullScreenWidth(context),");
    if (modelSpecifications.listFields.imageTitle) {
      codeBuffer.writeln(spaces(12) + "child: Center( child: ImageHelper.getImageFromImageModel(imageModel: value." + title + ", width: fullScreenWidth(context)))");
    } else {
      codeBuffer.writeln(spaces(12) + "child: Center(child: Text(");
      codeBuffer.writeln(spaces(14) + "value." + title + ",");
      codeBuffer.writeln(
          spaces(14) + "style: TextStyle(color: RgbHelper.color(rgbo: app.listTextItemColor)),");
      codeBuffer.writeln(spaces(12) + ")),");
    }
    codeBuffer.writeln(spaces(10) + "),");
    codeBuffer.writeln(spaces(8) + "),");
    String subTitle = modelSpecifications.listFields.subTitle;
    if (subTitle != null) {
      codeBuffer.writeln(spaces(8) + "subtitle: (value." + subTitle + " != null) && (value." + subTitle + ".isNotEmpty)");
      codeBuffer.write(spaces(12) + "? ");
      if (modelSpecifications.listFields.imageSubTitle) {
        codeBuffer.writeln("Center( child: ImageHelper.getThumbnailFromImageModel(imageModel: value, width: fullScreenWidth(context)))");
      } else {
        codeBuffer.writeln("Center( child: Text(");
        codeBuffer.writeln(spaces(10) + "value." + subTitle + ",");
        codeBuffer.writeln(spaces(10) + "maxLines: 1,");
        codeBuffer.writeln(spaces(10) + "overflow: TextOverflow.ellipsis,");
        codeBuffer.writeln(
            spaces(10) + "style: TextStyle(color: RgbHelper.color(rgbo: app.listTextItemColor)),");
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

String _listBody = """
class \${id}ListWidget extends StatefulWidget with HasFab {
  BackgroundModel listBackground;
  bool readOnly;
  String form;
  String listItemWidget;
  \${id}ListWidgetState state;
  bool isEmbedded;

  \${id}ListWidget({ Key key, this.readOnly, this.form, this.listItemWidget, this.isEmbedded, this.listBackground }): super(key: key);

  @override
  \${id}ListWidgetState createState() {
    state ??= \${id}ListWidgetState();
    return state;
  }

  @override
  Widget fab(BuildContext context) {
    if ((readOnly != null) && readOnly) return null;
    state ??= \${id}ListWidgetState();
    var accessState = AccessBloc.getState(context);
    return state.fab(context, accessState);
  }
}

class \${id}ListWidgetState extends State<\${id}ListWidget> {
  \${id}ListBloc bloc;

  @override
  void didChangeDependencies() {
    bloc = BlocProvider.of<\${id}ListBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose () {
    if (bloc != null) bloc.close();
    super.dispose();
  }

  @override
  Widget fab(BuildContext aContext, AccessState accessState) {
    if (accessState is AppLoaded) {
      return !accessState.memberIsOwner() \${allowAddItemsCondition}
        ? null
        :FloatingActionButton(
        heroTag: "\${id}FloatBtnTag",
        foregroundColor: RgbHelper.color(rgbo: accessState.app.floatingButtonForegroundColor),
        backgroundColor: RgbHelper.color(rgbo: accessState.app.floatingButtonBackgroundColor),
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            pageRouteBuilder(accessState.app, page: BlocProvider.value(
                value: bloc,
                child: \${id}Form(
                    value: null,
                    formAction: FormAction.AddAction)
            )),
          );
        },
      );
    } else {
      return Text('App not loaded');
    }
  }

  @override
  Widget build(BuildContext context) {
    var accessState = AccessBloc.getState(context);
    if (accessState is AppLoaded) {
      return BlocBuilder<\${id}ListBloc, \${id}ListState>(builder: (context, state) {
        if (state is \${id}ListLoading) {
          return Center(
            child: DelayedCircularProgressIndicator(),
          );
        } else if (state is \${id}ListLoaded) {
          final values = state.values;
          if ((widget.isEmbedded != null) && (widget.isEmbedded)) {
            List<Widget> children = List();
            children.add(theList(context, values, accessState));
            children.add(RaisedButton(
                    color: RgbHelper.color(rgbo: accessState.app.formSubmitButtonColor),
                    onPressed: () {
                      Navigator.of(context).push(
                                pageRouteBuilder(accessState.app, page: BlocProvider.value(
                                    value: bloc,
                                    child: \${id}Form(
                                        value: null,
                                        formAction: FormAction.AddAction)
                                )),
                              );
                    },
                    child: Text('Add', style: TextStyle(color: RgbHelper.color(rgbo: accessState.app.formSubmitButtonTextColor))),
                  ));
            return ListView(
              padding: const EdgeInsets.all(8),
              physics: ScrollPhysics(),
              shrinkWrap: true,
              children: children
            );
          } else {
            return theList(context, values, accessState);
          }
        } else {
          return Center(
            child: DelayedCircularProgressIndicator(),
          );
        }
      });
    } else {
      return Text("App not loaded");
    } 
  }
  
  Widget theList(BuildContext context, values, AppLoaded accessState) {
    return Container(
      decoration: widget.listBackground == null ? BoxDecorationHelper.boxDecoration(accessState, accessState.app.listBackground) : BoxDecorationHelper.boxDecoration(accessState, widget.listBackground),
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: RgbHelper.color(rgbo: accessState.app.dividerColor)
        ),
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values[index];
\${_listItemVariations}
          return \${id}ListItem(
            value: value,
            app: accessState.app,
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
             \${onTap}
            },
          );
        }
      ));
  }
  
  
  Widget getForm(value, action) {
    if (widget.form == null) {
      return \${id}Form(value: value, formAction: action);
    } else {
\${_formVariations}
    }
  }
  
  
}

""";
