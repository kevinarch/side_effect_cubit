# side_effect_cubit_test

This package facilitates testing blocs that produce side effects, as introduced in the **side_effect_cubit** package. 
It heavily inherits from **bloc_test**, adding features that allow you to expect side effects to be emitted.


## The Problem: Testing side effects without side_effect_cubit_test
Traditionally, testing side effects in a Bloc involved a cumbersome process. Developers had to:

- **Manually Collect Side Effects**: Create a list to store the emitted side effects.
- **Subscribe to the Side Effect Stream**: Establish a StreamSubscription to listen for side effect events.
- **Append Side Effects to the List**: Add received side effects to the previously created list during the build step of the test.
- **Assert Side Effects**: Verify the contents of the side effect list within the verify step.
- **Clean Up**: Cancel the StreamSubscription in the tearDown step.

```dart
  final receivedEffects = <RarOnboardingSideEffect>[];
  StreamSubscription? effectSub;

  blocTest<RarOnboardingBloc, RarOnboardingState>(
    "should produce RarOnboardingEkycInitFailure when init ekyc plugin fail",
    setUp: () {
      when(() => rarRepository.getFaceAuthenConfig()).thenAnswer((_) async => FaceAuthenService.defaultConfig);
      when(() => ekycPlugin.initialize(any())).thenAnswer((_) async => EKYCFailure());
    },
    build: () {
      effectSub = bloc.sideEffects.asBroadcastStream().listen(receivedEffects.add);

      return bloc;
    },
    act: (bloc) async => bloc.initConfig(),
    verify: (bloc) {
      expect(receivedEffects, [isA<RarOnboardingEkycInitFailure>()]);

    },
    tearDown: () => effectSub?.cancel()
  );
```
This approach introduces redundancy and makes test code verbose, especially when multiple test cases require side effect verification.

## The Solution: side_effect_cubit_test
**side_effect_cubit_test** provides a more concise and efficient method for testing side effects in Blocs. It leverages the existing bloc_test package and introduces the following key improvement:

 - **Simplified Side Effect Expectation**: The **expectSideEffects** function allows you to specify the expected side effects directly within the test setup. This eliminates the need for manual side effect collection, subscription management, and individual verification steps.


```dart
sideEffectBlocTest<RarOnboardingBloc, RarOnboardingState, RarOnboardingSideEffect>(
    "should produce RarOnboardingEkycInitFailure when init ekyc plugin fail",
    setUp: () {
      when(() => rarRepository.getFaceAuthenConfig()).thenAnswer((_) async => FaceAuthenService.defaultConfig);
      when(() => ekycPlugin.initialize(any())).thenAnswer((_) async => EKYCFailure());
    },
    build: () => bloc,
    act: (bloc) async => bloc.initConfig(),
    expectSideEffects: () => [isA<RarOnboardingEkycInitFailure>()],
);
```