import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/group.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _imports(String packageName, List<String>? depends) =>
    """import 'package:eliud_core_main/model/app_model.dart';
import '../tools/bespoke_models.dart';
import 'package:eliud_core_main/apis/action_api/action_model.dart';

import 'package:eliud_core_main/apis/apis.dart';

import 'package:eliud_core_helpers/etc/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:eliud_core_helpers/helpers/common_tools.dart';
import 'package:eliud_core_main/apis/style/style_registry.dart';
import 'package:eliud_core_main/apis/style/admin/admin_form_style.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:eliud_core_main/model/internal_component.dart';
import 'package:$packageName/model/embedded_component.dart';
import 'package:$packageName/tools/bespoke_formfields.dart';
import 'package:eliud_core_main/tools/bespoke_formfields.dart';

import 'package:eliud_core_helpers/etc/enums.dart';
import 'package:eliud_core_main/tools/etc/etc.dart';

${base_imports(packageName, repo: true, model: true, entity: true, embeddedComponent: true, depends: depends)}""";

String _specificImports(String packageName) => """
import 'package:$packageName/model/\${path}_list_bloc.dart';
import 'package:$packageName/model/\${path}_list_event.dart';
import 'package:$packageName/model/\${path}_model.dart';
import 'package:$packageName/model/\${path}_form_bloc.dart';
import 'package:$packageName/model/\${path}_form_event.dart';
import 'package:$packageName/model/\${path}_form_state.dart';

""";

const String _xyzFormString = """
class \${className}Form extends StatelessWidget {
  final AppModel app;
  final FormAction formAction;
  final \${id}Model? value;
  final ActionModel? submitAction;

  \${className}Form({Key? key, required this.app, required this.formAction, required this.value, this.submitAction}) : super(key: key);

  /// Build the \${className}Form
  @override
  Widget build(BuildContext context) {
    //var accessState = AccessBloc.getState(context);
    var appId = app.documentID;
    if (formAction == FormAction.showData) {
      return BlocProvider<\${id}FormBloc >(
            create: (context) => \${id}FormBloc(appId,
                                       \${constructorParameters}
                                                )..add(Initialise\${id}FormEvent(value: value)),
  
        child: _My\${className}Form(app:app, submitAction: submitAction, formAction: formAction),
          );
    } if (formAction == FormAction.showPreloadedData) {
      return BlocProvider<\${id}FormBloc >(
            create: (context) => \${id}FormBloc(appId,
                                       \${constructorParameters}
                                                )..add(Initialise\${id}FormNoLoadEvent(value: value)),
  
        child: _My\${className}Form(app:app, submitAction: submitAction, formAction: formAction),
          );
    } else {
      return Scaffold(
        appBar: StyleRegistry.registry().styleWithApp(app).adminFormStyle().appBarWithString(app, context, title: formAction == FormAction.updateAction ? '\${updateTitle}' : '\${addTitle}'),
        body: BlocProvider<\${id}FormBloc >(
            create: (context) => \${id}FormBloc(appId,
                                       \${constructorParameters}
                                                )..add((formAction == FormAction.updateAction ? Initialise\${id}FormEvent(value: value) : InitialiseNew\${id}FormEvent())),
  
        child: _My\${className}Form(app: app, submitAction: submitAction, formAction: formAction),
          ));
    }
  }
}

""";

const String _myXyzFormString = """
class _My\${className}Form extends StatefulWidget {
  final AppModel app;
  final FormAction? formAction;
  final ActionModel? submitAction;

  _My\${className}Form({required this.app, this.formAction, this.submitAction});

  State<_My\${className}Form> createState() => _My\${className}FormState(this.formAction);
}

""";

const _groupFieldHeaderString = """
        \${condition} children.add(Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: StyleRegistry.registry().styleWithApp(widget.app).adminFormStyle().groupTitle(widget.app, context, '\${label}')
                ));
""";

const _otherChangedString = """
  void _on\${upperFieldName}Changed(value) {
    _myFormBloc.add(Changed\${id}\${upperFieldName}(value: value));
    \${setState}
  }

""";

const _xyzSetEnumSelectionString = """
  void setSelection\${upperFieldName}(int? val) {
    setState(() {
      _\${lowerFieldName}SelectedRadioTile = val;
    });
    _myFormBloc.add(Changed\${id}\${upperFieldName}(value: to\${fieldType}(val)));
  }

""";

const _xyzSetBooleanSelectionString = """
  void setSelection\${upperFieldName}(bool? val) {
    setState(() {
      _\${lowerFieldName}Selection = val;
    });
    _myFormBloc.add(Changed\${id}\${upperFieldName}(value: val));
  }
""";

const _xyzLookupChangedString = """
  void _on\${upperFieldName}Selected(String? val) {
    setState(() {
      _\${lowerFieldName} = val;
    });
    _myFormBloc.add(Changed\${id}\${upperFieldName}(value: val));
  }

""";

const String _readOnlyMethodMember = """
  /// Is the form read-only?
  bool _readOnly(BuildContext context, \${id}FormInitialized state) {
    return (formAction == FormAction.showData) || (formAction == FormAction.showPreloadedData) || (!((Apis.apis().getCoreApi().isLoggedIn(context)) && (Apis.apis().getCoreApi().currentMemberId(context) == state.value!.documentID)));
  }
  
""";

const String _readOnlyMethod = """
  /// Is the form read-only?
  bool _readOnly(BuildContext context, \${id}FormInitialized state) {
    return (formAction == FormAction.showData) || (formAction == FormAction.showPreloadedData) || (!Apis.apis().getCoreApi().memberIsOwner(context, widget.app.documentID));
  }
  
""";

class RealFormCodeGenerator extends CodeGenerator {
  final String className;
  final String? title;
  final String? buttonLabel;

  RealFormCodeGenerator(this.className,
      {this.title, this.buttonLabel, required super.modelSpecifications});

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(process(_imports(
        modelSpecifications.packageName, modelSpecifications.depends)));
    headerBuffer.writeln(process(
        _specificImports(modelSpecifications.packageName),
        parameters: <String, String>{
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
      "\${updateTitle}":
          title == null ? "Update ${modelSpecifications.id}" : title!,
      "\${addTitle}": title == null ? "Add ${modelSpecifications.id}" : title!,
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
    codeBuffer.writeln("${spaces(2)}final FormAction? formAction;");
    codeBuffer.writeln(
        "${spaces(2)}late ${modelSpecifications.id}FormBloc _myFormBloc;");
    return codeBuffer.toString();
  }

  String _xyzFormStateFieldMemberData() {
    StringBuffer codeBuffer = StringBuffer();
    for (var field in modelSpecifications.fields) {
      if (field.bespokeFormField == null) {
        if (!field.isHidden()) {
          switch (field.formFieldType()) {
            case FormTypeField.EntryField:
              codeBuffer.writeln(
                  "${spaces(2)}final TextEditingController _${field.fieldName}Controller = TextEditingController();");
              break;
            case FormTypeField.CheckBox:
              codeBuffer
                  .writeln("${spaces(2)}bool? _${field.fieldName}Selection;");
              break;
            case FormTypeField.Lookup:
              codeBuffer.writeln("${spaces(2)}String? _${field.fieldName};");
              break;
            case FormTypeField.Selection:
              codeBuffer.writeln(
                  "${spaces(2)}int? _${field.fieldName}SelectedRadioTile;");
              break;
            case FormTypeField.List:
              // Support private data members for list
              break;
            case FormTypeField.Unsupported:
              // Ignore
              break;
          }
        }
      }
    }
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _xyzFormStateConstructor() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer
        .writeln("${spaces(2)}_My${className}FormState(this.formAction);");
    return codeBuffer.toString();
  }

  String _xyzFormStateInitState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("${spaces(2)}@override");
    codeBuffer.writeln("${spaces(2)}void initState() {");
    codeBuffer.writeln("${spaces(4)}super.initState();");
    codeBuffer.writeln(
        "${spaces(4)}_myFormBloc = BlocProvider.of<${modelSpecifications.id}FormBloc>(context);");
    for (var field in modelSpecifications.fields) {
      if (field.bespokeFormField == null) {
        if (!field.isHidden()) {
          switch (field.formFieldType()) {
            case FormTypeField.EntryField:
              codeBuffer.writeln(
                  "${spaces(4)}_${field.fieldName}Controller.addListener(_on${firstUpperCase(field.fieldName)}Changed);");
              break;
            case FormTypeField.CheckBox:
              codeBuffer
                  .writeln("${spaces(4)}_${field.fieldName}Selection = false;");
              break;
            case FormTypeField.Lookup:
              break;
            case FormTypeField.Selection:
              codeBuffer.writeln(
                  "${spaces(4)}_${field.fieldName}SelectedRadioTile = 0;");
              break;
            case FormTypeField.List:
              break;
            case FormTypeField.Unsupported:
              // Ignore
              break;
          }
        }
      }
    }
    codeBuffer.writeln("${spaces(2)}}");
    return codeBuffer.toString();
  }

  String _xyzFormStateBuild() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("${spaces(2)}@override");
    codeBuffer.writeln("${spaces(2)}Widget build(BuildContext context) {");

    // start blocbuilder
    codeBuffer.writeln(
        "${spaces(4)}return BlocBuilder<${modelSpecifications.id}FormBloc, ${modelSpecifications.id}FormState>(builder: (context, state) {");

    // state is ...Uninitialized
    codeBuffer.writeln(
        "${spaces(6)}if (state is ${modelSpecifications.id}FormUninitialized) return Center(");
    codeBuffer.writeln(
        "${spaces(8)}child: StyleRegistry.registry().styleWithApp(widget.app).adminListStyle().progressIndicator(widget.app, context),");
    codeBuffer.writeln("${spaces(6)});");
    codeBuffer.writeln();

    // state is ...FormLoaded
    codeBuffer.writeln(
        "${spaces(6)}if (state is ${modelSpecifications.id}FormLoaded) {");
    for (var field in modelSpecifications.fields) {
      if (field.bespokeFormField == null) {
        if (!field.isHidden()) {
          switch (field.formFieldType()) {
            case FormTypeField.EntryField:
              if (field.isOptional()) {
                codeBuffer.writeln(
                    "${spaces(8)}if (state.value!.${field.fieldName} != null)");
                codeBuffer.writeln(
                    "${spaces(10)}_${field.fieldName}Controller.text = state.value!.${field.fieldName}.toString();");
                codeBuffer.writeln("${spaces(8)}else");
                codeBuffer.writeln(
                    "${spaces(10)}_${field.fieldName}Controller.text = \"\";");
              } else {
                codeBuffer.writeln(
                    "${spaces(8)}_${field.fieldName}Controller.text = state.value!.${field.fieldName}.toString();");
              }
              break;
            case FormTypeField.CheckBox:
              codeBuffer.writeln(
                  "${spaces(8)}if (state.value!.${field.fieldName} != null)");
              codeBuffer.writeln(
                  "${spaces(8)}_${field.fieldName}Selection = state.value!.${field.fieldName};");
              codeBuffer.writeln("${spaces(8)}else");
              codeBuffer
                  .writeln("${spaces(8)}_${field.fieldName}Selection = false;");
              break;
            case FormTypeField.Lookup:
              codeBuffer.writeln(
                  "${spaces(8)}if (state.value!.${field.fieldName} != null)");
              codeBuffer.writeln(
                  "${spaces(10)}_${field.fieldName}= state.value!.${field.fieldName}!.documentID;");
              codeBuffer.writeln("${spaces(8)}else");
              codeBuffer.writeln("${spaces(10)}_${field.fieldName}= \"\";");
              break;
            case FormTypeField.Selection:
              codeBuffer.writeln(
                  "${spaces(8)}if (state.value!.${field.fieldName} != null)");
              codeBuffer.writeln(
                  "${spaces(10)}_${field.fieldName}SelectedRadioTile = state.value!.${field.fieldName}!.index;");
              codeBuffer.writeln("${spaces(8)}else");
              codeBuffer.writeln(
                  "${spaces(10)}_${field.fieldName}SelectedRadioTile = 0;");
              break;
            case FormTypeField.List:
              // Initialise support private data members for list
              break;
            case FormTypeField.Unsupported:
              // Ignore
              break;
          }
        }
      }
    }
    codeBuffer.writeln("${spaces(6)}}");

    codeBuffer.writeln(
        "${spaces(6)}if (state is ${modelSpecifications.id}FormInitialized) {");

    codeBuffer.writeln("${spaces(8)}List<Widget> children = [];");

    if (modelSpecifications.groups == null) {
      codeBuffer.writeln(_fields(modelSpecifications.fields));
    } else {
      if (modelSpecifications.hasUngroupedFields()) {
        codeBuffer.writeln(_groupedFieldsFor(
            "General", null, modelSpecifications.unGroupedFields()));
      }
      for (var group in modelSpecifications.groups!) {
        codeBuffer.writeln(_groupedFieldsFor(group.getDescription(),
            group.conditional, modelSpecifications.fieldsForGroups(group)));
      }
    }

    codeBuffer.writeln(
        "${spaces(8)}if ((formAction != FormAction.showData) && (formAction != FormAction.showPreloadedData))");
    codeBuffer.writeln(
        "${spaces(10)}children.add(StyleRegistry.registry().styleWithApp(widget.app).adminFormStyle().button(widget.app, context, label: 'Submit',");
    codeBuffer.writeln(
        "${spaces(18)}onPressed: _readOnly(context, state) ? null : () {");
    codeBuffer.writeln(
        "${spaces(14 + 6)}if (state is ${modelSpecifications.id}FormError) {");
    codeBuffer.writeln("${spaces(14 + 8)}return null;");
    codeBuffer.writeln("${spaces(14 + 6)}} else {");
    codeBuffer.writeln(
        "${spaces(14 + 8)}if (formAction == FormAction.updateAction) {");
    codeBuffer.writeln(
        "${spaces(14 + 10)}BlocProvider.of<${modelSpecifications.id}ListBloc>(context).add(");
    codeBuffer.writeln(
        "${spaces(14 + 12)}Update${modelSpecifications.id}List(value: state.value!.copyWith(");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        codeBuffer.writeln(
            "${spaces(14 + 16)}${field.fieldName}: state.value!.${field.fieldName}, ");
      }
    }
    codeBuffer.writeln("${spaces(14 + 10)})));");
    codeBuffer.writeln("${spaces(14 + 8)}} else {");
    codeBuffer.writeln(
        "${spaces(14 + 10)}BlocProvider.of<${modelSpecifications.id}ListBloc>(context).add(");
    codeBuffer.writeln(
        "${spaces(14 + 12)}Add${modelSpecifications.id}List(value: ${modelSpecifications.modelClassName()}(");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        codeBuffer.writeln(
            "${spaces(14 + 16)}${field.fieldName}: state.value!.${field.fieldName}, ");
      }
    }
    codeBuffer.writeln("${spaces(14 + 12)})));");
    codeBuffer.writeln("${spaces(14 + 8)}}");

    codeBuffer.writeln("${spaces(14 + 8)}if (widget.submitAction != null) {");
    codeBuffer.writeln(
        "${spaces(14 + 10)}Apis.apis().getRouterApi().navigateTo(context, widget.submitAction!);");
    codeBuffer.writeln("${spaces(14 + 8)}} else {");
    codeBuffer.writeln("${spaces(14 + 10)}Navigator.pop(context);");
    codeBuffer.writeln("${spaces(14 + 8)}}");

    codeBuffer.writeln("${spaces(14 + 6)}}");

    codeBuffer.writeln("${spaces(18)}},");
    codeBuffer.writeln("${spaces(16)}));");

    codeBuffer.writeln();
    codeBuffer.writeln(
        "${spaces(8)}return StyleRegistry.registry().styleWithApp(widget.app).adminFormStyle().container(widget.app, context, Form(");

    codeBuffer.writeln("${spaces(12)}child: ListView(");
    codeBuffer.writeln("${spaces(14)}padding: const EdgeInsets.all(8),");
    codeBuffer.writeln(
        "${spaces(14)}physics: ((formAction == FormAction.showData) || (formAction == FormAction.showPreloadedData)) ? NeverScrollableScrollPhysics() : null,");
    codeBuffer.writeln(
        "${spaces(14)}shrinkWrap: ((formAction == FormAction.showData) || (formAction == FormAction.showPreloadedData)),");
    codeBuffer.writeln("${spaces(14)}children: children as List<Widget>");
    codeBuffer.writeln("${spaces(12)}),");
    codeBuffer.writeln("${spaces(10)}), formAction!");
    codeBuffer.writeln("${spaces(8)});");

    codeBuffer.writeln("${spaces(6)}} else {");
    codeBuffer.writeln(
        "${spaces(8)}return StyleRegistry.registry().styleWithApp(widget.app).adminListStyle().progressIndicator(widget.app, context);");
    codeBuffer.writeln("${spaces(6)}}");
    // close blocbuilder
    codeBuffer.writeln("${spaces(4)}});");

    // close method
    codeBuffer.writeln("${spaces(2)}}");
    return codeBuffer.toString();
  }

  String _groupedFieldHeader(String groupLabel, String? condition) {
    String conditionStr = "";
    if (condition != null) conditionStr = "if $condition";
    return process(_groupFieldHeaderString, parameters: <String, String>{
      "\${label}": groupLabel,
      "\${condition}": conditionStr
    });
  }

  String _groupedFieldFooter() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("${spaces(8)}children.add(Container(height: 20.0));");
    codeBuffer.writeln(
        "${spaces(8)}children.add(StyleRegistry.registry().styleWithApp(widget.app).adminFormStyle().divider(widget.app, context));");
    return codeBuffer.toString();
  }

  String _fieldStart(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    if (field.conditional != null) {
      codeBuffer
          .writeln("${spaces(8)}if (${field.getConditional()}) children.add(");
    } else {
      codeBuffer.writeln("${spaces(8)}children.add(");
    }
    return codeBuffer.toString();
  }

  String _fieldEnd() {
    return "${spaces(10)});";
  }

  String _field(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    if (field.bespokeFormField == null) {
      switch (field.formFieldType()) {
        case FormTypeField.EntryField:
          String readOnlyCondition;
          if (field.fieldName == "documentID") {
            if (modelSpecifications.id == "Member") {
              readOnlyCondition = "true";
            } else {
              readOnlyCondition = "(formAction == FormAction.updateAction)";
            }
          } else {
            readOnlyCondition = "_readOnly(context, state)";
          }

          var controllerName = "_${field.fieldName}Controller";

          var iconName;
          if (field.iconName != null) {
            iconName = field.iconName;
          } else {
            iconName = "text_format";
          }

          var labelName;
          if (field.displayName == null) {
            labelName = field.fieldName;
          } else {
            labelName = field.displayName;
          }

          var hintText;
          if (field.remark != null) hintText = "'field.remark'";

          var keyboardType;
          if (field.isDouble()) {
            keyboardType = "keyboardType: TextInputType.number";
          }
          if (field.isInt()) {
            keyboardType = "keyboardType: TextInputType.number";
          }
          if (field.isString()) {
            keyboardType = "keyboardType: TextInputType.text";
          }

          var validator =
              "(_) => state is ${firstUpperCase(field.fieldName)}${modelSpecifications.id}FormError ? state.message : null";

          codeBuffer.writeln(_fieldStart(field));
          codeBuffer.writeln(
              "${spaces(18)}StyleRegistry.registry().styleWithApp(widget.app).adminFormStyle().textFormField(widget.app, context, labelText: '$labelName', icon: Icons.$iconName, readOnly: $readOnlyCondition, textEditingController: $controllerName, $keyboardType, validator: $validator, hintText: $hintText)");
          codeBuffer.writeln(_fieldEnd());

          break;
        case FormTypeField.CheckBox:
          var title;
          if (field.displayName == null) {
            title = field.fieldName;
          } else {
            title = field.displayName;
          }

          var value = "_${firstLowerCase(field.fieldName)}Selection";

          var onChanged =
              "_readOnly(context, state) ? null : (dynamic val) => setSelection${firstUpperCase(field.fieldName)}(val)";

          codeBuffer.writeln(_fieldStart(field));
          codeBuffer.writeln(
              "${spaces(18)}StyleRegistry.registry().styleWithApp(widget.app).adminFormStyle().checkboxListTile(widget.app, context, '$title', $value, $onChanged)");
          codeBuffer.writeln(_fieldEnd());
          break;
        case FormTypeField.Lookup:
          codeBuffer.writeln(_fieldStart(field));
          bool optionalValue = field.isOptional();
          codeBuffer.writeln(
              "${spaces(16)}DropdownButtonComponentFactory().createNew(app: widget.app, id: \"${firstLowerCase(field.fieldType)}s\", value: _${firstLowerCase(field.fieldName)}, trigger: (value, privilegeLevel) => _on${firstUpperCase(field.fieldName)}Selected(value), optional: $optionalValue),");
          codeBuffer.writeln(_fieldEnd());
          break;

        case FormTypeField.Selection:
          int i = 0;
          if (field.enumValues != null) {
            for (var enumField in field.enumValues!) {
              var onChanged =
                  "!Apis.apis().getCoreApi().memberIsOwner(context, widget.app.documentID) ? null : (dynamic val) => setSelection${firstUpperCase(field.fieldName)}(val)";
              codeBuffer.writeln(_fieldStart(field));
              codeBuffer.writeln(
                  "${spaces(18)}StyleRegistry.registry().styleWithApp(widget.app).adminFormStyle().radioListTile(widget.app, context, $i, _${firstLowerCase(field.fieldName)}SelectedRadioTile, '$enumField', '$enumField', $onChanged)");
              codeBuffer.writeln(_fieldEnd());
            }
          }
          break;
        case FormTypeField.List:
          codeBuffer.writeln(_fieldStart(field));
          codeBuffer.writeln("${spaces(16)}new Container(");
          codeBuffer.writeln(
              "${spaces(20)}height: (fullScreenHeight(context) / 2.5), ");
          codeBuffer.writeln(
              "${spaces(20)}child: ${firstLowerCase(field.fieldType)}sList(widget.app, context, state.value!.${field.fieldName}, _on${firstUpperCase(field.fieldName)}Changed)");
          codeBuffer.writeln("${spaces(16)})");
          codeBuffer.writeln(_fieldEnd());
          break;
        case FormTypeField.Unsupported:
          break;
      }
    } else {
      if (field.getBespokeFormField().contains("(")) {
        codeBuffer.writeln(_fieldStart(field));
        codeBuffer.writeln("${spaces(16)}${field.getBespokeFormField()}");
        codeBuffer.writeln(_fieldEnd());
      } else {
        codeBuffer.writeln(_fieldStart(field));
        codeBuffer.writeln(
            "${spaces(16)}${field.getBespokeFormField()}(widget.app, state.value!.${field.fieldName}, _on${firstUpperCase(field.fieldName)}Changed)");
        codeBuffer.writeln(_fieldEnd());
      }
    }
    return codeBuffer.toString();
  }

  String _groupedFieldsFor(
      String groupLabel, String? condition, List<Field> fields) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(_groupedFieldHeader(groupLabel, condition));
    codeBuffer.writeln(_fields(fields));
    codeBuffer.writeln(_groupedFieldFooter());
    return codeBuffer.toString();
  }

  String _fields(List<Field> fields) {
    StringBuffer codeBuffer = StringBuffer();
    for (var field in fields) {
      if (!field.isHidden()) codeBuffer.writeln(_field(field));
    }
    return codeBuffer.toString();
  }

  String _xyzFormState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(
        "class _My${className}FormState extends State<_My${className}Form> {");
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
    if (modelSpecifications.id == "Member") {
      return process(_readOnlyMethodMember, parameters: <String, String>{
        "\${id}": modelSpecifications.id,
      });
    } else {
      return process(_readOnlyMethod, parameters: <String, String>{
        "\${id}": modelSpecifications.id,
      });
    }
  }

  String _xyzOnChanged(Field field) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(
        "${spaces(2)}void _on${firstUpperCase(field.fieldName)}Changed() {");
    codeBuffer.writeln(
        "${spaces(4)}_myFormBloc.add(Changed${modelSpecifications.id}${firstUpperCase(field.fieldName)}(value: _${firstLowerCase(field.fieldName)}Controller.text));");
    codeBuffer.writeln("${spaces(2)}}");
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
    for (var field in modelSpecifications.fields) {
      if (!field.isHidden()) {
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
      }
    }
    return codeBuffer.toString();
  }

  String _dispose() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("${spaces(2)}@override");
    codeBuffer.writeln("${spaces(2)}void dispose() {");
    for (var field in modelSpecifications.fields) {
      if (field.bespokeFormField == null) {
        if (!field.isHidden()) if (field.formFieldType() ==
            FormTypeField.EntryField) {
          codeBuffer
              .writeln("${spaces(4)}_${field.fieldName}Controller.dispose();");
        }
      }
    }
    codeBuffer.writeln("${spaces(4)}super.dispose();");
    codeBuffer.writeln("${spaces(2)}}");
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

  FormCodeGenerator({required super.modelSpecifications})
      : realFormCodeGenerator = RealFormCodeGenerator(modelSpecifications.id,
            modelSpecifications: modelSpecifications);

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(realFormCodeGenerator.body());
    if (modelSpecifications.views != null) {
      for (var view in modelSpecifications.views!) {
        var fields = <Field>[];
        for (var fieldName in view.fields!) {
          // search in the list of view.
          Field newField = modelSpecifications.fields
              .firstWhere((field) => field.fieldName == fieldName);
          fields.add(newField);
        }

        var groups = <Group>[];
        for (var groupName in view.groups!) {
          // search in the list of view.
          Group newGroup = modelSpecifications.groups!
              .firstWhere((group) => group.group == groupName);
          groups.add(newGroup);
        }

        if (fields.isNotEmpty) {
          ModelSpecification newModelSpec =
              modelSpecifications.copyWith(fields: fields, groups: groups);
          codeBuffer.writeln(RealFormCodeGenerator(
            modelSpecifications.id + view.name ?? "noname",
            modelSpecifications: newModelSpec,
            title: view.title,
            buttonLabel: view.buttonLabel,
          ).body());
        } else {
          print("view ${view.name} has no fields matching the specifications");
        }
      }
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
