import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'side_effect_cubit_mixin.dart';

abstract class SideEffectBloc<EVENT, STATE, SIDE_EFFECT>
    extends Bloc<EVENT, STATE>
    with SideEffectBlocMixin<EVENT, STATE, SIDE_EFFECT> {
  SideEffectBloc(super.initialState);
}

abstract class SideEffectProvider<SIDE_EFFECT> {
  Stream<SIDE_EFFECT> get sideEffects;
}

mixin SideEffectBlocMixin<EVENT, STATE, SIDE_EFFECT> on Bloc<EVENT, STATE>
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
