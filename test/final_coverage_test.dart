import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/flutter_key_lints.dart';

void main() {
  group('Rule metadata tests for comprehensive coverage', () {
    test('All rules should have correct metadata', () {
      // Test that all the expected rules are accessible
      expect(AppropriateKeyTypeRule, isNotNull);
      expect(ListItemKeyRule, isNotNull);
      expect(RequireWidgetKeyRule, isNotNull);
      expect(AnimationKeyRule, isNotNull);
      expect(PerformanceImpactRule, isNotNull);
    });
    
    test('AppropriateKeyTypeRule has correct metadata', () {
      const rule = AppropriateKeyTypeRule();
      expect(rule.code.name, equals('appropriate_key_type'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
      expect(rule.toString(), contains('AppropriateKeyTypeRule'));
    });
    
    test('ListItemKeyRule has correct metadata', () {
      const rule = ListItemKeyRule();
      expect(rule.code.name, equals('list_item_key'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
      expect(rule.toString(), contains('ListItemKeyRule'));
    });
    
    test('RequireWidgetKeyRule has correct metadata', () {
      const rule = RequireWidgetKeyRule(severity: 'info');
      expect(rule.code.name, equals('require_widget_key'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
      expect(rule.toString(), contains('RequireWidgetKeyRule'));
      expect(rule.exemptWidgets, isNotEmpty);
      expect(rule.exemptWidgets.length, greaterThan(5));
    });
    
    test('AnimationKeyRule has correct metadata', () {
      const rule = AnimationKeyRule();
      expect(rule.code.name, equals('animation_key'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
      expect(rule.toString(), contains('AnimationKeyRule'));
    });
    
    test('PerformanceImpactRule has correct metadata', () {
      const rule = PerformanceImpactRule();
      expect(rule.code.name, equals('performance_impact'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
      expect(rule.toString(), contains('PerformanceImpactRule'));
    });
    
    test('createPlugin returns a valid plugin instance', () {
      final plugin = createPlugin();
      expect(plugin, isNotNull);
      expect(plugin.toString(), contains('_KeyLintsPlugin'));
    });
    
    test('RequireWidgetKeyRule.fromJson works with all parameters', () {
      final rule = RequireWidgetKeyRule.fromJson({
        'exempt_widgets': ['Container', 'Text'],
        'severity': 'error',
      });
      
      expect(rule.code.name, equals('require_widget_key'));
      expect(rule.exemptWidgets, contains('Container'));
      expect(rule.exemptWidgets, contains('Text'));
      expect(rule.exemptWidgets.contains('Divider'), isFalse);
    });
    
    test('RequireWidgetKeyRule.fromJson works with default parameters', () {
      final rule = RequireWidgetKeyRule.fromJson({});
      
      expect(rule.code.name, equals('require_widget_key'));
      expect(rule.exemptWidgets, isNotEmpty);
      expect(rule.exemptWidgets, contains('Divider'));
    });
  });
} 