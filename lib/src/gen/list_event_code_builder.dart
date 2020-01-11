import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/list_event_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an event class based on a `spec` file
class ListEventCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['.list.event.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateBloc) {
      ListEventCodeGenerator eventCodeGenerator = ListEventCodeGenerator(
          modelSpecifications: modelSpecification);
      return eventCodeGenerator;
    }
  }
}
