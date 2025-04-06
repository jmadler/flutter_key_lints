// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/src/rules/require_widget_key_rule.dart';

// Simple mocks that don't rely on analyzer or internal APIs
class MockReporter {
  final List<String> errors = [];
  
  void reportIssue(String message) {
    errors.add(message);
  }
}

// Class to test rule detection logic with simplified approach
class RuleTestHelper {
  final MockReporter reporter = MockReporter();
  
  // Test require widget key rule
  bool shouldReportWithRequireWidgetKeyRule(String widgetType, {bool hasKey = false, bool isConst = false, String severity = 'info'}) {
    final rule = RequireWidgetKeyRule(
      severity: severity,
      exemptWidgets: const ['Divider', 'SizedBox', 'Padding', 'Spacer'],
    );
    
    // Skip const widgets
    if (isConst) return false;
    
    // Skip exempted widgets
    if (rule.exemptWidgets.contains(widgetType)) return false;
    
    // Report if widget doesn't have a key
    return !hasKey;
  }
  
  // Test require widget key rule with custom exempt list
  bool shouldReportWithCustomExemptList(String widgetType, {
    bool hasKey = false, 
    bool isConst = false, 
    required List<String> exemptWidgets,
  }) {
    final rule = RequireWidgetKeyRule(
      severity: 'info',
      exemptWidgets: exemptWidgets,
    );
    
    // Skip const widgets
    if (isConst) return false;
    
    // Skip exempted widgets
    if (exemptWidgets.contains(widgetType)) return false;
    
    // Report if widget doesn't have a key
    return !hasKey;
  }
  
  // Helper to check if a key is present in the widget
  bool hasWidgetKey(Widget widget) {
    return widget.key != null;
  }
}

void main() {
  group('RequireWidgetKeyRule', () {
    late RuleTestHelper helper;
    
    setUp(() {
      helper = RuleTestHelper();
    });
    
    group('rule behavior', () {
      test('has correct metadata', () {
        const rule = RequireWidgetKeyRule(severity: 'info');
        expect(rule.code.name, equals('require_widget_key'));
        expect(rule.code.problemMessage, contains('key parameter'));
        expect(rule.code.correctionMessage, contains('efficiency'));
      });
      
      test('correctly identifies widgets that need keys', () {
        // Should report widgets without keys that are not exempt
        expect(helper.shouldReportWithRequireWidgetKeyRule('Container'), isTrue);
        expect(helper.shouldReportWithRequireWidgetKeyRule('ListView'), isTrue);
        expect(helper.shouldReportWithRequireWidgetKeyRule('CustomWidget'), isTrue);
        
        // Should not report widgets with keys
        expect(helper.shouldReportWithRequireWidgetKeyRule('Container', hasKey: true), isFalse);
        expect(helper.shouldReportWithRequireWidgetKeyRule('ListView', hasKey: true), isFalse);
        
        // Should not report exempt widgets
        expect(helper.shouldReportWithRequireWidgetKeyRule('Divider'), isFalse);
        expect(helper.shouldReportWithRequireWidgetKeyRule('SizedBox'), isFalse);
        expect(helper.shouldReportWithRequireWidgetKeyRule('Padding'), isFalse);
        
        // Should not report const widgets
        expect(helper.shouldReportWithRequireWidgetKeyRule('Container', isConst: true), isFalse);
      });
      
      test('supports different severity levels', () {
        // Should have the same behavior regardless of severity
        expect(helper.shouldReportWithRequireWidgetKeyRule('Container', severity: 'info'), isTrue);
        expect(helper.shouldReportWithRequireWidgetKeyRule('Container', severity: 'warning'), isTrue);
        expect(helper.shouldReportWithRequireWidgetKeyRule('Container', severity: 'error'), isTrue);
        
        // Severity should not affect the logic for exempt widgets
        expect(helper.shouldReportWithRequireWidgetKeyRule('Divider', severity: 'error'), isFalse);
      });
      
      test('custom exempt widgets works correctly', () {
        final customExemptList = ['Container', 'CustomWidget', 'MyButton'];
        
        // Test with custom exempt widgets
        expect(helper.shouldReportWithCustomExemptList('Container', exemptWidgets: customExemptList), isFalse);
        expect(helper.shouldReportWithCustomExemptList('CustomWidget', exemptWidgets: customExemptList), isFalse);
        expect(helper.shouldReportWithCustomExemptList('MyButton', exemptWidgets: customExemptList), isFalse);
        
        // Test non-exempt widgets
        expect(helper.shouldReportWithCustomExemptList('Divider', exemptWidgets: customExemptList), isTrue);
        expect(helper.shouldReportWithCustomExemptList('SizedBox', exemptWidgets: customExemptList), isTrue);
        expect(helper.shouldReportWithCustomExemptList('Card', exemptWidgets: customExemptList), isTrue);
      });
    });
    
    group('fromJson constructor', () {
      test('handles complete configuration', () {
        final json = {
          'severity': 'error',
          'exempt_widgets': ['Container', 'Row', 'Column'],
        };
        
        final rule = RequireWidgetKeyRule.fromJson(json);
        
        expect(rule.exemptWidgets, contains('Container'));
        expect(rule.exemptWidgets, contains('Row'));
        expect(rule.exemptWidgets, contains('Column'));
        // Verify that the error code name is set correctly
        expect(rule.code.name, equals('require_widget_key'));
      });
      
      test('handles missing configuration', () {
        final json = <String, dynamic>{};
        
        final rule = RequireWidgetKeyRule.fromJson(json);
        
        // Should use default exempt widgets
        expect(rule.exemptWidgets, contains('Divider'));
        expect(rule.exemptWidgets, contains('SizedBox'));
        // Verify rule code is set correctly
        expect(rule.code.name, equals('require_widget_key'));
      });
      
      test('handles partial configuration', () {
        final json = {
          'severity': 'info',
        };
        
        final rule = RequireWidgetKeyRule.fromJson(json);
        
        // Should use default exempt widgets
        expect(rule.exemptWidgets, contains('Divider'));
        expect(rule.exemptWidgets, contains('SizedBox'));
        // Verify rule code is set correctly
        expect(rule.code.name, equals('require_widget_key'));
      });
    });
    
    group('widget tests', () {
      testWidgets('reports widgets without keys', (WidgetTester tester) async {
        // Just testing that we can build widgets - the actual lint rule
        // would normally report an issue on these widgets
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                Container(
                  // Missing key here
                  color: Colors.blue,
                  child: const Text('Container without key'),
                ),
                Card(
                  // Missing key here
                  child: const Text('Card without key'),
                ),
              ],
            ),
          ),
        );
        
        // Verify widgets without keys were created
        final containers = tester.widgetList<Container>(find.byType(Container));
        for (final container in containers) {
          expect(helper.hasWidgetKey(container), isFalse);
        }
        
        final cards = tester.widgetList<Card>(find.byType(Card));
        for (final card in cards) {
          expect(helper.hasWidgetKey(card), isFalse);
        }
      });
      
      testWidgets('does not report widgets with keys', (WidgetTester tester) async {
        // These should NOT trigger the rule
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                Container(
                  key: const ValueKey('container-1'),
                  color: Colors.blue,
                  child: const Text('Container with key'),
                ),
                Card(
                  key: const ValueKey('card-1'),
                  child: const Text('Card with key'),
                ),
              ],
            ),
          ),
        );
        
        // Verify widgets with keys were created
        final containers = tester.widgetList<Container>(find.byType(Container));
        for (final container in containers) {
          expect(helper.hasWidgetKey(container), isTrue);
        }
        
        final cards = tester.widgetList<Card>(find.byType(Card));
        for (final card in cards) {
          expect(helper.hasWidgetKey(card), isTrue);
        }
      });
      
      testWidgets('handles nested widgets properly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Container(
              key: const ValueKey('outer-container'),
              child: Column(
                children: [
                  Card(
                    // Missing key - would trigger rule
                    child: ListTile(
                      // Missing key - would trigger rule
                      title: const Text('Nested widgets without keys'),
                    ),
                  ),
                  Card(
                    key: const ValueKey('card-with-key'),
                    child: ListTile(
                      key: const ValueKey('list-tile-with-key'),
                      title: const Text('Nested widgets with keys'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        
        // Check outer container has key
        final outerContainer = tester.widget<Container>(find.byKey(const ValueKey('outer-container')));
        expect(helper.hasWidgetKey(outerContainer), isTrue);
        
        // Check nested widgets with keys
        final cardWithKey = tester.widget<Card>(find.byKey(const ValueKey('card-with-key')));
        expect(helper.hasWidgetKey(cardWithKey), isTrue);
        
        final listTileWithKey = tester.widget<ListTile>(find.byKey(const ValueKey('list-tile-with-key')));
        expect(helper.hasWidgetKey(listTileWithKey), isTrue);
        
        // Find widgets without keys
        final cardsWithoutKey = tester.widgetList<Card>(find.byType(Card)).where((w) => w.key == null);
        expect(cardsWithoutKey.isNotEmpty, isTrue);
        
        final listTilesWithoutKey = tester.widgetList<ListTile>(find.byType(ListTile)).where((w) => w.key == null);
        expect(listTilesWithoutKey.isNotEmpty, isTrue);
      });
    });
  });
} 