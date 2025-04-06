import 'package:flutter_test/flutter_test.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:flutter_key_lints/main.dart' as main_lib;

void main() {
  group('main.dart', () {
    test('createPlugin returns a valid plugin instance', () {
      final plugin = main_lib.createPlugin();
      expect(plugin, isNotNull);
      expect(plugin.toString(), contains('_KeyLintsPlugin'));
    });
    
    test('_KeyLintsPlugin getLintRules returns RequireWidgetKeyRule', () {
      final plugin = main_lib.createPlugin();
      final lintRules = plugin.getLintRules(
        const CustomLintConfigs(
          enableAllLintRules: false,
          verbose: false,
          debug: false,
          rules: {},
        ),
      );
      
      expect(lintRules.length, equals(1));
      expect(lintRules.first.code.name, equals('require_widget_key'));
      
      // Verify the rule is configured properly
      expect(lintRules.first.toString(), contains('RequireWidgetKeyRule'));
    });
  });
} 