import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:eliud_annotations/annotation/annotation.dart';
import 'package:source_gen/source_gen.dart';

class ModelGenerator extends GeneratorForAnnotation<ModelAnnotation> {
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return _generateCode(element);
  }

  String _generateCode(Element element) {
    ModelVisitor visitor = ModelVisitor();
    element.visitChildren(visitor);
    String className = visitor.className.toString();
    var fields = visitor.fields;
    var metaData = visitor.metaData;
    String value = "";
    StringBuffer classBuffer = StringBuffer();
    classBuffer.writeln("class $className {");
    if (fields != null) {
      // Constructor
      classBuffer.writeln("$className (");
      fields.forEach((key, value) {
        String fieldName = value.toString();
        classBuffer.write("this.$fieldName, ");
/*
        classBuffer.writeln(key);

        var v1 = value;
        InterfaceType it = v1;
        print(v1.runtimeType);
        List<ElementAnnotation> annotations = metaData[key];
        if (annotations != null) {
          annotations.forEach((annotation) {
            var element = annotation.computeConstantValue();
            var el = element.type.name;
            if (el == "ID") {
              print("IDENTIFIER");
            } else if (el == "Association") {
              print("ASSOCIATION");
            } else if (el == "Composition") {
              print("COMPOSITION");
            }
          });
        }
*/
      });
    }
    classBuffer.writeln("$className (");
    classBuffer.writeln("}");

    return "/* " + classBuffer.toString() + "*/";
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