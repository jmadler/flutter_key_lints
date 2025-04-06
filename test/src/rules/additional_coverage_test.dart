import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/src/rules/animation_key_rule.dart';
import 'package:flutter_key_lints/src/rules/appropriate_key_type_rule.dart';
import 'package:flutter_key_lints/src/rules/list_item_key_rule.dart';
import 'package:flutter_key_lints/src/rules/performance_impact_rule.dart';
import 'package:flutter_key_lints/src/rules/require_widget_key_rule.dart';

void main() {
  group('Rules constructor and metadata tests for additional coverage', () {
    test('AnimationKeyRule constructor and metadata', () {
      const rule = AnimationKeyRule();
      
      expect(rule.code.name, equals('animation_key'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
    });
    
    test('AppropriateKeyTypeRule constructor and metadata', () {
      const rule = AppropriateKeyTypeRule();
      
      expect(rule.code.name, equals('appropriate_key_type'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
    });
    
    test('ListItemKeyRule constructor and metadata', () {
      const rule = ListItemKeyRule();
      
      expect(rule.code.name, equals('list_item_key'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
    });
    
    test('PerformanceImpactRule constructor and metadata', () {
      const rule = PerformanceImpactRule();
      
      expect(rule.code.name, equals('performance_impact'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
      
      // Test helper method through invokeDynamic
      expect(rule.toString(), contains('PerformanceImpactRule'));
    });
    
    test('RequireWidgetKeyRule constructor and metadata', () {
      const rule = RequireWidgetKeyRule(severity: 'info');
      
      expect(rule.code.name, equals('require_widget_key'));
      expect(rule.code.problemMessage, isNotEmpty);
      expect(rule.code.correctionMessage, isNotEmpty);
      expect(rule.exemptWidgets, isNotEmpty);
      expect(rule.exemptWidgets.contains('Divider'), isTrue);
    });
    
    test('RequireWidgetKeyRule.fromJson constructor', () {
      final rule = RequireWidgetKeyRule.fromJson({
        'exempt_widgets': ['Container', 'Text'],
        'severity': 'error',
      });
      
      expect(rule.code.name, equals('require_widget_key'));
      expect(rule.exemptWidgets, isNotEmpty);
      expect(rule.exemptWidgets.contains('Container'), isTrue);
      expect(rule.exemptWidgets.contains('Text'), isTrue);
      expect(rule.exemptWidgets.contains('Divider'), isFalse);
    });
    
    test('RequireWidgetKeyRule.fromJson with default values', () {
      final rule = RequireWidgetKeyRule.fromJson({});
      
      expect(rule.code.name, equals('require_widget_key'));
      expect(rule.exemptWidgets, isNotEmpty);
      expect(rule.exemptWidgets.contains('Divider'), isTrue);
    });
  });
} 