import 'package:equatable/equatable.dart';
import '../../data/models/template_model.dart';

abstract class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object?> get props => [];
}

class LoadTemplatesEvent extends TemplateEvent {
  final String? category;
  final String? brand;

  const LoadTemplatesEvent({this.category, this.brand});

  @override
  List<Object?> get props => [category, brand];
}

class SelectTemplateEvent extends TemplateEvent {
  final TemplateModel template;

  const SelectTemplateEvent(this.template);

  @override
  List<Object?> get props => [template];
}

class LoadMetadataEvent extends TemplateEvent {
  const LoadMetadataEvent();
}
