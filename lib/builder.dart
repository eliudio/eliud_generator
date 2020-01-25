import 'package:build/build.dart';

import 'package:eliud_generator/src/gen/entity_code_builder.dart';
import 'package:eliud_generator/src/gen/model_code_builder.dart';

import 'package:eliud_generator/src/gen/firestore_code_builder.dart';
import 'package:eliud_generator/src/gen/repository_code_builder.dart';

import 'package:eliud_generator/src/gen/component_bloc_code_builder.dart';
import 'package:eliud_generator/src/gen/component_code_builder.dart';
import 'package:eliud_generator/src/gen/component_event_code_builder.dart';
import 'package:eliud_generator/src/gen/component_state_code_builder.dart';

import 'package:eliud_generator/src/gen/form_bloc_code_builder.dart';
import 'package:eliud_generator/src/gen/form_code_builder.dart';
import 'package:eliud_generator/src/gen/form_event_code_builder.dart';
import 'package:eliud_generator/src/gen/form_state_code_builder.dart';

import 'package:eliud_generator/src/gen/list_bloc_code_builder.dart';
import 'package:eliud_generator/src/gen/list_code_builder.dart';
import 'package:eliud_generator/src/gen/list_event_code_builder.dart';
import 'package:eliud_generator/src/gen/list_state_code_builder.dart';

import 'package:eliud_generator/src/gen/repository_singleton_builder.dart';

import 'package:eliud_generator/src/gen/internal_component_builder.dart';
import 'package:eliud_generator/src/gen/embedded_component_builder.dart';

Builder model(BuilderOptions options) =>
    ModelCodeBuilder();

Builder entity(BuilderOptions options) =>
    EntityCodeBuilder();

Builder repository(BuilderOptions options) =>
    RepositoryCodeBuilder();

Builder firestore(BuilderOptions options) =>
    FirestoreCodeBuilder();

Builder component_event(BuilderOptions options) =>
    ComponentEventCodeBuilder();

Builder component_state(BuilderOptions options) =>
    ComponentStateCodeBuilder();

Builder component_bloc(BuilderOptions options) =>
    ComponentBlocCodeBuilder();

Builder component(BuilderOptions options) =>
    ComponentCodeBuilder();

Builder list_event(BuilderOptions options) =>
    ListEventCodeBuilder();

Builder list_state(BuilderOptions options) =>
    ListStateCodeBuilder();

Builder list_bloc(BuilderOptions options) =>
    ListBlocCodeBuilder();

Builder list(BuilderOptions options) =>
    ListCodeBuilder();

Builder form_event(BuilderOptions options) =>
    FormEventCodeBuilder();

Builder form_state(BuilderOptions options) =>
    FormStateCodeBuilder();

Builder form_bloc(BuilderOptions options) =>
    FormBlocCodeBuilder();

Builder form(BuilderOptions options) =>
    FormCodeBuilder();

Builder internal_component(BuilderOptions options) =>
    InternalComponentBuilder();

Builder embedded_component(BuilderOptions options) =>
    EmbeddedComponentBuilder();

Builder repository_singleton(BuilderOptions options) =>
    RepositorySingletonBuilder();

