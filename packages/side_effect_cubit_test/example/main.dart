import "package:side_effect_cubit_test/side_effect_cubit_test.dart";
import "package:side_effect_cubit/side_effect_cubit.dart";
import "package:test/test.dart";

class CounterCubit extends SideEffectCubit<int, CounterSideEffect> {
  CounterCubit() : super(0);

  void plusOne() {
    produceSideEffect(ShowInfoDialogEffect());
    emit(state + 1);
  }
}

abstract class CounterSideEffect {}

class ShowInfoDialogEffect extends CounterSideEffect {}

void main() {
  final counterCubit = CounterCubit();

  group("side_effect tests", () {
    sideEffectBlocTest<CounterCubit, int, CounterSideEffect>(
      "plusOne should yield ShowInfoDialogEffect",
      build: () => counterCubit,
      act: (cubit) => cubit.plusOne(),
      expect: () => [1],
      expectSideEffects: () => [isA<ShowInfoDialogEffect>()],
    );
  });
}
