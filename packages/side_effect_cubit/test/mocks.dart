import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

void registerFallbacks() {
  registerFallbackValue(_FakeBuildContext());
}
