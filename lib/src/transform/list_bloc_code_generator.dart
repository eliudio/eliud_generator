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
import 'package:eliud_core_helpers/query/query_tools.dart';

import '\${id_import}_model.dart';

typedef List<\${id}Model?> Filter\${id}Models(List<\${id}Model?> values);
""";

String _code = """


class \${id}ListBloc extends Bloc<\${id}ListEvent, \${id}ListState> {
  final Filter\${id}Models? filter;
  final \${id}Repository _\${lid}Repository;
  StreamSubscription? _\${lid}sListSubscription;
  EliudQuery? eliudQuery;
  int pages = 1;
  final bool? paged;
  final String? orderBy;
  final bool? descending;
  final bool? detailed;
  final int \${lid}Limit;

  \${id}ListBloc({this.filter, this.paged, this.orderBy, this.descending, this.detailed, this.eliudQuery, required \${id}Repository \${lid}Repository, this.\${lid}Limit = 5})
      : assert(\${lid}Repository != null),
        _\${lid}Repository = \${lid}Repository,
        super(\${id}ListLoading()) {
    on <Load\${id}List> ((event, emit) {
      if ((detailed == null) || (!detailed!)) {
        _mapLoad\${id}ListToState();
      } else {
        _mapLoad\${id}ListWithDetailsToState();
      }
    });
    
    on <NewPage> ((event, emit) {
      pages = pages + 1; // it doesn't matter so much if we increase pages beyond the end
      _mapLoad\${id}ListWithDetailsToState();
    });
    
    on <\${id}ChangeQuery> ((event, emit) {
      eliudQuery = event.newQuery;
      if ((detailed == null) || (!detailed!)) {
        _mapLoad\${id}ListToState();
      } else {
        _mapLoad\${id}ListWithDetailsToState();
      }
    });
      
    on <Add\${id}List> ((event, emit) async {
      await _mapAdd\${id}ListToState(event);
    });
    
    on <Update\${id}List> ((event, emit) async {
      await _mapUpdate\${id}ListToState(event);
    });
    
    on <Delete\${id}List> ((event, emit) async {
      await _mapDelete\${id}ListToState(event);
    });
    
    on <\${id}ListUpdated> ((event, emit) {
      emit(_map\${id}ListUpdatedToState(event));
    });
  }

  List<\${id}Model?> _filter(List<\${id}Model?> original) {
    if (filter != null) {
      return filter!(original);
    } else {
      return original;
    }
  }

  Future<void> _mapLoad\${id}ListToState() async {
    int amountNow =  (state is \${id}ListLoaded) ? (state as \${id}ListLoaded).values!.length : 0;
    _\${lid}sListSubscription?.cancel();
    _\${lid}sListSubscription = _\${lid}Repository.listen(
          (list) => add(\${id}ListUpdated(value: _filter(list), mightHaveMore: amountNow != list.length)),
      orderBy: orderBy,
      descending: descending,
      eliudQuery: eliudQuery,
      limit: ((paged != null) && paged!) ? pages * \${lid}Limit : null
    );
  }

  Future<void> _mapLoad\${id}ListWithDetailsToState() async {
    int amountNow =  (state is \${id}ListLoaded) ? (state as \${id}ListLoaded).values!.length : 0;
    _\${lid}sListSubscription?.cancel();
    _\${lid}sListSubscription = _\${lid}Repository.listenWithDetails(
            (list) => add(\${id}ListUpdated(value: _filter(list), mightHaveMore: amountNow != list.length)),
        orderBy: orderBy,
        descending: descending,
        eliudQuery: eliudQuery,
        limit: ((paged != null) && paged!) ? pages * \${lid}Limit : null
    );
  }

  Future<void> _mapAdd\${id}ListToState(Add\${id}List event) async {
    var value = event.value;
    if (value != null) {
      await _\${lid}Repository.add(value);
    }
  }

  Future<void> _mapUpdate\${id}ListToState(Update\${id}List event) async {
    var value = event.value;
    if (value != null) {
      await _\${lid}Repository.update(value);
    }
  }

  Future<void> _mapDelete\${id}ListToState(Delete\${id}List event) async {
    var value = event.value;
    if (value != null) {
      await _\${lid}Repository.delete(value);
    }
  }

  \${id}ListLoaded _map\${id}ListUpdatedToState(
      \${id}ListUpdated event) => \${id}ListLoaded(values: event.value, mightHaveMore: event.mightHaveMore);

  @override
  Future<void> close() {
    _\${lid}sListSubscription?.cancel();
    return super.close();
  }
}

""";

class ListBlocCodeGenerator extends CodeGenerator {
  ListBlocCodeGenerator({required super.modelSpecifications});

  Map<String, String> parameters(ModelSpecification modelSpecification) =>
      <String, String>{
        '\${id}': modelSpecifications.id,
        '\${lid}': firstLowerCase(modelSpecifications.id),
        "\${id_import}": camelcaseToUnderscore(modelSpecifications.id),
        "\${package_name}": modelSpecifications.packageName
      };

  @override
  String commonImports() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(
        process(_imports, parameters: parameters(modelSpecifications)));
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer
        .writeln(process(_code, parameters: parameters(modelSpecifications)));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listBlocFileName();
  }
}
