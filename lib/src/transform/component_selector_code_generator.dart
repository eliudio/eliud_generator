import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _code = """
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/style/style_registry.dart';

import 'abstract_repository_singleton.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import '\${path}_list_bloc.dart';
import '\${path}_list_event.dart';
import '\${path}_list_state.dart';
import '\${path}_model.dart';

class \${id}ComponentSelector extends ComponentSelector {
  @override
  Widget createSelectWidget(BuildContext context, double height,
      SelectComponent selected, editorConstructor) {
    var appId = AccessBloc.currentAppId(context);
    return BlocProvider<\${id}ListBloc>(
          create: (context) => \${id}ListBloc(
            \${lid}Repository:
                \${lid}Repository(appId: appId)!,
          )..add(Load\${id}List()),
      child: Select\${id}Widget(
          height: height,
          selected: selected,
          editorConstructor: editorConstructor),
    );
  }
}

class Select\${id}Widget extends StatefulWidget {
  final double height;
  final SelectComponent selected;
  final ComponentEditorConstructor editorConstructor;

  const Select\${id}Widget(
      {Key? key,
      required this.height,
      required this.selected,
      required this.editorConstructor})
      : super(key: key);

  @override
  _Select\${id}WidgetState createState() {
    return _Select\${id}WidgetState();
  }
}

class _Select\${id}WidgetState extends State<Select\${id}Widget> {
  Widget theList(BuildContext context, List<\${id}Model?> values) {
    return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values[index];
          if (value != null) {
            return getListTile(
              context,
              trailing: PopupMenuButton<int>(
                  child: Icon(Icons.more_vert),
                  elevation: 10,
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: text(context, 'Add to page'),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: text(context, 'Update'),
                        ),
                      ],
                  onSelected: (selectedValue) {
                    if (selectedValue == 1) {
                      widget.selected(value.documentID!);
                    } else if (selectedValue == 2) {
                      widget.editorConstructor.updateComponent(context, value, (_) {});
                    }
                  }),
              title: \${title},
              subtitle: \${subtitle},
            );
          } else {
            return Container();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<\${id}ListBloc, \${id}ListState>(
        builder: (context, state) {
      if (state is \${id}ListLoading) {
        return progressIndicator(context);
      } else if (state is \${id}ListLoaded) {
        if (state.values == null) {
          return text(context, 'No items');
        } else {
          var children = <Widget>[];
          children.add(Container(
              height: widget.height - 45,
              child: theList(
                context,
                state.values!,
              )));
          children.add(Column(children: [
            divider(context),
            Center(
                child: iconButton(
              context,
              onPressed: () {
                widget.editorConstructor.createNewComponent(context, (_) {});
              },
              icon: Icon(Icons.add),
            ))
          ]));
          return ListView(
              physics: ScrollPhysics(), shrinkWrap: true, children: children);
        }
      }
      return Text("nothing");
    });
  }
}


""";

class ComponentSelectorCodeGenerator extends CodeGenerator {
  ComponentSelectorCodeGenerator ({required ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String theFileName() {
    return modelSpecifications.listFileName();
  }

  Map<String, String> parameters(ModelSpecification modelSpecification) => <String, String>{
    '\${id}': modelSpecifications.id,
    '\${lid}': firstLowerCase(modelSpecifications.id),
    '\${title}': modelSpecifications.listFields.getTitle(),
    '\${subtitle}': modelSpecifications.listFields.getSubTitle(),
    '\${path}': camelcaseToUnderscore(modelSpecifications.id),
  };

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_code, parameters: parameters(modelSpecifications)));
    return codeBuffer.toString();
  }

  @override
  String commonImports() {
    return '';
  }
}
