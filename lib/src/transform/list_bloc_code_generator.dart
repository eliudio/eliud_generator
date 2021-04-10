import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _imports = """
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import 'package:\${package_name}/model/\${id_import}_repository.dart';
import 'package:\${package_name}/model/\${id_import}_list_event.dart';
import 'package:\${package_name}/model/\${id_import}_list_state.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
""";

String _code = """

const _\${lid}Limit = 5;

class \${id}ListBloc extends Bloc<\${id}ListEvent, \${id}ListState> {
  final \${id}Repository _\${lid}Repository;
  StreamSubscription? _\${lid}sListSubscription;
  final EliudQuery? eliudQuery;
  int pages = 1;
  final bool? paged;
  final String? orderBy;
  final bool? descending;
  final bool? detailed;

  \${id}ListBloc({this.paged, this.orderBy, this.descending, this.detailed, this.eliudQuery, required \${id}Repository \${lid}Repository})
      : assert(\${lid}Repository != null),
        _\${lid}Repository = \${lid}Repository,
        super(\${id}ListLoading());

  Stream<\${id}ListState> _mapLoad\${id}ListToState() async* {
    int amountNow =  (state is \${id}ListLoaded) ? (state as \${id}ListLoaded).values!.length : 0;
    _\${lid}sListSubscription?.cancel();
    _\${lid}sListSubscription = _\${lid}Repository.listen(
          (list) => add(\${id}ListUpdated(value: list, mightHaveMore: amountNow != list.length)),
      orderBy: orderBy,
      descending: descending,
      eliudQuery: eliudQuery,
      limit: ((paged != null) && paged!) ? pages * _\${lid}Limit : null
    );
  }

  Stream<\${id}ListState> _mapLoad\${id}ListWithDetailsToState() async* {
    int amountNow =  (state is \${id}ListLoaded) ? (state as \${id}ListLoaded).values!.length : 0;
    _\${lid}sListSubscription?.cancel();
    _\${lid}sListSubscription = _\${lid}Repository.listenWithDetails(
            (list) => add(\${id}ListUpdated(value: list, mightHaveMore: amountNow != list.length)),
        orderBy: orderBy,
        descending: descending,
        eliudQuery: eliudQuery,
        limit: ((paged != null) && paged!) ? pages * _\${lid}Limit : null
    );
  }

  Stream<\${id}ListState> _mapAdd\${id}ListToState(Add\${id}List event) async* {
    var value = event.value;
    if (value != null) 
      _\${lid}Repository.add(value);
  }

  Stream<\${id}ListState> _mapUpdate\${id}ListToState(Update\${id}List event) async* {
    var value = event.value;
    if (value != null) 
      _\${lid}Repository.update(value);
  }

  Stream<\${id}ListState> _mapDelete\${id}ListToState(Delete\${id}List event) async* {
    var value = event.value;
    if (value != null) 
      _\${lid}Repository.delete(value);
  }

  Stream<\${id}ListState> _map\${id}ListUpdatedToState(
      \${id}ListUpdated event) async* {
    yield \${id}ListLoaded(values: event.value, mightHaveMore: event.mightHaveMore);
  }

  @override
  Stream<\${id}ListState> mapEventToState(\${id}ListEvent event) async* {
    if (event is Load\${id}List) {
      if ((detailed == null) || (!detailed!)) {
        yield* _mapLoad\${id}ListToState();
      } else {
        yield* _mapLoad\${id}ListWithDetailsToState();
      }
    }
    if (event is NewPage) {
      pages = pages + 1; // it doesn't matter so much if we increase pages beyond the end
      yield* _mapLoad\${id}ListWithDetailsToState();
    } else if (event is Add\${id}List) {
      yield* _mapAdd\${id}ListToState(event);
    } else if (event is Update\${id}List) {
      yield* _mapUpdate\${id}ListToState(event);
    } else if (event is Delete\${id}List) {
      yield* _mapDelete\${id}ListToState(event);
    } else if (event is \${id}ListUpdated) {
      yield* _map\${id}ListUpdatedToState(event);
    }
  }

  @override
  Future<void> close() {
    _\${lid}sListSubscription?.cancel();
    return super.close();
  }
}

""";

class ListBlocCodeGenerator extends CodeGenerator {
  ListBlocCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  Map<String, String> parameters(ModelSpecification modelSpecification) => <String, String>{
    '\${id}': modelSpecifications.id,
    '\${lid}': firstLowerCase(modelSpecifications.id),
    "\${id_import}": camelcaseToUnderscore(modelSpecifications.id),
    "\${package_name}": modelSpecifications.packageName
  };

  @override
  String commonImports() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_imports, parameters: parameters(modelSpecifications)));
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_code, parameters: parameters(modelSpecifications)));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listBlocFileName();
  }
}
