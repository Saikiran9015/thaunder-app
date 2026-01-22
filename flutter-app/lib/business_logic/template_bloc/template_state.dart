import 'package:equatable/equatable.dart';
import '../../data/models/template_model.dart';

abstract class TemplateState extends Equatable {
  const TemplateState();

  @override
  List<Object?> get props => [];
}

class TemplateInitial extends TemplateState {}

class TemplateLoading extends TemplateState {}

class TemplatesLoaded extends TemplateState {
  final List<TemplateModel> templates;

  const TemplatesLoaded(this.templates);

  @override
  List<Object?> get props => [templates];
}

class TemplateSelected extends TemplateState {
  final TemplateModel template;

  const TemplateSelected(this.template);

  @override
  List<Object?> get props => [template];
}

class TemplateError extends TemplateState {
  final String message;

  const TemplateError(this.message);

  @override
  List<Object?> get props => [message];
}

class MetadataLoaded extends TemplateState {
  final List<String> categories;
  final List<String> brands;

  const MetadataLoaded({required this.categories, required this.brands});

  @override
  List<Object?> get props => [categories, brands];
}
