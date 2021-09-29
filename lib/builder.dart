import 'package:build/build.dart';
import 'package:eliud_generator/src/gen/abstract_repository_singleton_builder.dart';
import 'package:eliud_generator/src/gen/admin_app_code_builder.dart';
import 'package:eliud_generator/src/gen/cache_code_builder.dart';
import 'package:eliud_generator/src/gen/cache_export_builder.dart';
import 'package:eliud_generator/src/gen/component_registry_builder.dart';
import 'package:eliud_generator/src/gen/component_selector_code_builder.dart';

import 'package:eliud_generator/src/gen/entity_code_builder.dart';
import 'package:eliud_generator/src/gen/entity_export_builder.dart';
import 'package:eliud_generator/src/gen/model_code_builder.dart';

import 'package:eliud_generator/src/gen/firestore_code_builder.dart';
import 'package:eliud_generator/src/gen/model_export_builder.dart';
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
import 'package:eliud_generator/src/gen/dropdownbutton_code_builder.dart';
import 'package:eliud_generator/src/gen/list_event_code_builder.dart';
import 'package:eliud_generator/src/gen/list_state_code_builder.dart';
import 'package:eliud_generator/src/gen/repository_export_builder.dart';

import 'package:eliud_generator/src/gen/repository_singleton_builder.dart';

import 'package:eliud_generator/src/gen/internal_component_builder.dart';
import 'package:eliud_generator/src/gen/embedded_component_builder.dart';

Builder model(BuilderOptions options) =>
    ModelCodeBuilder();

Builder entity(BuilderOptions options) =>
    EntityCodeBuilder();

Builder repository(BuilderOptions options) =>
    RepositoryCodeBuilder();

Builder cache(BuilderOptions options) =>
    CacheCodeBuilder();

Builder admin_app(BuilderOptions options) =>
    AdminAppBuilder();

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

Builder dropdown_button(BuilderOptions options) =>
    DropdownButtonCodeBuilder();

Builder component_selector(BuilderOptions options) =>
    ComponentSelectorCodeBuilder();

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

Builder abstract_repository_singleton(BuilderOptions options) =>
    AbstractRepositorySingletonBuilder();

Builder repository_export(BuilderOptions options) =>
    RepositoryExportBuilder();

Builder entity_export(BuilderOptions options) =>
    EntityExportBuilder();

Builder model_export(BuilderOptions options) =>
    ModelExportBuilder();

Builder cache_export(BuilderOptions options) =>
    CacheExportBuilder();

Builder component_registry(BuilderOptions options) =>
    ComponentRegistryBuilder();

