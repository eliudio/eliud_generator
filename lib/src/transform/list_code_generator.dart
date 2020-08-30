import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _imports = """
import 'package:eliud_core/core/global_data.dart';
import 'package:eliud_core/tools/has_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/tools/screen_size.dart';

import 'package:eliud_core/tools/delete_snackbar.dart';
import 'package:eliud_core/tools/router_builders.dart';
import 'package:eliud_core/tools/etc.dart';
import 'package:eliud_core/tools/enums.dart';
import 'package:eliud_core/eliud.dart';

import '\${importprefix}_list_event.dart';
import '\${importprefix}_list_state.dart';
import '\${importprefix}_list_bloc.dart';
import '\${importprefix}_model.dart';

""";

String _importForms = """
import '\${importprefix}_form.dart';
""";

String _onTap = """
                      final removedItem = await Navigator.of(context).push(
                        pageRouteBuilder(page: BlocProvider.value(
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


String _listBody = """
class \${id}ListWidget extends StatefulWidget with HasFab {
  bool readOnly;
  String form;
  \${id}ListWidgetState state;

  \${id}ListWidget({ Key key, this.readOnly, this.form }): super(key: key);

  @override
  \${id}ListWidgetState createState() {
    state ??= \${id}ListWidgetState();
    return state;
  }

  Widget fab(BuildContext context) {
    if ((readOnly != null) && readOnly) return null;
    state ??= \${id}ListWidgetState();
    return state.fab(context);
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
  Widget fab(BuildContext aContext) {
    return !GlobalData.memberIsOwner() \${allowAddItemsCondition} 
        ? null
        :FloatingActionButton(
      heroTag: "\${id}FloatBtnTag",
      foregroundColor: RgbHelper.color(rgbo: GlobalData.app().floatingButtonForegroundColor),
      backgroundColor: RgbHelper.color(rgbo: GlobalData.app().floatingButtonBackgroundColor),
      child: Icon(Icons.add),
      onPressed: () {
        Navigator.of(context).push(
          pageRouteBuilder(page: BlocProvider.value(
              value: bloc,
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
    return BlocBuilder<\${id}ListBloc, \${id}ListState>(builder: (context, state) {
      if (state is \${id}ListLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else if (state is \${id}ListLoaded) {
        final values = state.values;
        return Container(
                 decoration: BoxDecorationHelper.boxDecoration(GlobalData.app().listBackground),
                 child: ListView.separated(
                   separatorBuilder: (context, index) => Divider(
                     color: RgbHelper.color(rgbo: GlobalData.app().dividerColor)
                   ),
                   shrinkWrap: true,
                   physics: ScrollPhysics(),
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
                       \${onTap}
                       },
                     );
                   }
               ));
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    });
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

class ListCodeGenerator extends CodeGenerator {
  ListCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    return process(_imports, parameters: <String, String>{
      "\${importprefix}": camelcaseToUnderscore(modelSpecifications.id)
    })
    + (modelSpecifications.generate.generateForm ? process(_importForms, parameters: <String, String>{
      "\${importprefix}": camelcaseToUnderscore(modelSpecifications.id),
    }) : "");
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
    codeBuffer.writeln(spaces(12) + "width: fullScreenWidth(context),");
    if (modelSpecifications.listFields.imageTitle) {
      codeBuffer.writeln(spaces(12) + "child: Center( child: ImageHelper.getImageFromImageModel(imageModel: value." + title + ", width: fullScreenWidth(context)))");
    } else {
      codeBuffer.writeln(spaces(12) + "child: Center(child: Text(");
      codeBuffer.writeln(spaces(14) + "value." + title + ",");
      codeBuffer.writeln(
          spaces(14) + "style: TextStyle(color: RgbHelper.color(rgbo: GlobalData.app().listTextItemColor)),");
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
            spaces(10) + "style: TextStyle(color: RgbHelper.color(rgbo: GlobalData.app().listTextItemColor)),");
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
