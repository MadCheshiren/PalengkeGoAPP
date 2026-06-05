import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:palengkego/main.dart';

void main() {
  testWidgets('app loads and advances past splash timer', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PalengkeGoApp()));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('PalengkeGo'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
