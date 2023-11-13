import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _code = """
import 'dart:math';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
import 'package:eliud_core/model/app_model.dart';
import 'package:eliud_core/style/frontend/has_button.dart';
import 'package:eliud_core/style/frontend/has_divider.dart';
import 'package:eliud_core/style/frontend/has_list_tile.dart';
import 'package:eliud_core/style/frontend/has_progress_indicator.dart';
import 'package:eliud_core/style/frontend/has_tabs.dart';
import 'package:eliud_core/style/frontend/has_text.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/style/style_registry.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_core/tools/query/query_tools.dart';

import 'abstract_repository_singleton.dart';
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';
import '\${path}_list_bloc.dart';
import '\${path}_list_event.dart';
import '\${path}_list_state.dart';
import '\${path}_model.dart';

/* 
 * \${id}ComponentSelector is a component selector for \${id}, allowing to select a \${id} component
 */
class \${id}ComponentSelector extends ComponentSelector {

  /* 
   * createSelectWidget creates the widget
   */
  @override
  Widget createSelectWidget(BuildContext context, AppModel app, int privilegeLevel, double height,
      SelectComponent selected, editor) {
    var appId = app.documentID;
    return BlocProvider<\${id}ListBloc>(
          create: (context) => \${id}ListBloc(
          eliudQuery: getComponentSelectorQuery(0, app.documentID),
          \${lid}Repository:
              \${lid}Repository(appId: appId)!,
          )..add(Load\${id}List()),
      child: _Select\${id}Widget(app: app,
          height: height,
          containerPrivilege: privilegeLevel,
          selected: selected,
          editorConstructor: editor),
    );
  }
}

/* 
 * _Select\${id}Widget 
 */
class _Select\${id}Widget extends StatefulWidget {
  final AppModel app;
  final double height;
  final SelectComponent selected;
  final int containerPrivilege;
  final ComponentEditorConstructor editorConstructor;

  const _Select\${id}Widget(
      {Key? key,
      required this.app,
      required this.containerPrivilege,
      required this.height,
      required this.selected,
      required this.editorConstructor})
      : super(key: key);

  @override
  State<_Select\${id}Widget> createState() {
    return _Select\${id}WidgetState();
  }
}

class _Select\${id}WidgetState extends State<_Select\${id}Widget> with TickerProviderStateMixin {
  TabController? _privilegeTabController;
  final List<String> _privilegeItems = ['No', 'L1', 'L2', 'Owner'];
  final int _initialPrivilege = 0;
  int _currentPrivilege = 0;

  @override
  void initState() {
    var _privilegeASize = _privilegeItems.length;
    _privilegeTabController =
        TabController(vsync: this, length: _privilegeASize);
    _privilegeTabController!.addListener(_handlePrivilegeTabSelection);
    _privilegeTabController!.index = _initialPrivilege;

    super.initState();
  }

  @override
  void dispose() {
    if (_privilegeTabController != null) {
      _privilegeTabController!.dispose();
    }
    super.dispose();
  }

  void _handlePrivilegeTabSelection() {
    if ((_privilegeTabController != null) &&
        (_privilegeTabController!.indexIsChanging)) {
        _currentPrivilege = _privilegeTabController!.index;
        BlocProvider.of<\${id}ListBloc>(context).add(
            \${id}ChangeQuery(newQuery: getComponentSelectorQuery(_currentPrivilege, widget.app.documentID)));
    }
  }

  Widget theList(BuildContext context, List<\${id}Model?> values) {
    var app = widget.app; 
    return ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: values.length,
        itemBuilder: (context, index) {
          final value = values[index];
          if (value != null) {
            return getListTile(
              context,
              widget.app,
              trailing: PopupMenuButton<int>(
                  child: Icon(Icons.more_vert),
                  elevation: 10,
                  itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: text(widget.app, context, 'Add to page'),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: text(widget.app, context, 'Update'),
                        ),
                      ],
                  onSelected: (selectedValue) {
                    if (selectedValue == 1) {
                      widget.selected(value.documentID);
                    } else if (selectedValue == 2) {
                      widget.editorConstructor.updateComponent(widget.app, context, value, (_, __) {});
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
      var children = <Widget>[];
      var newPrivilegeItems = <Widget>[];
      int i = 0;
      for (var privilegeItem in _privilegeItems) {
        newPrivilegeItems.add(Wrap(children: [(i <= widget.containerPrivilege) ? Icon(Icons.check) : Icon(Icons.close), Container(width: 2), text(widget.app, context, privilegeItem)]));
        i++;
      }
      children.add(tabBar2(widget.app, context,
          items: newPrivilegeItems, tabController: _privilegeTabController!));
      if ((state is \${id}ListLoaded) && (state.values != null)) {
        children.add(Container(
            height: max(30, widget.height - 101),
            child: theList(
              context,
              state.values!,
            )));
      } else {
        children.add(Container(
            height: max(30, widget.height - 101),
            ));
      }
      children.add(Column(children: [
        divider(widget.app, context),
        Center(
            child: iconButton(widget.app, 
          context,
          onPressed: () {
            widget.editorConstructor.createNewComponent(widget.app, context, (_, __) {});
          },
          icon: Icon(Icons.add),
        ))
      ]));
      return ListView(
          physics: ScrollPhysics(), shrinkWrap: true, children: children);
    });
  }
}


""";

class ComponentSelectorCodeGenerator extends CodeGenerator {
  ComponentSelectorCodeGenerator({required super.modelSpecifications});

  @override
  String theFileName() {
    return modelSpecifications.listFileName();
  }

  Map<String, String> parameters(ModelSpecification modelSpecification) =>
      <String, String>{
        '\${id}': modelSpecifications.id,
        '\${lid}': firstLowerCase(modelSpecifications.id),
        '\${title}': modelSpecifications.listFields == null
            ? ""
            : modelSpecifications.listFields!.getTitle(),
        '\${subtitle}': modelSpecifications.listFields == null
            ? ""
            : modelSpecifications.listFields!.getSubTitle(),
        '\${path}': camelcaseToUnderscore(modelSpecifications.id),
      };

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer
        .writeln(process(_code, parameters: parameters(modelSpecifications)));
    return codeBuffer.toString();
  }

  @override
  String commonImports() {
    return '';
  }
}
