import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _code = """
abstract class \${id}ListEvent extends Equatable {
  const \${id}ListEvent();
  @override
  List<Object?> get props => [];
}

class Load\${id}List extends \${id}ListEvent {}

class NewPage extends \${id}ListEvent {}

class Add\${id}List extends \${id}ListEvent {
  final \${id}Model? value;

  const Add\${id}List({ this.value });

  @override
  List<Object?> get props => [ value ];

  @override
  String toString() => 'Add\${id}List{ value: \$value }';
}

class Update\${id}List extends \${id}ListEvent {
  final \${id}Model? value;

  const Update\${id}List({ this.value });

  @override
  List<Object?> get props => [ value ];

  @override
  String toString() => 'Update\${id}List{ value: \$value }';
}

class Delete\${id}List extends \${id}ListEvent {
  final \${id}Model? value;

  const Delete\${id}List({ this.value });

  @override
  List<Object?> get props => [ value ];

  @override
  String toString() => 'Delete\${id}List{ value: \$value }';
}

class \${id}ListUpdated extends \${id}ListEvent {
  final List<\${id}Model?>? value;
  final bool? mightHaveMore;

  const \${id}ListUpdated({ this.value, this.mightHaveMore });

  @override
  List<Object?> get props => [ value, mightHaveMore ];

  @override
  String toString() => '\${id}ListUpdated{ value: \$value, mightHaveMore: \$mightHaveMore }';
}

class \${id}ChangeQuery extends \${id}ListEvent {
  final EliudQuery? newQuery;

  const \${id}ChangeQuery({ required this.newQuery });

  @override
  List<Object?> get props => [ newQuery ];

  @override
  String toString() => '\${id}ChangeQuery{ value: \$newQuery }';
}
""";

class ListEventCodeGenerator extends CodeGenerator {
  ListEventCodeGenerator({required ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:eliud_core/tools/query/query_tools.dart';");
    headerBuffer.writeln("import 'package:equatable/equatable.dart';");
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/" + modelSpecifications.modelFileName()));

    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_code, parameters: <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
    }));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listEventFileName();
  }
}
