import 'package:flutter/material.dart';
import 'package:side_effect_cubit/side_effect_cubit.dart';

void main() {
  runApp(const MyApp());
}

class WeatherState {
  final int temperature;

  WeatherState(this.temperature);
}

sealed class WeatherSideEffect {}

class ShowBottomSheet extends WeatherSideEffect {}

class WeatherCubit extends SideEffectCubit<WeatherState, WeatherSideEffect> {
  WeatherCubit() : super(WeatherState(0));

  void onButtonPressed() {
    emit(WeatherState(38));

    produceSideEffect(ShowBottomSheet());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WeatherCubit weatherCubit;

  @override
  void initState() {
    super.initState();
    weatherCubit = WeatherCubit();
  }

  @override
  void dispose() {
    weatherCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BlocSideEffectListener<WeatherCubit, WeatherSideEffect>(
          bloc: weatherCubit,
          listener: (context, effect) {
            if (effect is ShowBottomSheet) {
              showBottomSheet(
                context: context,
                builder: (c) => Material(
                  child: Container(
                    color: Colors.black12,
                    height: 150,
                  ),
                ),
              );
            }
          },
          child: Center(
            child: ElevatedButton(
              onPressed: weatherCubit.onButtonPressed,
              child: const Icon(Icons.upload),
            ),
          ),
        ),
      ),
    );
  }
}
