import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/template_repository.dart';
import 'template_event.dart';
import 'template_state.dart';

export 'template_event.dart';
export 'template_state.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final TemplateRepository _templateRepository;

  TemplateBloc(this._templateRepository) : super(TemplateInitial()) {
    on<LoadTemplatesEvent>(_onLoadTemplates);
    on<SelectTemplateEvent>(_onSelectTemplate);
    on<LoadMetadataEvent>(_onLoadMetadata);
  }

  Future<void> _onLoadMetadata(
    LoadMetadataEvent event,
    Emitter<TemplateState> emit,
  ) async {
    try {
      final categories = await _templateRepository.getCategories();
      final brands = await _templateRepository.getBrands();
      emit(MetadataLoaded(categories: categories, brands: brands));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> _onLoadTemplates(
    LoadTemplatesEvent event,
    Emitter<TemplateState> emit,
  ) async {
    emit(TemplateLoading());
    
    try {
      final templates = await _templateRepository.getTemplates(
        category: event.category,
        brand: event.brand,
      );
      emit(TemplatesLoaded(templates));
    } catch (e) {
      emit(TemplateError(e.toString()));
    }
  }

  Future<void> _onSelectTemplate(
    SelectTemplateEvent event,
    Emitter<TemplateState> emit,
  ) async {
    emit(TemplateSelected(event.template));
  }
}
