import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/design_repository.dart';
import 'design_event.dart';
import 'design_state.dart';

export 'design_event.dart';
export 'design_state.dart';

class DesignBloc extends Bloc<DesignEvent, DesignState> {
  final DesignRepository _designRepository;

  DesignBloc(this._designRepository) : super(DesignInitial()) {
    on<UploadDesignEvent>(_onUploadDesign);
    on<ProcessDesignEvent>(_onProcessDesign);
    on<StartCuttingEvent>(_onStartCutting);
    on<UpdateTransformEvent>(_onUpdateTransform);
    on<ResetDesignEvent>(_onResetDesign);
  }

  void _onUpdateTransform(UpdateTransformEvent event, Emitter<DesignState> emit) {
    if (state is DesignUploaded) {
      final current = state as DesignUploaded;
      emit(current.copyWith(
        dx: current.dx + event.dx,
        dy: current.dy + event.dy,
        scale: (current.scale * event.scale).clamp(0.1, 10.0),
        rotation: current.rotation + event.rotation,
      ));
    }
  }

  void _onResetDesign(ResetDesignEvent event, Emitter<DesignState> emit) {
    emit(DesignInitial());
  }

  Future<void> _onUploadDesign(
    UploadDesignEvent event,
    Emitter<DesignState> emit,
  ) async {
    emit(DesignLoading());
    
    try {
      final designInfo = await _designRepository.uploadDesign(event.filePath);
      // Ensure filePath is available in designInfo for the UI
      final updatedDesignInfo = Map<String, dynamic>.from(designInfo);
      updatedDesignInfo['filePath'] = event.filePath;
      
      emit(DesignUploaded(updatedDesignInfo));
    } catch (e) {
      emit(DesignError(e.toString()));
    }
  }

  Future<void> _onProcessDesign(
    ProcessDesignEvent event,
    Emitter<DesignState> emit,
  ) async {
    emit(DesignLoading());
    
    try {
      final result = await _designRepository.processDesign(
        filePath: event.filePath,
        scaleX: event.scaleX,
        scaleY: event.scaleY,
        mirror: event.mirror,
      );
      
      emit(DesignProcessed(
        List<String>.from(result['gcode']),
        result['stats'],
      ));
    } catch (e) {
      emit(DesignError(e.toString()));
    }
  }

  Future<void> _onStartCutting(
    StartCuttingEvent event,
    Emitter<DesignState> emit,
  ) async {
    try {
      await _designRepository.startCutting(event.gcode);
      emit(const CuttingInProgress(0));
    } catch (e) {
      emit(DesignError(e.toString()));
    }
  }
}
