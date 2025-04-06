import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/flutter_key_lints.dart';

/// Tests all the rules in combination to verify they work together properly.
/// This approach focuses on testing the rules' behavior by creating simplified
/// simulations of real-world scenarios rather than relying on analyzer mocks.
void main() {
  group('Integration tests for rule combinations', () {
    
    test('Rule names and types are correctly exported', () {
      // Verify all rules are exported correctly
      expect(RequireWidgetKeyRule, isNotNull);
      expect(ListItemKeyRule, isNotNull);
      expect(AppropriateKeyTypeRule, isNotNull);
      expect(AnimationKeyRule, isNotNull);
      expect(PerformanceImpactRule, isNotNull);
      
      // Verify rule names match expected patterns
      const requireWidgetKeyRule = RequireWidgetKeyRule(severity: 'info');
      const listItemKeyRule = ListItemKeyRule();
      const appropriateKeyTypeRule = AppropriateKeyTypeRule();
      const animationKeyRule = AnimationKeyRule();
      const performanceImpactRule = PerformanceImpactRule();
      
      expect(requireWidgetKeyRule.code.name, equals('require_widget_key'));
      expect(listItemKeyRule.code.name, equals('list_item_key'));
      expect(appropriateKeyTypeRule.code.name, equals('appropriate_key_type'));
      expect(animationKeyRule.code.name, equals('animation_key'));
      expect(performanceImpactRule.code.name, equals('performance_impact'));
    });
    
    test('Rule severity can be configured', () {
      const errorRule = RequireWidgetKeyRule(severity: 'error');
      const warningRule = RequireWidgetKeyRule(severity: 'warning');
      const infoRule = RequireWidgetKeyRule(severity: 'info');
      
      // Verify severities are configurable and don't crash
      expect(errorRule, isNotNull);
      expect(warningRule, isNotNull);
      expect(infoRule, isNotNull);
    });
    
    test('Rules handle different widget scenarios correctly', () {
      // Create rule instances
      const requireWidgetKeyRule = RequireWidgetKeyRule(severity: 'info');
      
      // Verify exempt widgets list works correctly
      expect(requireWidgetKeyRule.exemptWidgets, contains('Divider'));
      expect(requireWidgetKeyRule.exemptWidgets, contains('SizedBox'));
      expect(requireWidgetKeyRule.exemptWidgets, isNot(contains('Container')));
      
      // Test configuring exempt widgets
      final customRule = RequireWidgetKeyRule(
        severity: 'info',
        exemptWidgets: ['CustomExempt', 'TestWidget'],
      );
      
      expect(customRule.exemptWidgets, contains('CustomExempt'));
      expect(customRule.exemptWidgets, contains('TestWidget'));
      expect(customRule.exemptWidgets, isNot(contains('Divider')));
    });
    
    test('createPlugin returns plugin with getLintRules implemented', () {
      final plugin = createPlugin();
      
      expect(plugin, isNotNull);
      expect(plugin.toString(), contains('_KeyLintsPlugin'));
      
      // Verify the plugin instance looks correct
      expect(plugin.runtimeType.toString(), contains('KeyLints'));
    });
    
    test('fromJson constructor works for rule configuration', () {
      final rule = RequireWidgetKeyRule.fromJson({
        'exempt_widgets': ['CustomWidget', 'TestWidget'],
        'severity': 'error',
      });
      
      expect(rule.exemptWidgets, contains('CustomWidget'));
      expect(rule.exemptWidgets, contains('TestWidget'));
      expect(rule.exemptWidgets, isNot(contains('Divider')));
      
      // Test with empty config
      final defaultRule = RequireWidgetKeyRule.fromJson({});
      expect(defaultRule.exemptWidgets, contains('Divider'));
    });
    
    test('Rule combinations work together without conflicts', () {
      // Create all rules
      const requireWidgetKeyRule = RequireWidgetKeyRule(severity: 'info');
      const listItemKeyRule = ListItemKeyRule();
      const appropriateKeyTypeRule = AppropriateKeyTypeRule();
      const animationKeyRule = AnimationKeyRule();
      const performanceImpactRule = PerformanceImpactRule();
      
      // Verify they all have unique names
      final ruleNames = [
        requireWidgetKeyRule.code.name,
        listItemKeyRule.code.name,
        appropriateKeyTypeRule.code.name,
        animationKeyRule.code.name,
        performanceImpactRule.code.name,
      ];
      
      final uniqueNames = ruleNames.toSet();
      expect(uniqueNames.length, equals(ruleNames.length));
      
      // Verify all rules have problem messages
      expect(requireWidgetKeyRule.code.problemMessage, isNotEmpty);
      expect(listItemKeyRule.code.problemMessage, isNotEmpty);
      expect(appropriateKeyTypeRule.code.problemMessage, isNotEmpty);
      expect(animationKeyRule.code.problemMessage, isNotEmpty);
      expect(performanceImpactRule.code.problemMessage, isNotEmpty);
      
      // Verify all rules have correction messages
      expect(requireWidgetKeyRule.code.correctionMessage, isNotEmpty);
      expect(listItemKeyRule.code.correctionMessage, isNotEmpty);
      expect(appropriateKeyTypeRule.code.correctionMessage, isNotEmpty);
      expect(animationKeyRule.code.correctionMessage, isNotEmpty);
      expect(performanceImpactRule.code.correctionMessage, isNotEmpty);
    });
  });
} 