import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ano/main.dart';
import 'package:ano/app/interface/glass_navigation.dart';

void main() {
  testWidgets(
    'Compact phone can enter, drag tabs, search rooms and send a room message',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const AnoApp());
      await tester.scrollUntilVisible(
        find.text('Sign in  →'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Sign in  →'));
      await tester.pumpAndSettle();
      expect(find.text('The lounge'), findsOneWidget);
      final bar = tester.getRect(find.byType(GlassNavigation));
      final gesture = await tester.startGesture(
        Offset(bar.left + 30, bar.center.dy),
      );
      await gesture.moveTo(Offset(bar.left + bar.width * .4, bar.center.dy));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('Find your people.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).hitTestable(),
        'After hours',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('After hours').last);
      await tester.pumpAndSettle();
      expect(find.text('A small room. A shared curiosity.'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).hitTestable(),
        'A quiet evening.',
      );
      await tester.tap(find.byTooltip('Send message').hitTestable());
      await tester.pumpAndSettle();
      expect(find.text('A quiet evening.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Friends open a distinct private conversation', (tester) async {
    await tester.pumpWidget(const AnoApp());
    await tester.scrollUntilVisible(
      find.text('Sign in  →'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Sign in  →'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Friends'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Moonlit'));
    await tester.pumpAndSettle();
    expect(find.text('Just the two of you.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
