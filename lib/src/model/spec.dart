import 'package:eliud_generator/src/tools/tool_set.dart';

abstract class Specification {
  final String id;

  Specification({required this.id});

  String modelClassName() {
    return "${id}Model";
  }

  String entityClassName() {
    return "${id}Entity";
  }

  String repositoryClassName() {
    return "${id}Repository";
  }

  String firestoreClassName() {
    return "${id}Firestore";
  }

  String componentClassName() {
    return "Abstract${id}Component";
  }

  String formClassName() {
    return "${id}Form";
  }

  String formStateClassName() {
    return "${id}FormState";
  }

  String formEventClassName() {
    return "${id}FormEvent";
  }

  String listClassName() {
    return "${id}List";
  }

  String modelFileName() {
    return "${camelcaseToUnderscore(id)}_model.dart";
  }

  String entityFileName() {
    return "${camelcaseToUnderscore(id)}_entity.dart";
  }

  String repositoryFileName() {
    return "${camelcaseToUnderscore(id)}_repository.dart";
  }

  String firestoreFileName() {
    return "${camelcaseToUnderscore(id)}_firestore.dart";
  }

  String componentStateFileName() {
    return "${camelcaseToUnderscore(id)}_component_state.dart";
  }

  String componentEventFileName() {
    return "${camelcaseToUnderscore(id)}_component_event.dart";
  }

  String componentBlocFileName() {
    return "${camelcaseToUnderscore(id)}_component_bloc.dart";
  }

  String componentFileName() {
    return "${camelcaseToUnderscore(id)}_component.dart";
  }

  String listStateFileName() {
    return "${camelcaseToUnderscore(id)}_list_state.dart";
  }

  String listEventFileName() {
    return "${camelcaseToUnderscore(id)}_list_event.dart";
  }

  String listBlocFileName() {
    return "${camelcaseToUnderscore(id)}_list_bloc.dart";
  }

  String listFileName() {
    return "${camelcaseToUnderscore(id)}_list.dart";
  }

  String componentSelectorFileName() {
    return "${camelcaseToUnderscore(id)}_component_selector.dart";
  }

  String formStateFileName() {
    return "${camelcaseToUnderscore(id)}_form_state.dart";
  }

  String formEventFileName() {
    return "${camelcaseToUnderscore(id)}_form_event.dart";
  }

  String formBlocFileName() {
    return "${camelcaseToUnderscore(id)}_form_bloc.dart";
  }

  String formFileName() {
    return "${camelcaseToUnderscore(id)}_form.dart";
  }
}
