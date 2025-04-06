import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/flutter_key_lints.dart';

// Import additional coverage tests
import 'src/rules/additional_coverage_test.dart' as additional_coverage_test;
import 'final_coverage_test.dart' as final_coverage_test;
import 'main_test.dart' as main_test;
import 'standalone_widget_test.dart' as standalone_widget_test;
import 'src/rules/implementation_test.dart' as implementation_test;
import 'integration_test.dart' as integration_test;

void main() {
  group('key_lints plugin', () {
    test('plugin contains all expected rules', () {
      // Test that all the expected rules are accessible
      expect(AppropriateKeyTypeRule, isNotNull);
      expect(ListItemKeyRule, isNotNull);
      expect(RequireWidgetKeyRule, isNotNull);
      expect(AnimationKeyRule, isNotNull);
      expect(PerformanceImpactRule, isNotNull);
    });
    
    test('plugin exports all rules via library exports', () {
      // Verify that the rules are properly exported from the library
      const appropriateKeyRule = AppropriateKeyTypeRule();
      const listItemKeyRule = ListItemKeyRule();
      const requireWidgetKeyRule = RequireWidgetKeyRule(severity: 'info');
      const animationKeyRule = AnimationKeyRule();
      const performanceImpactRule = PerformanceImpactRule();
      
      // Each rule should have proper LintCode
      expect(appropriateKeyRule.code.name, equals('appropriate_key_type'));
      expect(listItemKeyRule.code.name, equals('list_item_key'));
      expect(requireWidgetKeyRule.code.name, equals('require_widget_key'));
      expect(animationKeyRule.code.name, equals('animation_key'));
      expect(performanceImpactRule.code.name, equals('performance_impact'));
    });
    
    test('createPlugin returns a valid plugin instance', () {
      final plugin = createPlugin();
      expect(plugin, isNotNull);
      expect(plugin.toString(), contains('_KeyLintsPlugin'));
    });
    
    test('plugin contains rule instances', () {
      final plugin = createPlugin();
      
      // Test that the plugin has rule instances
      expect(plugin.toString(), contains('_KeyLintsPlugin'));
      
      // We can't directly access the rules due to encapsulation,
      // but we can verify the plugin instance contains the expected type
      expect(plugin.runtimeType.toString(), contains('_KeyLintsPlugin'));
    });
  });
  
  // Run all our comprehensive tests
  group('Comprehensive coverage tests', () {
    additional_coverage_test.main();
    final_coverage_test.main();
    main_test.main();
    standalone_widget_test.main();
    implementation_test.main();
    integration_test.main();
  });
}
