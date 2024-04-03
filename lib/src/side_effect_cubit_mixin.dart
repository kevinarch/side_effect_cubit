part of 'side_effect_bloc_mixin.dart';

abstract class SideEffectCubit<STATE, EFFECT> extends Cubit<STATE>
    with SideEffectCubitMixin<STATE, EFFECT> {
  SideEffectCubit(super.initialState);
}

mixin SideEffectCubitMixin<STATE, SIDE_EFFECT> on Cubit<STATE>
    implements SideEffectProvider<SIDE_EFFECT> {
  final StreamController<SIDE_EFFECT> _sideEffectController =
      StreamController.broadcast();

  /// Emits a new [sideEffect].
  void produceSideEffect(SIDE_EFFECT sideEffect) {
    try {
      if (_sideEffectController.isClosed) {
        throw StateError('Cannot emit new states after calling close');
      }
      _sideEffectController.add(sideEffect);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      rethrow;
    }
  }

  @override
  Stream<SIDE_EFFECT> get sideEffects => _sideEffectController.stream;

  @mustCallSuper
  @override
  Future<void> close() async {
    await super.close();
    await _sideEffectController.close();
  }

  @override
  bool get isClosed => super.isClosed && _sideEffectController.isClosed;
}
