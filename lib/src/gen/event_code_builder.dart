import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/entity_code_generator.dart';
import 'package:eliud_generator/src/transform/event_code_generator.dart';
import 'package:eliud_generator/src/transform/repository_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an event class based on a `spec` file
class EventCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['.event.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.requiresBLoC) {
      EventCodeGenerator eventCodeGenerator = EventCodeGenerator(
          modelSpecifications: modelSpecification);
      return eventCodeGenerator;
    }
  }
}