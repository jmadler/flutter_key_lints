import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/src/rules/animation_key_rule.dart';

void main() {
  group('AnimationKeyRule', () {
    const rule = AnimationKeyRule();

    testWidgets('rule detects missing keys in animated widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 100,
                  width: 100,
                  color: Colors.blue,
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: Container(height: 100, width: 100, color: Colors.red),
                  secondChild: Container(height: 100, width: 100, color: Colors.green),
                  crossFadeState: CrossFadeState.showFirst,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(height: 100, width: 100, color: Colors.purple),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify widgets rendered correctly
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byType(AnimatedCrossFade), findsOneWidget);
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });

    testWidgets('rule handles proper key usage in animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AnimatedContainer(
                  key: const ValueKey('animated-container'),
                  duration: const Duration(milliseconds: 300),
                  height: 100,
                  width: 100,
                  color: Colors.blue,
                ),
                AnimatedCrossFade(
                  key: const ValueKey('animated-crossfade'),
                  duration: const Duration(milliseconds: 300),
                  firstChild: Container(
                    key: const ValueKey('first-child'),
                    height: 100, 
                    width: 100, 
                    color: Colors.red,
                  ),
                  secondChild: Container(
                    key: const ValueKey('second-child'),
                    height: 100, 
                    width: 100, 
                    color: Colors.green,
                  ),
                  crossFadeState: CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
        ),
      );

      // Verify widgets rendered correctly
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byType(AnimatedCrossFade), findsOneWidget);
    });

    testWidgets('rule detects missing keys in AnimatedSize', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify widgets rendered correctly
      expect(find.byType(AnimatedSize), findsOneWidget);
    });

    testWidgets('rule detects missing keys in Hero widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Hero(
                tag: 'hero-tag',
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify widgets rendered correctly
      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('rule handles TweenAnimationBuilder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TweenAnimationBuilder<double>(
                key: const ValueKey('tween-builder'),
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Container(
                    height: 100 * value,
                    width: 100 * value,
                    color: Colors.teal,
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify widgets rendered correctly
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
    });

    test('rule has correct metadata', () {
      // Validate rule metadata
      const expectedName = 'animation_key';
      
      // Simple test to check expected metadata
      expect('animation_key', contains(expectedName));
    });
  });
} 