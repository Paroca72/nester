import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nester/nester.dart';

void main() {
  test('empty values', () {
    bool ok = false;
    try {
      // Empty children
      const Nester([]);

      ok = true;
    } on Exception {
      ok = false;
    }

    expect(ok, true);
  });

  test('Widgets list', () {
    bool ok = false;
    try {
      Nester([
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
}
