import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

sealed class WeatherEvent {}

class WeatherRequestedEvent extends WeatherEvent {}

class WeatherBloc extends SideEffectBloc<WeatherEvent, WeatherState, WeatherSideEffect> {
  WeatherBloc() : super(WeatherState(0)) {
    on<WeatherRequestedEvent>(_fetchNewWeather);
  }

  Future<void> _fetchNewWeather(WeatherRequestedEvent event, Emitter emitter) async {
    emitter(WeatherState(38));

    produceSideEffect(ShowBottomSheet());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WeatherBloc weatherBloc;

  @override
  void initState() {
    super.initState();
    weatherBloc = WeatherBloc();
  }

  @override
  void dispose() {
    weatherBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BlocSideEffectConsumer<WeatherBloc, WeatherState, WeatherSideEffect>(
          bloc: weatherBloc,
          sideEffectListener: (context, sideEffect) {
            if (sideEffect is ShowBottomSheet) {
              showBottomSheet(
                  context: context,
                  builder: (c) => Material(
                        child: Container(
                          color: Colors.black12,
                          height: 150,
                        ),
                      ));
            }
          },
          builder: (context, state) {
            return Center(
              child: ElevatedButton(
                onPressed: () => weatherBloc.add(WeatherRequestedEvent()),
                child: const Icon(Icons.upload),
              ),
            );
          },
        ),
      ),
    );
  }
}
