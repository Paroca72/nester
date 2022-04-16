import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nester/nester.dart';

void main() {
  /// --------------------------------------------------
  /// LIST tests
  ///
  test('list empty values', () {
    bool ok = false;
    try {
      // Empty children
      Nester.list([]);

      ok = true;
    } on Exception {
      ok = false;
    }

    expect(ok, true);
  });

  test('list', () {
    bool ok = false;
    try {
      Nester.list([
        (next) => MaterialApp(
              title: 'Nester library',
              home: next,
            ),
        (next) => Scaffold(
              appBar: AppBar(
                title: const Center(
                  child: Text('Nester library'),
                ),
              ),
              body: next,
            ),
        (next) => Center(child: next),
        (next) => const Text(
              'Hello World!',
              textAlign: TextAlign.center,
            ),
      ]);

      ok = true;
    } on Exception {
      ok = false;
    }

    expect(ok, true);
  });

  /// --------------------------------------------------
  /// QUEUE tests
  ///
  test('queue empty values', () {
    bool ok = false;
    try {
      Nester.queue([
        (next) => MaterialApp(
              title: 'Nester library',
              home: next(),
            ),
        (next) => Scaffold(
              appBar: AppBar(
                title: const Center(
                  child: Text('Nester library'),
                ),
              ),
              body: next(),
            ),
        (next) => Center(child: next()),
        (next) => const Text(
              'Hello World!',
              textAlign: TextAlign.center,
            ),
      ]);

      ok = true;
    } on Exception {
      ok = false;
    }

    expect(ok, true);
  });
}
