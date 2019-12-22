import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:eliud_annotations/annotation/annotation.dart';
import 'package:source_gen/source_gen.dart';

class EliudGenerator extends GeneratorForAnnotation<ModelAnnotation> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generateCode(element);
  }

  String _generateCode(Element element) {
    ModelVisitor visitor = ModelVisitor();
    element.visitChildren(visitor);
    DartType className = visitor.className;
    return "// JAJA ${className}";
  }
}

class ModelVisitor extends SimpleElementVisitor {
  DartType className;
  Map<String, DartType> fields = {};
  Map<String, dynamic> metaData = {};

  @override
  visitConstructorElement(ConstructorElement element) {
    className = element.type.returnType;
  }

  @override
  visitFieldElement(FieldElement element) {
    fields[element.name] = element.type;
    metaData[element.name] = element.metadata;
  }
}