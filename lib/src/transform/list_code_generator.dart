import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _imports(String packageName) => """
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/core/blocs/access/state/access_state.dart';
import 'package:eliud_core/core/blocs/access/state/access_determined.dart';
import 'package:eliud_core/style/style_registry.dart';
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
                        pageRouteBuilder(AccessBloc.currentApp(context), page: BlocProvider.value(
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

    parameters["\${onTap}"] = tap;
    parameters["\${_formVariations}"] = _formVariations;
    return process(_listBody, parameters: parameters);
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
    codeBuffer.writeln(spaces(4) + "Key? key,");
    codeBuffer.writeln(spaces(4) + "required this.onDismissed,");
    codeBuffer.writeln(spaces(4) + "required this.onTap,");
    codeBuffer.writeln(spaces(4) + "required this.value,");
    codeBuffer.writeln(spaces(2) + "}) : super(key: key);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "return Dismissible(");
    codeBuffer.writeln(spaces(6) + "key: Key('__" + modelSpecifications.id + "_item_\${value.documentID}'),");
    codeBuffer.writeln(spaces(6) + "onDismissed: onDismissed,");
    codeBuffer.writeln(spaces(6) + "child: ListTile(");
    codeBuffer.writeln(spaces(8) + "onTap: onTap,");

    String title = modelSpecifications.listFields.title;
    if (title != null) {
      codeBuffer.writeln(spaces(8) + "title: $title,");
    }
    String subTitle = modelSpecifications.listFields.subTitle;
    if (subTitle != null) {
      codeBuffer.writeln(spaces(8) + "subtitle: $subTitle,");
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

typedef \${id}WidgetProvider(\${id}Model? value);

class \${id}ListWidget extends StatefulWidget with HasFab {
  BackgroundModel? listBackground;
  \${id}WidgetProvider? widgetProvider;
  bool? readOnly;
  String? form;
  \${id}ListWidgetState? state;
  bool? isEmbedded;

  \${id}ListWidget({ Key? key, this.readOnly, this.form, this.widgetProvider, this.isEmbedded, this.listBackground }): super(key: key);

  @override
  \${id}ListWidgetState createState() {
    state ??= \${id}ListWidgetState();
    return state!;
  }

  @override
  Widget? fab(BuildContext context) {
    if ((readOnly != null) && readOnly!) return null;
    state ??= \${id}ListWidgetState();
    var accessState = AccessBloc.getState(context);
    return state!.fab(context, accessState);
  }
}

class \${id}ListWidgetState extends State<\${id}ListWidget> {
  @override
  Widget? fab(BuildContext aContext, AccessState accessState) {
    return !accessState.memberIsOwner(AccessBloc.currentAppId(context)) \${allowAddItemsCondition}
      ? null
      : StyleRegistry.registry().styleWithContext(context).adminListStyle().floatingActionButton(context, 'PageFloatBtnTag', Icon(Icons.add),
      onPressed: () {
        Navigator.of(context).push(
          pageRouteBuilder(AccessBloc.currentApp(context), page: BlocProvider.value(
              value: BlocProvider.of<\${id}ListBloc>(context),
              child: \${id}Form(
                  value: null,
                  formAction: FormAction.AddAction)
          )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessBloc, AccessState>(
        builder: (context, accessState) {
      if (accessState is AccessDetermined) {
        return BlocBuilder<\${id}ListBloc, \${id}ListState>(builder: (context, state) {
          if (state is \${id}ListLoading) {
            return StyleRegistry.registry().styleWithContext(context).adminListStyle().progressIndicator(context);
          } else if (state is \${id}ListLoaded) {
            final values = state.values;
            if ((widget.isEmbedded != null) && widget.isEmbedded!) {
              var children = <Widget>[];
              children.add(theList(context, values, accessState));
              children.add(
                  StyleRegistry.registry().styleWithContext(context).adminFormStyle().button(
                      context, label: 'Add',
                      onPressed: () {
                        Navigator.of(context).push(
                                  pageRouteBuilder(accessState.currentApp, page: BlocProvider.value(
                                      value: BlocProvider.of<\${id}ListBloc>(context),
                                      child: \${id}Form(
                                          value: null,
                                          formAction: FormAction.AddAction)
                                  )),
                                );
                      },
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
            return StyleRegistry.registry().styleWithContext(context).adminListStyle().progressIndicator(context);
          }
        });
      } else {
        return StyleRegistry.registry().styleWithContext(context).adminListStyle().progressIndicator(context);
      }
    });
  }
  
  Widget theList(BuildContext context, values, AccessState accessState) {
    return Container(
      decoration: widget.listBackground == null ? StyleRegistry.registry().styleWithContext(context).adminListStyle().boxDecorator(context, accessState.getMember()) : BoxDecorationHelper.boxDecoration(accessState.getMember(), widget.listBackground),
      child: ListView.separated(
        separatorBuilder: (context, index) => StyleRegistry.registry().styleWithContext(context).adminListStyle().divider(context),
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values[index];
          
          if (widget.widgetProvider != null) return widget.widgetProvider!(value);

          return \${id}ListItem(
            value: value,
//            app: accessState.app,
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
  
  
  Widget? getForm(value, action) {
    if (widget.form == null) {
      return \${id}Form(value: value, formAction: action);
    } else {
\${_formVariations}
    }
  }
  
  
}

""";
