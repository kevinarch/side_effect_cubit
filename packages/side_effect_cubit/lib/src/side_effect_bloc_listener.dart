import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

import 'side_effect_bloc_mixin.dart';

mixin BlocSideEffectListenerSingleChildWidget on SingleChildWidget {}

typedef BlocWidgetSideEffectListener<SIDE_EFFECT> = void Function(
  BuildContext context,
  SIDE_EFFECT sideEffect,
);

abstract class BlocSideEffectListenerBase<
    B extends SideEffectProvider<SIDE_EFFECT>,
    SIDE_EFFECT> extends SingleChildStatefulWidget {
  const BlocSideEffectListenerBase({
    super.key,
    required this.listener,
    this.bloc,
    this.child,
  }) : super(child: child);

  final Widget? child;

  final B? bloc;
  final BlocWidgetSideEffectListener<SIDE_EFFECT> listener;

  @override
  SingleChildState<BlocSideEffectListenerBase<B, SIDE_EFFECT>> createState() =>
      _BlocSideEffectListenerBaseState<B, SIDE_EFFECT>();
}

class BlocSideEffectListener<B extends SideEffectProvider<SIDE_EFFECT>,
        SIDE_EFFECT> extends BlocSideEffectListenerBase<B, SIDE_EFFECT>
    with BlocSideEffectListenerSingleChildWidget {
  const BlocSideEffectListener({
    super.key,
    required super.listener,
    super.bloc,
    super.child,
  });
}

class _BlocSideEffectListenerBaseState<
        B extends SideEffectProvider<SIDE_EFFECT>, SIDE_EFFECT>
    extends SingleChildState<BlocSideEffectListenerBase<B, SIDE_EFFECT>> {
  StreamSubscription<SIDE_EFFECT>? _subscription;
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
    _subscribe();
  }

  @override
  void didUpdateWidget(BlocSideEffectListenerBase<B, SIDE_EFFECT> oldWidget) {
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
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(
      child != null,
      '''${widget.runtimeType} used outside of MultiBlocListener must specify a child''',
    );
    if (widget.bloc == null) {
      context.select<B, bool>((bloc) => identical(_bloc, bloc));
    }
    return child!;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _bloc.sideEffects.listen((command) {
      widget.listener(context, command);
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
