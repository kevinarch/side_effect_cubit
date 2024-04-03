import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'side_effect_bloc_mixin.dart';
import 'side_effect_bloc_listener.dart';

class BlocSideEffectConsumer<B extends StateStreamable<STATE>, STATE,
    SIDE_EFFECT> extends StatefulWidget {
  const BlocSideEffectConsumer({
    required this.builder,
    this.listener,
    super.key,
    this.bloc,
    this.buildWhen,
    this.listenWhen,
    this.sideEffectListener,
  });

  final B? bloc;

  final BlocWidgetBuilder<STATE> builder;

  final BlocWidgetListener<STATE>? listener;

  final BlocWidgetSideEffectListener<SIDE_EFFECT>? sideEffectListener;

  final BlocBuilderCondition<STATE>? buildWhen;

  final BlocListenerCondition<STATE>? listenWhen;

  @override
  State<BlocSideEffectConsumer<B, STATE, SIDE_EFFECT>> createState() =>
      _BlocSideEffectConsumerState<B, STATE, SIDE_EFFECT>();
}

class _BlocSideEffectConsumerState<B extends StateStreamable<STATE>, STATE,
    SIDE_EFFECT> extends State<BlocSideEffectConsumer<B, STATE, SIDE_EFFECT>> {
  late B _bloc;
  StreamSubscription<SIDE_EFFECT>? _subscription;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  void didUpdateWidget(
      BlocSideEffectConsumer<B, STATE, SIDE_EFFECT> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      if (_subscription != null) {
        _unsubscribe();
      }

      _bloc = currentBloc;
      _subscribe();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = widget.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      if (_subscription != null) {
        _unsubscribe();
      }

      _bloc = bloc;
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bloc == null) {
      // Trigger a rebuild if the bloc reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      context.select<B, bool>((bloc) => identical(_bloc, bloc));
    }
    return BlocBuilder<B, STATE>(
      bloc: _bloc,
      builder: widget.builder,
      buildWhen: (previous, current) {
        if (widget.listenWhen?.call(previous, current) ?? true) {
          widget.listener?.call(context, current);
        }
        return widget.buildWhen?.call(previous, current) ?? true;
      },
    );
  }

  void _subscribe() {
    if (_bloc is! SideEffectCubit<STATE, SIDE_EFFECT>) {
      throw Exception("Cubit dont' conform SideEffectCubit, did you forget ?");
    }

    final sideEffectCubit = _bloc as SideEffectCubit<STATE, SIDE_EFFECT>;
    _subscription = sideEffectCubit.sideEffects.listen((command) {
      widget.sideEffectListener?.call(context, command);
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
