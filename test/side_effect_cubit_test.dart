import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:side_effect_cubit/side_effect_cubit.dart';

import 'mocks.dart';

class CounterState {
  final int count;

  CounterState(this.count);
}

sealed class CounterSideEffect {}

class ShowCounterDialog extends CounterSideEffect {}

class FallbackEffect extends CounterSideEffect {}

class CounterCubit extends SideEffectCubit<CounterState, CounterSideEffect> {
  CounterCubit() : super(CounterState(0));

  Future<void> increase() async {
    produceSideEffect(ShowCounterDialog());
    emit(CounterState(state.count + 1));
  }
}

class _MockListener extends Mock {
  void listen(BuildContext context, CounterSideEffect effect);
}

class _MockSideEffectListener extends Mock {
  void sideEffectListener(BuildContext context, CounterSideEffect effect);
}

void main() {
  group("SideEffectCubit", () {
    late CounterCubit cubit;
    late _MockListener listener;
    late _MockSideEffectListener sideEffectListener;

    setUpAll(() {
      registerFallbacks();
      registerFallbackValue(FallbackEffect());
    });

    setUp(() {
      cubit = CounterCubit();
      listener = _MockListener();
      sideEffectListener = _MockSideEffectListener();

      when(() => listener.listen(any(), any())).thenReturn(null);
      when(() => listener.listen(any(), any())).thenReturn(null);
    });

    testWidgets('BlocSideEffectListener should call listener correctly',
        (widgetTester) async {
      await widgetTester
          .pumpWidget(BlocSideEffectListener<CounterCubit, CounterSideEffect>(
        bloc: cubit,
        listener: listener.listen,
        child: const SizedBox(),
      ));

      await cubit.increase();

      await widgetTester.pump();

      final receivedSideEffect =
          verify(() => listener.listen(any(), captureAny()));
      expect(receivedSideEffect.captured.last is ShowCounterDialog, true);
      receivedSideEffect.called(1);
    });

    testWidgets('BlocSideEffectListener should disppose correctly',
        (widgetTester) async {
      await widgetTester
          .pumpWidget(BlocSideEffectListener<CounterCubit, CounterSideEffect>(
        bloc: cubit,
        listener: listener.listen,
        child: const SizedBox(),
      ));

      await widgetTester.pump();
      await widgetTester.pumpWidget(const SizedBox());

      await cubit.increase();
      await widgetTester.pump();

      verifyNever(() => listener.listen(any(), any()));
    });

    testWidgets('BlocSideEffectConsumer should call its listener correctly',
        (widgetTester) async {
      await widgetTester.pumpWidget(
          BlocSideEffectConsumer<CounterCubit, CounterState, CounterSideEffect>(
        bloc: cubit,
        sideEffectListener: sideEffectListener.sideEffectListener,
        // listener: (_, state) { },
        builder: (context, state) => const SizedBox(),
      ));

      await cubit.increase();
      await widgetTester.pump();

      final receivedSideEffect = verify(
          () => sideEffectListener.sideEffectListener(any(), captureAny()));
      expect(receivedSideEffect.captured.last is ShowCounterDialog, true);
      receivedSideEffect.called(1);
    });

    testWidgets(
        'BlocSideEffectConsumer should call buildWhen and listen correctly',
        (widgetTester) async {
      var buildCounter = 0;
      CounterState? latestState;

      await widgetTester.pumpWidget(
          BlocSideEffectConsumer<CounterCubit, CounterState, CounterSideEffect>(
        bloc: cubit,
        sideEffectListener: sideEffectListener.sideEffectListener,
        listener: (_, state) {
          latestState = state;
        },
        buildWhen: (previous, current) => previous.count != current.count,
        builder: (context, state) {
          buildCounter++;
          return const SizedBox();
        },
      ));

      await widgetTester.pump();
      await cubit.increase();
      await widgetTester.pump();

      expect(buildCounter, 2);
      expect(latestState?.count ?? 0, 1);
    });
  });
}
