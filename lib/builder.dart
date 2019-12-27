import 'package:build/build.dart';
import 'file:///C:/src/eliud/eliud_generator/lib/src/gen/model_code_builder.dart';
import 'package:eliud_generator/src/gen/entity_code_builder.dart';
import 'package:eliud_generator/src/gen/firestore_code_builder.dart';
import 'package:eliud_generator/src/gen/repository_code_builder.dart';

Builder model(BuilderOptions options) =>
    ModelCodeBuilder();

Builder entity(BuilderOptions options) =>
    EntityCodeBuilder();

Builder repository(BuilderOptions options) =>
    RepositoryCodeBuilder();

Builder firestore(BuilderOptions options) =>
    FirestoreCodeBuilder();

