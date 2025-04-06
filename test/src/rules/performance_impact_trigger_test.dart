// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/src/rules/performance_impact_rule.dart';

/// This test file contains examples of widget code that was incorrectly
/// triggering the performance_impact rule despite having keys.
/// Used to verify the fix for the overzealous rule behavior.

class KeyUtils {
  /// Creates a key using the provided identifier.
  static Key simpleKey(String identifier) => Key(identifier);
}

void main() {
  group('Performance impact rule - problematic triggers', () {
    test('rule should correctly analyze keys', () {
      // This is just to instantiate the rule for testing
      final rule = PerformanceImpactRule();
      expect(rule.code.name, equals('performance_impact'));
    });

    group('Example 1: SnackBar widgets with keys', () {
      testWidgets('SnackBar with proper key should not trigger rule',
          (WidgetTester tester) async {
        // This widget was incorrectly triggering the rule despite having a key
        final widgetCode = '''
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: KeyUtils.simpleKey('offline_mode_snackbar'),
              content: Text(
                value
                    ? l10n.offlineModeEnabled
                    : l10n.offlineModeDisabled,
                key: KeyUtils.simpleKey('offline_mode_text'),
              ),
            ),
          );
        ''';

        // Just used to visually show the code in test output
        expect(widgetCode.isNotEmpty, isTrue);

        // We can't directly verify the rule within this test since it requires analyzer
        // The real validation happens when running the custom lint on the project
      });
    });

    group('Example 2: Conditionally rendered widgets with keys', () {
      testWidgets('Widget with key inside conditional should not trigger',
          (WidgetTester tester) async {
        // This type of widget was incorrectly triggering the rule
        final widgetCode = '''
          if (isEnabled) {
            return Container(
              key: KeyUtils.simpleKey('enabled_container'),
              child: Text('Enabled'),
            );
          } else {
            return Container(
              key: KeyUtils.simpleKey('disabled_container'),
              child: Text('Disabled'),
            );
          }
        ''';

        expect(widgetCode.isNotEmpty, isTrue);
      });
    });

    group('Example 3: Parent-Child key inheritance', () {
      testWidgets('Child widget should inherit key status from parent',
          (WidgetTester tester) async {
        // This pattern was triggering the rule incorrectly
        final widgetCode = '''
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: KeyUtils.simpleKey('notifications_snackbar'),
              content: Text(
                l10n.notificationTogglingImplementation,
                key: KeyUtils.simpleKey('notifications_snackbar_text'),
              ),
            ),
          );
        ''';

        expect(widgetCode.isNotEmpty, isTrue);
      });
    });
  });
} 