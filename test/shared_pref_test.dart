import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo_bloc_pattern/shared_pref.dart';

main() {
  group('Test $SharedPref', () {
    const channel = MethodChannel(
      'plugins.flutter.io/shared_preferences',
    );
    const kTestValues = <String, dynamic>{
      'flutter.${SharedPref.favoritedIdsKey}': <String>[],
    };
    SharedPref sharedPref;
    Future<SharedPreferences> sharedPrefFuture;
    List<MethodCall> log = [];

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        await Future.delayed(const Duration(milliseconds: 1000));

        if (methodCall.method == 'getAll') {
          return kTestValues;
        }
        if (methodCall.method.startsWith('set')) {
          return true;
        }
        return null;
      });

      sharedPrefFuture = Future.value(await SharedPreferences.getInstance());
      sharedPref = SharedPref(sharedPrefFuture);
      log.clear();
    });
    tearDown(() async {
      await (await sharedPrefFuture).clear();
    });

    test('Emit initial value', () async {
      await expectLater(sharedPref.favoritedIds$, emits(<String>[]));
      expect(log, []);
    });

    test('Add or remove id', () async {
      const id = 'hoc081098';
      const result1 = ToggleFavResult(
        id: id,
        added: true,
        error: null,
        result: true,
      );
      expect(await sharedPref.toggleFavorite(id), result1);

      const result2 = ToggleFavResult(
        id: id,
        added: false,
        error: null,
        result: true,
      );
      expect(await sharedPref.toggleFavorite(id), result2);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'setStringList',
            arguments: <String, dynamic>{
              'key': 'flutter.${SharedPref.favoritedIdsKey}',
              'value': <String>[id],
            },
          ),
          isMethodCall(
            'setStringList',
            arguments: <String, dynamic>{
              'key': 'flutter.${SharedPref.favoritedIdsKey}',
              'value': <String>[],
            },
          ),
        ],
      );
    });

    test('Stream emit value after add or remove id', () async {
      const id = 'hoc081098';
      final future = expectLater(
        sharedPref.favoritedIds$,
        emitsInOrder(<List<String>>[
          <String>[],
          <String>[id],
          <String>[],
          <String>[id],
        ]),
      );
      await sharedPref.toggleFavorite(id);
      await sharedPref.toggleFavorite(id);
      await sharedPref.toggleFavorite(id);
      await future;

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'setStringList',
            arguments: <String, dynamic>{
              'key': 'flutter.${SharedPref.favoritedIdsKey}',
              'value': <String>[id],
            },
          ),
          isMethodCall(
            'setStringList',
            arguments: <String, dynamic>{
              'key': 'flutter.${SharedPref.favoritedIdsKey}',
              'value': <String>[],
            },
          ),
          isMethodCall(
            'setStringList',
            arguments: <String, dynamic>{
              'key': 'flutter.${SharedPref.favoritedIdsKey}',
              'value': <String>[id],
            },
          ),
        ],
      );
    });
  });
}
