# Side Effect Cubit

An extension to the bloc state management library which serve an additional stream for events that should be consumed only once - as usual called one-time events. 

## Usage

### 1. Adding to existing one

For Bloc:

```dart
class FeatureBloc extends Bloc<FeatureEvent, FeatureState>
    with SideEffectBlocMixin<FeatureEvent, FeatureState, FeatureSideEffect> {
  FeatureBloc() : super(FeatureState.initial());
}
```

For Cubit:

```dart
  class FeatureCubit extends Cubit<FeatureState>
    with SideEffectCubitMixin<FeatureState, FeatureSideEffect> {
  FeatureCubit() : super(FeatureState.initial());
}
```

### 2. Inherit

For Bloc:

```dart
class FeatureBloc extends SideEffectBloc<FeatureEvent, FeatureState, FeatureSideEffect>{
  FeatureBloc() : super(FeatureState.initial());
}
```

For Cubit:

```dart
class FeatureCubit extends SideEffectCubit<FeatureState, FeatureSideEffect> {
  FeatureCubit() : super(FeatureState.initial());
}
```

### Emit side effect

```dart
class FeatureBloc extends SideEffectBloc<FeatureEvent, FeatureState, FeatureSideEffect>{
  FeatureBloc() : super(FeatureState.initial()){        
    on<ItemClick>(
      (event, emit) {
        produceSideEffect(FeatureSideEffect.openItem(event.id));
      },
    );
  }
}
```


```dart
class FeatureCubit extends SideEffectCubit<FeatureState, FeatureSideEffect> {
  FeatureCubit() : super(FeatureState.initial());

  Future<void> doSomething() {
    produceSideEffect(FeatureSideEffect.openItem(event.id));
  }
}
```

### Listen side effect

```dart
BlocSideEffectListener<FeatureBloc, FeatureSideEffect>(
    listener: (BuildContext context, FeatureSideEffect sideEffect) {
        sideEffect.when(
            goToNextScreen: () => Navigator.of(context).pushNamed("/second_screen"),
            showPopupError: (errMsg) {
                // ....
            });
    },
    child: ...
)
```

```dart
BlocSideEffectConsumer<FeatureBloc, FeatureState, FeatureSideEffect>(
    sideEffectListener: (BuildContext context, FeatureSideEffect sideEffect) {

    },
    listenWhen: (previos, current) {},
    listen: (previous, current) {},
    buildWhen: (previous, current) => true,
    builder: (BuildContext context,  FeatureState state) {
        return ...
    }
)
```