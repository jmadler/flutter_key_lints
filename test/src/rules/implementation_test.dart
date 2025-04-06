import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/src/rules/require_widget_key_rule.dart';
import 'package:flutter_key_lints/src/rules/list_item_key_rule.dart';
import 'package:flutter_key_lints/src/rules/animation_key_rule.dart';
import 'package:flutter_key_lints/src/rules/appropriate_key_type_rule.dart';
import 'package:flutter_key_lints/src/rules/performance_impact_rule.dart';
import '../test_helpers.dart';

void main() {
  group('RequireWidgetKeyRule implementation', () {
    test('exemptWidgets correctly identifies exempt widgets', () {
      // Create a custom rule instance with specific exempt widgets
      final customRule = RequireWidgetKeyRule(
        severity: 'warning',
        exemptWidgets: ['CustomExempt', 'AnotherExempt'],
      );
      
      // Testing through exposed properties
      expect(customRule.exemptWidgets, contains('CustomExempt'));
      expect(customRule.exemptWidgets, contains('AnotherExempt'));
      expect(customRule.exemptWidgets, isNot(contains('Container')));
      
      // Default list should contain common exempt widgets
      final defaultRule = const RequireWidgetKeyRule(severity: 'warning');
      expect(defaultRule.exemptWidgets, contains('Divider'));
      expect(defaultRule.exemptWidgets, contains('SizedBox'));
      expect(defaultRule.exemptWidgets, contains('Padding'));
    });
    
    test('fromJson constructor configures rule correctly', () {
      final jsonRule = RequireWidgetKeyRule.fromJson({
        'exempt_widgets': ['TestWidget', 'AnotherWidget'],
        'severity': 'error',
      });
      
      expect(jsonRule.exemptWidgets, contains('TestWidget'));
      expect(jsonRule.exemptWidgets, contains('AnotherWidget'));
      expect(jsonRule.exemptWidgets, isNot(contains('Divider')));
      
      // Default values when not specified
      final defaultJsonRule = RequireWidgetKeyRule.fromJson({});
      expect(defaultJsonRule.exemptWidgets, contains('Divider'));
      expect(defaultJsonRule.exemptWidgets.contains('SizedBox'), isTrue);
    });
    
    test('rule has correct metadata', () {
      const rule = RequireWidgetKeyRule(severity: 'info');
      verifyRuleMetadata(
        rule: rule,
        name: 'require_widget_key',
        problemMessageSubstring: 'key parameter',
        correctionMessageSubstring: 'efficiency',
      );
    });
  });
  
  group('ListItemKeyRule implementation', () {
    test('rule has correct metadata', () {
      const rule = ListItemKeyRule();
      
      // Directly check the actual messages
      expect(rule.code.name, equals('list_item_key'));
      expect(rule.code.problemMessage, equals('List items should have a key based on unique data'));
      expect(rule.code.correctionMessage, contains('key'));
    });
    
    testWidgets('can render list widgets correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildListView(useKeys: true));
      expect(find.byType(ListTile), findsWidgets);
      
      await tester.pumpWidget(buildListView(useKeys: false));
      expect(find.byType(ListTile), findsWidgets);
    });
  });
  
  group('AnimationKeyRule implementation', () {
    test('rule has correct metadata', () {
      const rule = AnimationKeyRule();
      
      // Directly check the actual messages
      expect(rule.code.name, equals('animation_key'));
      expect(rule.code.problemMessage, equals('Animations should have keys to prevent flickering'));
      expect(rule.code.correctionMessage, contains('key'));
    });
    
    testWidgets('can render animation widgets correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildAnimationWidgets(useKeys: true));
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byType(AnimatedOpacity), findsOneWidget);
      expect(find.byType(AnimatedPositioned), findsOneWidget);
      
      await tester.pumpWidget(buildAnimationWidgets(useKeys: false));
      expect(find.byType(AnimatedContainer), findsOneWidget);
      expect(find.byType(AnimatedOpacity), findsOneWidget);
      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });
  });
  
  group('AppropriateKeyTypeRule implementation', () {
    test('rule has correct metadata', () {
      const rule = AppropriateKeyTypeRule();
      verifyRuleMetadata(
        rule: rule,
        name: 'appropriate_key_type',
        problemMessageSubstring: 'key type',
        correctionMessageSubstring: 'ValueKey',
      );
    });
  });
  
  group('PerformanceImpactRule implementation', () {
    test('rule has correct metadata', () {
      const rule = PerformanceImpactRule();
      verifyRuleMetadata(
        rule: rule,
        name: 'performance_impact',
        problemMessageSubstring: 'performance',
        correctionMessageSubstring: 'key',
      );
    });
    
    testWidgets('can render conditional widgets correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildConditionalWidget(useKey: true, condition: true));
      expect(find.text('Conditional Widget'), findsOneWidget);
      
      await tester.pumpWidget(buildConditionalWidget(useKey: false, condition: true));
      expect(find.text('Conditional Widget'), findsOneWidget);
      
      await tester.pumpWidget(buildConditionalWidget(useKey: true, condition: false));
      expect(find.text('Conditional Widget'), findsNothing);
    });
  });
} 