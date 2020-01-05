import 'package:build/build.dart';
import 'package:eliud_generator/src/gen/component_bloc_code_builder.dart';
import 'package:eliud_generator/src/gen/component_code_builder.dart';
import 'package:eliud_generator/src/gen/component_event_code_builder.dart';
import 'package:eliud_generator/src/gen/component_state_code_builder.dart';
import 'package:eliud_generator/src/gen/entity_code_builder.dart';
import 'package:eliud_generator/src/gen/firestore_code_builder.dart';
import 'package:eliud_generator/src/gen/model_code_builder.dart';
import 'package:eliud_generator/src/gen/repository_code_builder.dart';

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

