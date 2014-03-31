library risk.test.utils;

import 'package:morph/morph.dart';
import 'package:unittest/unittest.dart';

final _MORPH = new Morph();

/*
 * Assert equality between [actual] and [expected] by reflection.
 */
void expectEquals(actual, expected, {String reason, FailureHandler
    failureHandler, bool verbose: false}) {
  expect(_MORPH.serialize(actual), equals(_MORPH.serialize(expected)), reason:
      reason, failureHandler: failureHandler, verbose: verbose);
}
